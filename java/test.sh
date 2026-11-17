#!/usr/bin/env bash
set -euo pipefail

image=${1:?Usage: test.sh IMAGE}

test_runtime() {
  local label=$1
  shift
  local output
  output=$(docker run --rm "$@" "$image" java -XX:+PrintFlagsFinal -version 2>&1)
  printf '%s\n' "$output" | awk '
    $2 == "UseBASE64Intrinsics" {
      print
      disabled = ($4 == "false")
    }
    /^openjdk version|^OpenJDK/ { print }
    END { exit !disabled }
  '
  echo "Java4Shell mitigation passed: $label"
}

test_runtime "default environment"
test_runtime "production JAVA_TOOL_OPTIONS" \
  --env JAVA_TOOL_OPTIONS=-Dio.github._4drian3d.signedvelocity.timeout=1000
