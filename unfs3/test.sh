#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: test.sh IMAGE}
directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
name="unfs3-test-$$"

cleanup() {
  docker logs "$name" || true
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm "$name" >/dev/null 2>&1 || true
  docker network rm "$name" >/dev/null 2>&1 || true
  docker image rm "$name-client" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker build --quiet --tag "$name-client" "$directory/test-client"
docker network create "$name" >/dev/null
docker volume create "$name" >/dev/null
docker run --detach --name "$name" --network "$name" --network-alias server \
  --read-only --security-opt=no-new-privileges --cap-drop=ALL \
  --cap-add=CHOWN --cap-add=DAC_OVERRIDE --cap-add=FOWNER --cap-add=FSETID \
  --cap-add=SETGID --cap-add=SETUID \
  --mount "type=volume,source=$name,target=/export" \
  "$image" >/dev/null

run_client() {
  # Only the disposable kernel NFS client needs mount permission.
  docker run --rm --network "$name" --cap-add=SYS_ADMIN \
    --security-opt=apparmor=unconfined "$name-client" sh -eu -c '
      mkdir /mnt-ro
      options="nfsvers=3,proto=tcp,mountproto=tcp,mountvers=3,port=2049,mountport=2049,nolock,hard,retry=0,actimeo=0"
      timeout 20 mount -t nfs -o "$options" server:/export /mnt
      trap "umount /mnt-ro; umount /mnt" EXIT
      timeout 20 mount -t nfs -o "$options,ro" server:/export /mnt-ro
      timeout 120 python3 "$1"
    ' sh "$1"
}

cache_stats=""
read_cache_stats() {
  local previous_stats=$cache_stats
  docker kill --signal=USR1 "$name" >/dev/null
  for attempt in {1..50}; do
    cache_stats=$(docker logs "$name" 2>&1 | awk '/^fh entries / { line = $0 } END { print line }')
    [[ -n "$cache_stats" && "$cache_stats" != "$previous_stats" ]] && break
    sleep 0.1
  done
  if [[ "$cache_stats" == "$previous_stats" || ! "$cache_stats" =~ ^fh\ entries\ [0-9]+\ access\ ([0-9]+)\ hit\ [0-9]+\ miss\ ([0-9]+)$ ]]; then
    echo "UNFS3 did not report file-handle cache statistics" >&2
    exit 1
  fi
  cache_accesses=${BASH_REMATCH[1]}
  cache_misses=${BASH_REMATCH[2]}
}

run_client /operations.py
read_cache_stats
initial_misses=$cache_misses
initial_accesses=$cache_accesses
run_client /metadata.py
read_cache_stats
# Fresh mounts can miss on root handles. The metadata phase must retain at
# least a 99.9% cache hit rate without relying on machine-dependent timings.
metadata_misses=$((cache_misses - initial_misses))
metadata_accesses=$((cache_accesses - initial_accesses))
if (( metadata_accesses <= 0 || metadata_misses * 1000 > metadata_accesses )); then
  echo "Metadata checks exhausted the file-handle cache: $cache_stats" >&2
  exit 1
fi
echo "File-handle cache checks passed: $cache_stats"
