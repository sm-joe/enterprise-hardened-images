#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Python hardened runtime regression tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Identity =="

docker run --rm "${IMAGE}" python -c '
import os

assert os.getuid() == 10001
assert os.getgid() == 10001

print("PASS: Python runs as UID/GID 10001")
'

echo
echo "== Python version =="

docker run --rm "${IMAGE}" python -c '
import sys

assert sys.version_info.major == 3
assert sys.version_info.minor == 13

print(f"PASS: Python version is {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")
'

echo
echo "== Python execution =="

docker run --rm "${IMAGE}" python -c '
import sys

result = 2 + 2

assert result == 4
assert sys.executable == "/usr/local/bin/python"

print("PASS: Python executes correctly")
'

echo
echo "== Python environment =="

docker run --rm "${IMAGE}" python -c '
import os
import sys

assert os.environ.get("PYTHONDONTWRITEBYTECODE") == "1"
assert os.environ.get("PYTHONUNBUFFERED") == "1"
assert os.environ.get("PYTHONFAULTHANDLER") == "1"

assert sys.prefix == "/usr"

print("PASS: Python runtime environment configured")
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
touch /app/.python-security-test
rm -f /app/.python-security-test

echo "PASS: application user can write /app"
'

echo
echo "== System filesystem protection =="

docker run --rm "${IMAGE}" sh -c '
for path in /etc /usr /var; do
    if touch "${path}/.python-security-test" 2>/dev/null; then
        echo "FAIL: ${path} is writable"
        exit 1
    fi
done

echo "PASS: system directories protected"
'

echo
echo "== SUID/SGID =="

docker run --rm "${IMAGE}" sh -c '
if find /usr/bin /usr/sbin -xdev -type f \
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
echo "== Python read-only root filesystem =="

docker run --rm \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --tmpfs /run:rw,noexec,nosuid,size=16m \
    "${IMAGE}" \
    python -c '
import os
import sys

assert os.getuid() == 10001
assert sys.version_info.minor == 13

print("PASS: Python starts with read-only root filesystem")
'

echo
echo "== Python package availability =="

docker run --rm "${IMAGE}" python -c '
import ssl
import sqlite3
import bz2
import lzma
import ctypes

print("PASS: required Python standard-library modules available")
'

echo
echo "========================================"
echo "ALL PYTHON BASE TESTS PASSED"
echo "========================================"