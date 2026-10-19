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

# Only the disposable kernel NFS client needs mount permission.
docker run --rm --network "$name" --cap-add=SYS_ADMIN \
  --security-opt=apparmor=unconfined "$name-client" sh -eu -c '
    mkdir /mnt-ro
    options="nfsvers=3,proto=tcp,mountproto=tcp,mountvers=3,port=2049,mountport=2049,nolock,hard,retry=0"
    timeout 20 mount -t nfs -o "$options" server:/export /mnt
    trap "umount /mnt-ro; umount /mnt" EXIT
    timeout 20 mount -t nfs -o "$options,ro" server:/export /mnt-ro
    timeout 30 python3 /operations.py
  '
