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
echo "== Credential environment defaults =="

printf '%s' "${CONFIG}" | python -c '
import json
import sys

data = json.load(sys.stdin)[0]
environment = data["Config"].get("Env") or []

blocked = {
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "AWS_SESSION_TOKEN",
    "AWS_SECURITY_TOKEN",
    "AWS_PROFILE",
    "AWS_DEFAULT_PROFILE",
    "GOOGLE_APPLICATION_CREDENTIALS",
    "AZURE_CLIENT_ID",
    "AZURE_CLIENT_SECRET",
    "AZURE_TENANT_ID",
    "AZURE_SUBSCRIPTION_ID",
    "GITHUB_TOKEN",
    "GH_TOKEN",
    "NPM_TOKEN",
    "NODE_AUTH_TOKEN",
    "DOCKER_AUTH_CONFIG",
}

for entry in environment:
    name = entry.split("=", 1)[0]

    if name in blocked:
        print(f"FAIL: credential-related environment variable is defined: {name}")
        sys.exit(1)

print("PASS: no credential-related environment defaults")
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