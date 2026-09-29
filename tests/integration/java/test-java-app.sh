#!/usr/bin/env bash

set -euo pipefail

IMAGE="enterprise-hardened-java-app:test"
CONTAINER="enterprise-hardened-java-app-test"

cleanup() {
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "========================================"
echo "Java application integration test"
echo "========================================"

docker build \
    --tag "${IMAGE}" \
    tests/integration/java

docker run \
    --detach \
    --name "${CONTAINER}" \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    --tmpfs /tmp:rw,nosuid,nodev,noexec \
    --publish 18082:8080 \
    "${IMAGE}"

sleep 3

echo
echo "== HTTP application test =="

response="$(curl --fail --silent http://127.0.0.1:18082/)"

echo "${response}"

echo "${response}" | grep -q '"application":"enterprise-hardened-java-test"'
echo "${response}" | grep -q '"runtime":"java"'

echo "PASS: Java application responded correctly"

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

echo "PASS: Java application runs with hardened runtime settings"

echo
echo "========================================"
echo "ALL JAVA APPLICATION TESTS PASSED"
echo "========================================"