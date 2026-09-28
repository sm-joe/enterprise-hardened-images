FROM debian:13

LABEL org.opencontainers.image.title="Enterprise Hardened Debian"
LABEL org.opencontainers.image.description="CIS L1-aligned enterprise Debian base image"
LABEL org.opencontainers.image.vendor="Enterprise Hardened Images"
LABEL org.opencontainers.image.source="https://github.com/sm-joe/enterprise-hardened-images"
LABEL org.opencontainers.image.licenses="Internal"
LABEL org.opencontainers.image.base.name="debian:13"
LABEL org.opencontainers.image.security.profile="cis-l1-aligned"
LABEL org.opencontainers.image.security.non-root="true"

RUN groupadd --gid 10001 app \
    && useradd \
        --uid 10001 \
        --gid 10001 \
        --no-create-home \
        --home-dir /nonexistent \
        --shell /usr/sbin/nologin \
        app

RUN mkdir -p \
        /app \
        /tmp \
        /var/tmp \
        /run \
    && chown 10001:10001 /app \
    && chmod 0755 /app \
    && chmod 1777 /tmp /var/tmp \
    && chmod 0755 /run

RUN find /usr/bin /usr/sbin \
    -xdev \
    -type f \
    \( -perm -4000 -o -perm -2000 \) \
    -exec chmod a-s {} +

RUN rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/cache/debconf/* \
    /var/log/apt/* \
    /var/log/dpkg.log \
    /var/log/alternatives.log

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/bin/sh", "-c", "test \"$(id -u)\" -eq 10001 && test \"$(id -g)\" -eq 10001 && test -d /app"]

USER 10001:10001