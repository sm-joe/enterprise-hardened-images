#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo "Hardened Runtime Security Regression"
echo "========================================"

run_security_test() {
    local image="$1"
    local name="$2"

    echo
    echo "========================================"
    echo "Testing: ${name}"
    echo "Image:   ${image}"
    echo "========================================"

    echo
    echo "== Identity =="

    uid="$(docker run --rm "${image}" sh -c 'id -u')"
    gid="$(docker run --rm "${image}" sh -c 'id -g')"

    if [[ "${uid}" != "10001" ]]; then
        echo "FAIL: UID is ${uid}; expected 10001"
        return 1
    fi

    if [[ "${gid}" != "10001" ]]; then
        echo "FAIL: GID is ${gid}; expected 10001"
        return 1
    fi

    echo "PASS: container runs as 10001:10001"

    echo
    echo "== Root filesystem protection =="

    if docker run --rm \
        --read-only \
        --tmpfs /tmp:rw,nosuid,nodev,noexec \
        "${image}" \
        sh -c 'touch /etc/runtime-security-test' \
        >/dev/null 2>&1
    then
        echo "FAIL: /etc is writable"
        return 1
    fi

    echo "PASS: /etc is not writable"

    if docker run --rm \
        --read-only \
        --tmpfs /tmp:rw,nosuid,nodev,noexec \
        "${image}" \
        sh -c 'touch /usr/runtime-security-test' \
        >/dev/null 2>&1
    then
        echo "FAIL: /usr is writable"
        return 1
    fi

    echo "PASS: /usr is not writable"

        echo
    echo "== Temporary filesystem =="

    docker run --rm \
        --read-only \
        --tmpfs /tmp:rw,nosuid,nodev,noexec \
        "${image}" \
        sh -c '
            touch /tmp/runtime-security-test
            rm -f /tmp/runtime-security-test
        '

    echo "PASS: /tmp is writable through explicit tmpfs"

    echo
    echo "== Capability drop =="

    capabilities="$(
        docker run --rm \
            --cap-drop=ALL \
            "${image}" \
            sh -c 'grep "^CapEff:" /proc/self/status | awk "{print \$2}"'
    )"

    if [[ "${capabilities}" != "0000000000000000" ]]; then
        echo "FAIL: effective capabilities are ${capabilities}"
        return 1
    fi

    echo "PASS: effective capabilities are zero"

    echo
    echo "== Privilege escalation protection =="

    docker run --rm \
        --cap-drop=ALL \
        --security-opt=no-new-privileges:true \
        "${image}" \
        sh -c '
            if grep -q "^NoNewPrivs:[[:space:]]*1" /proc/self/status; then
                echo "PASS: no-new-privileges is enabled"
            else
                echo "FAIL: no-new-privileges is not enabled"
                exit 1
            fi
        '

    echo
    echo "== SUID/SGID =="

    suid_count="$(
        docker run --rm "${image}" sh -c '
            find /usr/bin /usr/sbin /bin /sbin \
                -xdev \
                -type f \
                \( -perm -4000 -o -perm -2000 \) \
                2>/dev/null \
                | wc -l
        '
    )"

    if [[ "${suid_count}" != "0" ]]; then
        echo "FAIL: ${suid_count} SUID/SGID files found"
        return 1
    fi

    echo "PASS: no SUID/SGID binaries found"

    echo
    echo "PASS: ${name} runtime security boundary validated"
}

run_security_test \
    "ghcr.io/sm-joe/enterprise-hardened-python:3.13" \
    "Python 3.13"

run_security_test \
    "ghcr.io/sm-joe/enterprise-hardened-node:22" \
    "Node.js 22"

run_security_test \
    "ghcr.io/sm-joe/enterprise-hardened-java:21" \
    "Java 21"

run_security_test \
    "ghcr.io/sm-joe/enterprise-hardened-nginx:1.28" \
    "Nginx 1.28"

echo
echo "========================================"
echo "ALL RUNTIME SECURITY TESTS PASSED"
echo "========================================"