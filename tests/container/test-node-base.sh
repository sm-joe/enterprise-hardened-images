#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Node.js hardened runtime regression tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Identity =="

docker run --rm "${IMAGE}" node -e '
if (process.getuid() !== 10001 || process.getgid() !== 10001) {
    process.exit(1)
}

console.log("PASS: Node.js runs as UID/GID 10001")
'

echo
echo "== Node.js version =="

docker run --rm "${IMAGE}" node -e '
const major = Number(process.versions.node.split(".")[0]);
const minor = Number(process.versions.node.split(".")[1]);

if (major !== 22) {
    console.error(`FAIL: expected Node.js 22.x, got ${process.version}`);
    process.exit(1);
}

if (minor < 23) {
    console.error(`FAIL: expected Node.js >=22.23, got ${process.version}`);
    process.exit(1);
}

console.log(`PASS: Node.js version ${process.version}`)
'

echo
echo "== npm version =="

docker run --rm "${IMAGE}" npm --version

echo
echo "== JavaScript execution =="

docker run --rm "${IMAGE}" node -e '
const result = 2 + 2;

if (result !== 4) {
    process.exit(1);
}

console.log("PASS: JavaScript execution works")
'

echo
echo "== Node.js runtime modules =="

docker run --rm "${IMAGE}" node -e '
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const https = require("https");

if (!crypto || !fs || !path || !https) {
    process.exit(1);
}

console.log("PASS: required Node.js runtime modules available")
'

echo
echo "== Runtime environment =="

docker run --rm "${IMAGE}" node -e '
if (process.env.NODE_ENV !== "production") {
    process.exit(1);
}

if (process.env.NPM_CONFIG_UPDATE_NOTIFIER !== "false") {
    process.exit(1);
}

if (process.env.NPM_CONFIG_FUND !== "false") {
    process.exit(1);
}

console.log("PASS: Node.js runtime environment configured")
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
touch /app/.node-security-test
rm -f /app/.node-security-test

echo "PASS: application user can write /app"
'

echo
echo "== System filesystem protection =="

docker run --rm "${IMAGE}" sh -c '
for path in /etc /usr /var; do
    if touch "${path}/.node-security-test" 2>/dev/null; then
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
echo "== Package footprint =="

docker run --rm "${IMAGE}" sh -c '
if dpkg-query -W -f="${Package}\n" 2>/dev/null \
    | grep -Eq "^(curl|wget|openssh|git|vim|nano|gcc|make|netcat|telnet|ftp)$"; then

    echo "FAIL: unexpected package found in Node.js runtime image"
    dpkg-query -W -f="${Package}\n" 2>/dev/null \
        | grep -E "^(curl|wget|openssh|git|vim|nano|gcc|make|netcat|telnet|ftp)$"
    exit 1
fi

echo "PASS: Node.js runtime package footprint is minimal"
'

echo
echo "== Read-only root filesystem =="

docker run --rm \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --tmpfs /run:rw,noexec,nosuid,size=16m \
    "${IMAGE}" \
    node -e '
if (process.getuid() !== 10001) {
    process.exit(1);
}

console.log("PASS: Node.js starts with read-only root filesystem")
'

echo
echo "== npm cache behavior =="

docker run --rm "${IMAGE}" sh -c '
npm config get cache

echo "PASS: npm configuration accessible"
'

echo
echo "========================================"
echo "ALL NODE.JS BASE TESTS PASSED"
echo "========================================"