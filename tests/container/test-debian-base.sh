#!/usr/bin/env bash

shopt -s expand_aliases
alias docker='podman'

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Debian hardened base regression tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Identity =="
docker run --rm "${IMAGE}" sh -c '
    test "$(id -u)" -eq 10001
    test "$(id -g)" -eq 10001
    echo "PASS: container runs as UID/GID 10001"
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
echo "== Application write access =="
docker run --rm "${IMAGE}" sh -c '
    touch /app/.security-test
    rm -f /app/.security-test
    echo "PASS: application user can write /app"
'

echo
echo "== System filesystem protection =="
docker run --rm "${IMAGE}" sh -c '
    for path in /etc /usr /var; do
        if touch "${path}/.security-test" 2>/dev/null; then
            echo "FAIL: ${path} is writable"
            exit 1
        fi
    done
    echo "PASS: system directories protected"
'

echo
echo "== SUID/SGID =="
docker run --rm "${IMAGE}" sh -c '
    if find /usr/bin /usr/sbin -xdev -type f \( -perm -4000 -o -perm -2000 \) -print -quit | grep -q .; then
        echo "FAIL: SUID/SGID files found"
        exit 1
    fi
    echo "PASS: no SUID/SGID files"
'

echo
echo "== Unnecessary tools =="
docker run --rm "${IMAGE}" sh -c '
    for cmd in sudo curl wget ssh git vim nano gcc make nc netcat telnet ftp; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "FAIL: unexpected tool present: $cmd"
            exit 1
        fi
    done
    echo "PASS: unnecessary tools absent"
'

echo
echo "== APT metadata =="
docker run --rm "${IMAGE}" sh -c '
    if find /var/lib/apt/lists -type f -print -quit 2>/dev/null | grep -q .; then
        echo "FAIL: APT metadata remains"
        exit 1
    fi
    echo "PASS: APT metadata removed"
'

echo
echo "== Account configuration =="
docker run --rm "${IMAGE}" sh -c '
    test "$(getent passwd 10001 | cut -d: -f7)" = "/usr/sbin/nologin"
    test "$(getent passwd 10001 | cut -d: -f6)" = "/nonexistent"
    echo "PASS: application account uses nologin"
'

echo
echo "========================================"
echo "ALL DEBIAN BASE TESTS PASSED"
echo "========================================"