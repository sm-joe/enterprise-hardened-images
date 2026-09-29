#!/usr/bin/env bash

set -euo pipefail

IMAGE="enterprise-hardened-python-app:test"
CONTAINER="enterprise-hardened-python-app-test"

cleanup() {
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "========================================"
echo "Python application integration test"
echo "========================================"

docker build \
    --tag "${IMAGE}" \
    tests/integration/python

docker run \
    --detach \
    --name "${CONTAINER}" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,nosuid,nodev,noexec \
    --publish 18080:8080 \
    "${IMAGE}"

sleep 2

echo
echo "== HTTP application test =="

response="$(curl --fail --silent http://127.0.0.1:18080/)"

echo "${response}"

echo "${response}" | grep -q '"application": "enterprise-hardened-python-test"'
echo "${response}" | grep -q '"version": "3.13"'
echo "${response}" | grep -q '"uid": 10001'
echo "${response}" | grep -q '"gid": 10001'

echo "PASS: Python application responded correctly"

echo
echo "== Container security configuration =="

docker inspect "${CONTAINER}" \
    --format '{{.Config.User}}' \
    | grep -qx '10001:10001'

docker inspect "${CONTAINER}" \
    --format '{{.HostConfig.ReadonlyRootfs}}' \
    | grep -qx 'true'

docker inspect "${CONTAINER}" \
    --format '{{json .HostConfig.CapDrop}}' \
    | grep -q 'ALL'

echo "PASS: Python application runs with hardened runtime settings"

echo
echo "========================================"
echo "ALL PYTHON APPLICATION TESTS PASSED"
echo "========================================"