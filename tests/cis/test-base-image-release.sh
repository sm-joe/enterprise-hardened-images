#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo "Base image release validation"
echo "========================================"

DOCKERFILES="$(find images -type f -name Dockerfile -print)"

if [ -z "${DOCKERFILES}" ]; then
    echo "FAIL: no Dockerfiles found under images/"
    exit 1
fi

FAILED=0

while IFS= read -r dockerfile; do
    while IFS= read -r from_line; do
        [ -z "${from_line}" ] && continue

        image_ref="$(printf '%s' "${from_line}" | sed -E 's/^[[:space:]]*FROM[[:space:]]+([^[:space:]]+).*/\1/')"

        case "${image_ref}" in
            *:latest|latest)
                echo "FAIL: floating latest tag found: ${dockerfile}: ${from_line}"
                FAILED=1
                ;;
            *@sha256:*)
                echo "FAIL: digest-based FROM is not permitted: ${dockerfile}: ${from_line}"
                FAILED=1
                ;;
            *:*)
                echo "PASS: explicit release tag: ${dockerfile}: ${from_line}"
                ;;
            *)
                echo "FAIL: untagged base image reference: ${dockerfile}: ${from_line}"
                FAILED=1
                ;;
        esac
    done < <(grep -E '^[[:space:]]*FROM[[:space:]]+' "${dockerfile}" || true)
done <<< "${DOCKERFILES}"

if [ "${FAILED}" -ne 0 ]; then
    echo
    echo "FAIL: base image release validation failed"
    exit 1
fi

echo
echo "PASS: all base image references use explicit release tags"
echo "========================================"