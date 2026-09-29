#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:?Usage: $0 <image>}"

echo "========================================"
echo "Java hardened runtime regression tests"
echo "Image: ${IMAGE}"
echo "========================================"

echo
echo "== Identity =="

docker run --rm "${IMAGE}" sh -c '
test "$(id -u)" -eq 10001
test "$(id -g)" -eq 10001

echo "PASS: Java runs as UID/GID 10001"
'

echo
echo "== Java version =="

docker run --rm "${IMAGE}" sh -c '
version="$(java -version 2>&1 | awk -F\" '\''/version/ {print $2}'\'')"

case "${version}" in
    21.*)
        echo "PASS: Java version ${version}"
        ;;
    *)
        echo "FAIL: expected Java 21.x, got ${version}"
        exit 1
        ;;
esac
'

echo
echo "== JAVA_HOME =="

docker run --rm "${IMAGE}" sh -c '
test -d "${JAVA_HOME}"
test -x "${JAVA_HOME}/bin/java"

echo "PASS: JAVA_HOME is ${JAVA_HOME}"
'

echo
echo "== Java execution =="

docker run --rm "${IMAGE}" sh -c '
mkdir -p /tmp/java-test

cat > /tmp/java-test/Hello.java <<'\''EOF'\''
public class Hello {
    public static void main(String[] args) {
        if (2 + 2 != 4) {
            System.exit(1);
        }

        System.out.println("PASS: Java execution works");
    }
}
EOF

java /tmp/java-test/Hello.java

rm -rf /tmp/java-test
'

echo
echo "== Runtime properties =="

docker run --rm "${IMAGE}" sh -c '
java -XshowSettings:properties -version 2>&1 \
    | grep -q "java.version"

echo "PASS: Java runtime properties accessible"
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
touch /app/.java-security-test
rm -f /app/.java-security-test

echo "PASS: application user can write /app"
'

echo
echo "== System filesystem protection =="

docker run --rm "${IMAGE}" sh -c '
for path in /etc /usr /var; do
    if touch "${path}/.java-security-test" 2>/dev/null; then
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
for cmd in sudo curl wget ssh git vim nano gcc make nc netcat telnet ftp javac jdb jconsole; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "FAIL: unexpected tool present: $cmd"
        exit 1
    fi
done

echo "PASS: unnecessary tools absent"
'

echo
echo "== Read-only root filesystem =="

docker run --rm \
    --read-only \
    --tmpfs /tmp:rw,noexec,nosuid,size=64m \
    --tmpfs /run:rw,noexec,nosuid,size=16m \
    "${IMAGE}" \
    java -version

echo "PASS: Java starts with read-only root filesystem"

echo
echo "========================================"
echo "ALL JAVA BASE TESTS PASSED"
echo "========================================"