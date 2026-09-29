FROM ghcr.io/sm-joe/enterprise-hardened-debian:13

LABEL org.opencontainers.image.title="Enterprise Hardened Java"
LABEL org.opencontainers.image.description="CIS L1-aligned enterprise OpenJDK 21 LTS runtime image"
LABEL org.opencontainers.image.vendor="Enterprise Hardened Images"
LABEL org.opencontainers.image.source="https://github.com/sm-joe/enterprise-hardened-images"
LABEL org.opencontainers.image.licenses="Internal"
LABEL org.opencontainers.image.base.name="ghcr.io/sm-joe/enterprise-hardened-debian:13"
LABEL org.opencontainers.image.security.profile="cis-l1-aligned"
LABEL org.opencontainers.image.security.non-root="true"
LABEL org.opencontainers.image.runtime.version="21"

USER root

# hadolint ignore=DL3008
RUN mkdir -p /var/lib/apt/lists/partial \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        openjdk-21-jre-headless \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/* \
        /var/cache/debconf/* \
        /var/log/apt/* \
        /var/log/dpkg.log \
        /var/log/alternatives.log

ENV JAVA_TOOL_OPTIONS="-Djava.awt.headless=true" \
    JAVA_HOME="/usr/lib/jvm/java-21-openjdk"

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["java", "-version"]

USER 10001:10001

CMD ["java", "-version"]