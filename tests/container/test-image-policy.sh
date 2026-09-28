#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Image policy validation"
echo "Image: ${IMAGE}"
echo "========================================"

CONFIG="$(docker inspect "${IMAGE}")"

echo
echo "== Non-root configuration =="

USER_VALUE="$(printf '%s' "${CONFIG}" | python -c '
import json
import sys

data = json.load(sys.stdin)[0]
print(data["Config"].get("User", ""))
')"

if [ "${USER_VALUE}" != "10001:10001" ]; then
    echo "FAIL: image USER is '${USER_VALUE}'"
    exit 1
fi

echo "PASS: image USER is 10001:10001"

echo
echo "== Security labels =="

printf '%s' "${CONFIG}" | python -c '
import json
import sys

data = json.load(sys.stdin)[0]
labels = data["Config"].get("Labels") or {}

required = {
    "org.opencontainers.image.security.profile": "cis-l1-aligned",
    "org.opencontainers.image.security.non-root": "true",
}

for key, expected in required.items():
    actual = labels.get(key)

    if actual != expected:
        print(f"FAIL: {key}={actual!r}; expected {expected!r}")
        sys.exit(1)

    print(f"PASS: {key}={expected}")
'

echo
echo "== Healthcheck =="

printf '%s' "${CONFIG}" | python -c '
import json
import sys

data = json.load(sys.stdin)[0]
healthcheck = data["Config"].get("Healthcheck")

if not healthcheck:
    print("FAIL: image has no healthcheck")
    sys.exit(1)

print("PASS: image has healthcheck")
'

echo
echo "========================================"
echo "ALL IMAGE POLICY TESTS PASSED"
echo "========================================"