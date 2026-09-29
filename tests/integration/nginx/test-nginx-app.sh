#!/usr/bin/env bash

set -euo pipefail

IMAGE="enterprise-hardened-nginx-app:test"
CONTAINER="enterprise-hardened-nginx-app-test"

cleanup() {
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "========================================"
echo "Nginx application integration test"
echo "========================================"

docker build \
    --tag "${IMAGE}" \
    tests/integration/nginx

docker run \
    --detach \
    --name "${CONTAINER}" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,nosuid,nodev,noexec \
    --publish 18083:8080 \
    "${IMAGE}"

sleep 2

echo
echo "== HTTP application test =="

response="$(curl --fail --silent http://127.0.0.1:18083/)"

echo "${response}"

echo "${response}" | grep -q "Enterprise Hardened Nginx"
echo "${response}" | grep -q "Application integration test passed"

echo "PASS: Nginx served application successfully"

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

echo "PASS: Nginx application runs with hardened runtime settings"

echo
echo "========================================"
echo "ALL NGINX APPLICATION TESTS PASSED"
echo "========================================"