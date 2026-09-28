#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Debian runtime security tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Non-root runtime =="
docker run --rm "${IMAGE}" sh -c '
    test "$(id -u)" -eq 10001
    test "$(id -g)" -eq 10001
    echo "PASS: runtime uses UID/GID 10001"
'

echo
echo "== Privilege escalation =="
docker run --rm "${IMAGE}" sh -c '
    if su -c "id -u" root >/tmp/su-test 2>/dev/null; then
        if grep -qx "0" /tmp/su-test; then
            echo "FAIL: privilege escalation succeeded"
            exit 1
        fi
    fi
    rm -f /tmp/su-test
    echo "PASS: privilege escalation blocked"
'

echo
echo "== SUID/SGID =="
docker run --rm "${IMAGE}" sh -c '
    if find /usr/bin /usr/sbin -xdev -type f \
        \( -perm -4000 -o -perm -2000 \) \
        -print -quit | grep -q .; then
        echo "FAIL: SUID/SGID executable found"
        exit 1
    fi

    echo "PASS: no SUID/SGID executables"
'

echo
echo "== Read-only root filesystem compatibility =="
docker run --rm \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --tmpfs /run:rw,noexec,nosuid,size=16m \
    "${IMAGE}" \
    sh -c '
        test "$(id -u)" -eq 10001
        test -d /app
        echo "PASS: container starts with read-only root filesystem"
    '

echo
echo "== Application filesystem boundary =="
docker run --rm "${IMAGE}" sh -c '
    touch /app/.runtime-test
    rm -f /app/.runtime-test

    if touch /etc/.runtime-test 2>/dev/null; then
        echo "FAIL: /etc writable"
        exit 1
    fi

    echo "PASS: application/system filesystem boundary enforced"
'

echo
echo "========================================"
echo "ALL RUNTIME SECURITY TESTS PASSED"
echo "========================================"