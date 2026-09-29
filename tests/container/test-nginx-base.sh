#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Nginx hardened runtime regression tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Identity =="

docker run --rm "${IMAGE}" sh -c '
test "$(id -u)" -eq 10001
test "$(id -g)" -eq 10001
echo "PASS: Nginx runs as UID/GID 10001"
'

echo
echo "== Nginx version =="

docker run --rm "${IMAGE}" sh -c '
version="$(nginx -v 2>&1 | sed -E "s#nginx version: nginx/##")"

case "${version}" in
    1.28.*)
        echo "PASS: Nginx version ${version}"
        ;;
    *)
        echo "FAIL: expected Nginx 1.28.x, got ${version}"
        exit 1
        ;;
esac
'

echo
echo "== Nginx configuration =="

docker run --rm "${IMAGE}" nginx -t

echo "PASS: Nginx configuration is valid"

echo
echo "== Nginx startup =="

docker run --rm \
    --stop-timeout 5 \
    "${IMAGE}" \
    nginx -g "daemon off;" &
NGINX_PID=$!

sleep 2

if ! kill -0 "${NGINX_PID}" 2>/dev/null; then
    echo "FAIL: Nginx did not remain running"
    wait "${NGINX_PID}" || true
    exit 1
fi

kill "${NGINX_PID}"
wait "${NGINX_PID}" || true

echo "PASS: Nginx starts successfully as non-root"

echo
echo "== Non-privileged listener =="

docker run --rm "${IMAGE}" sh -c '
nginx -T 2>&1 | grep -q "listen 8080"
if nginx -T 2>&1 | grep -Eq "listen[[:space:]]+80([;[:space:]])"; then
    echo "FAIL: privileged HTTP listener detected"
    exit 1
fi
echo "PASS: Nginx listens on non-privileged port 8080"
'

echo
echo "== Application directory =="

docker run --rm "${IMAGE}" sh -c '
test -d /app
test "$(stat -c "%u" /app)" -eq 10001
test "$(stat -c "%g" /app)" -eq 10001
echo "PASS: /app ownership is 10001:10001"
'

echo
echo "== Nginx runtime directories =="

docker run --rm "${IMAGE}" sh -c '
set -eu

for path in \
    /tmp/client_temp \
    /tmp/proxy_temp \
    /tmp/fastcgi_temp \
    /tmp/uwsgi_temp \
    /tmp/scgi_temp
do
    if [ ! -d "${path}" ]; then
        echo "FAIL: runtime directory missing: ${path}"
        exit 1
    fi

    owner="$(stat -c "%u:%g" "${path}")"

    if [ "${owner}" != "10001:10001" ]; then
        echo "FAIL: ${path} ownership is ${owner}; expected 10001:10001"
        exit 1
    fi

    echo "PASS: ${path} owned by 10001:10001"
done

echo "PASS: all Nginx runtime directories are correctly owned"
'

echo
echo "== Application write access =="

docker run --rm "${IMAGE}" sh -c '
touch /app/.nginx-security-test
rm -f /app/.nginx-security-test
echo "PASS: application user can write /app"
'

echo
echo "== Runtime write access =="

docker run --rm "${IMAGE}" sh -c '
set -eu

touch /tmp/client_temp/.nginx-security-test
rm -f /tmp/client_temp/.nginx-security-test

touch /tmp/proxy_temp/.nginx-security-test
rm -f /tmp/proxy_temp/.nginx-security-test

touch /tmp/fastcgi_temp/.nginx-security-test
rm -f /tmp/fastcgi_temp/.nginx-security-test

touch /tmp/uwsgi_temp/.nginx-security-test
rm -f /tmp/uwsgi_temp/.nginx-security-test

touch /tmp/scgi_temp/.nginx-security-test
rm -f /tmp/scgi_temp/.nginx-security-test

echo "PASS: application user can write Nginx runtime directories"
'

echo
echo "== System filesystem protection =="

docker run --rm "${IMAGE}" sh -c '
for path in /etc /usr /var; do
    if touch "${path}/.nginx-security-test" 2>/dev/null; then
        echo "FAIL: ${path} is writable"
        exit 1
    fi
done

echo "PASS: system directories protected"
'

echo
echo "== Nginx configuration protection =="

docker run --rm "${IMAGE}" sh -c '
if touch /etc/nginx/.nginx-security-test 2>/dev/null; then
    echo "FAIL: /etc/nginx is writable"
    exit 1
fi

echo "PASS: Nginx configuration is protected"
'

echo
echo "== SUID/SGID =="

docker run --rm "${IMAGE}" sh -c '
if find /usr/bin /usr/sbin \
    -xdev \
    -type f \
    \( -perm -4000 -o -perm -2000 \) \
    -print -quit | grep -q .; then
    echo "FAIL: SUID/SGID files found"
    exit 1
fi

echo "PASS: no SUID/SGID files"
'

echo
echo "== Unnecessary tools =="

docker run --rm "${IMAGE}" sh -c '
for cmd in \
    sudo \
    curl \
    wget \
    ssh \
    git \
    vim \
    nano \
    gcc \
    make \
    nc \
    netcat \
    telnet \
    ftp
do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "FAIL: unexpected tool present: $cmd"
        exit 1
    fi
done

echo "PASS: unnecessary tools absent"
'

echo
echo "== Nginx process configuration =="

docker run --rm "${IMAGE}" sh -c '
nginx -T 2>&1 | grep -q "pid /tmp/nginx.pid;"
nginx -T 2>&1 | grep -q "access_log /dev/stdout;"
nginx -T 2>&1 | grep -q "error_log /dev/stderr"

echo "PASS: Nginx process configuration is hardened"
'

echo
echo "== Read-only root filesystem =="

docker run --rm \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --tmpfs /run:rw,noexec,nosuid,size=16m \
    "${IMAGE}" \
    nginx -t

echo "PASS: Nginx validates with read-only root filesystem"

echo
echo "== HTTP runtime =="

CONTAINER_NAME="enterprise-hardened-nginx-test"

cleanup() {
    docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

docker run \
    --detach \
    --name "${CONTAINER_NAME}" \
    --publish 18080:8080 \
    "${IMAGE}" >/dev/null

for _ in $(seq 1 30); do
    if docker exec "${CONTAINER_NAME}" nginx -t >/dev/null 2>&1; then
        break
    fi

    sleep 1
done

HTTP_RESPONSE="$(
    docker run --rm \
        --network host \
        curlimages/curl:8.17.0 \
        --silent \
        --show-error \
        --fail \
        http://127.0.0.1:18080/
)"

if [[ -n "${HTTP_RESPONSE}" ]]; then
    echo "PASS: Nginx HTTP listener responds on port 8080"
else
    echo "FAIL: Nginx HTTP listener returned an empty response"
    docker logs "${CONTAINER_NAME}" || true
    exit 1
fi

echo
echo "========================================"
echo "ALL NGINX BASE TESTS PASSED"
echo "========================================"