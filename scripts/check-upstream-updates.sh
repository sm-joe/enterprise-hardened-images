#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo "Enterprise Hardened Image Upstream Check"
echo "========================================"

check_version() {
    local family="$1"
    local published="$2"
    local upstream="$3"

    echo
    echo "== ${family} =="

    echo "Published: ${published}"
    echo "Upstream:  ${upstream}"

    if [[ "${published}" == "${upstream}" ]]; then
        echo "Status:   CURRENT"
    else
        echo "Status:   UPDATE_AVAILABLE"
    fi
}

get_debian_package_version() {
    local package="$1"

    curl \
        --fail \
        --silent \
        --show-error \
        --location \
        --connect-timeout 10 \
        --max-time 30 \
        "https://deb.debian.org/debian/dists/trixie/main/binary-amd64/Packages.gz" \
        -o "$2"
}

echo
echo "== Debian 13 =="

published_debian="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        ghcr.io/sm-joe/enterprise-hardened-debian:13 \
        cat /etc/debian_version
)"

debian_release_file="$(mktemp)"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 10 \
    --max-time 30 \
    --output "${debian_release_file}" \
    https://deb.debian.org/debian/dists/stable/Release

debian_release="$(
    grep '^Version:' "${debian_release_file}" \
        | head -n 1 \
        | sed 's/^Version:[[:space:]]*//'
)"

rm -f "${debian_release_file}"

if [[ -z "${published_debian}" ]]; then
    echo "FAIL: unable to determine published Debian version"
    exit 1
fi

if [[ -z "${debian_release}" ]]; then
    echo "FAIL: unable to determine current Debian stable release"
    exit 1
fi

check_version \
    "Debian 13" \
    "${published_debian}" \
    "${debian_release}"

echo
echo "== Python 3.13 =="

published_python="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        ghcr.io/sm-joe/enterprise-hardened-python:3.13 \
        dpkg-query \
        -W \
        '-f=${Version}' \
        python3.13
)"

python_package_page="$(mktemp)"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 10 \
    --max-time 30 \
    --output "${python_package_page}" \
    https://packages.debian.org/trixie/amd64/python3.13

upstream_python="$(
    grep -oE '[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\+deb13u[0-9]+' \
        "${python_package_page}" \
        | sort -V \
        | tail -n 1
)"

rm -f "${python_package_page}"

if [[ -z "${published_python}" ]]; then
    echo "FAIL: unable to determine published Python 3.13 version"
    exit 1
fi

if [[ -z "${upstream_python}" ]]; then
    echo "FAIL: unable to determine current Python 3.13 Debian package"
    exit 1
fi

check_version \
    "Python 3.13" \
    "${published_python}" \
    "${upstream_python}"

echo
echo "== Node.js 22 =="

published_node="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        ghcr.io/sm-joe/enterprise-hardened-node:22 \
        node \
        --version
)"

published_node="${published_node#v}"

node_releases_file="$(mktemp)"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 10 \
    --max-time 30 \
    --output "${node_releases_file}" \
    https://nodejs.org/dist/index.json

upstream_node="$(
    grep -oE '"version"[[:space:]]*:[[:space:]]*"v22\.[0-9]+\.[0-9]+"' \
        "${node_releases_file}" \
        | grep -oE 'v22\.[0-9]+\.[0-9]+' \
        | sed 's/^v//' \
        | sort -V \
        | tail -n 1
)"

rm -f "${node_releases_file}"

if [[ -z "${published_node}" ]]; then
    echo "FAIL: unable to determine published Node.js version"
    exit 1
fi

if [[ -z "${upstream_node}" ]]; then
    echo "FAIL: unable to determine current Node.js 22 release"
    exit 1
fi

check_version \
    "Node.js 22" \
    "${published_node}" \
    "${upstream_node}"

echo
echo "== Java 21 =="

published_java="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        ghcr.io/sm-joe/enterprise-hardened-java:21 \
        dpkg-query \
        -W \
        '-f=${Version}' \
        openjdk-21-jre-headless
)"

echo "Published Java package: ${published_java}"

upstream_java="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        debian:13 \
        sh -c '
            apt-get update -qq &&
            apt-cache policy openjdk-21-jre-headless |
            awk "/Candidate:/ {print \$2; exit}"
        '
)"

if [[ -z "${published_java}" ]]; then
    echo "FAIL: unable to determine published Java 21 version"
    exit 1
fi

if [[ -z "${upstream_java}" ]]; then
    echo "FAIL: unable to determine current Java 21 Debian package"
    exit 1
fi

check_version \
    "Java 21" \
    "${published_java}" \
    "${upstream_java}"

echo
echo "== Nginx 1.28 =="

published_nginx="$(
    MSYS_NO_PATHCONV=1 docker run --rm \
        ghcr.io/sm-joe/enterprise-hardened-nginx:1.28 \
        dpkg-query \
        -W \
        '-f=${Version}' \
        nginx
)"

echo "Published Nginx package: ${published_nginx}"

nginx_package_page="$(mktemp)"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 10 \
    --max-time 30 \
    --output "${nginx_package_page}" \
    https://nginx.org/packages/debian/pool/nginx/n/nginx/

upstream_nginx="$(
    grep -oE 'nginx_1\.28\.[0-9]+-1~trixie\.dsc' \
        "${nginx_package_page}" \
        | sed 's/^nginx_//; s/\.dsc$//' \
        | sort -V \
        | tail -n 1
)"

rm -f "${nginx_package_page}"

if [[ -z "${published_nginx}" ]]; then
    echo "FAIL: unable to determine published Nginx version"
    exit 1
fi

if [[ -z "${upstream_nginx}" ]]; then
    echo "FAIL: unable to determine current Nginx 1.28 package"
    exit 1
fi

check_version \
    "Nginx 1.28" \
    "${published_nginx}" \
    "${upstream_nginx}"

echo
echo "========================================"
echo "UPSTREAM CHECK COMPLETED"
echo "========================================"