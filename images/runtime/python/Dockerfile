FROM ghcr.io/sm-joe/enterprise-hardened-debian:13

LABEL org.opencontainers.image.title="Enterprise Hardened Python"
LABEL org.opencontainers.image.description="CIS L1-aligned enterprise Python 3.13 runtime image"
LABEL org.opencontainers.image.vendor="Enterprise Hardened Images"
LABEL org.opencontainers.image.source="https://github.com/sm-joe/enterprise-hardened-images"
LABEL org.opencontainers.image.licenses="Internal"
LABEL org.opencontainers.image.base.name="ghcr.io/sm-joe/enterprise-hardened-debian:13"
LABEL org.opencontainers.image.security.profile="cis-l1-aligned"
LABEL org.opencontainers.image.security.non-root="true"

USER root

RUN mkdir -p /var/lib/apt/lists/partial \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.13 \
        python3.13-venv \
        python3-pip \
        ca-certificates \
        tzdata \
    && ln -sf /usr/bin/python3.13 /usr/local/bin/python \
    && ln -sf /usr/bin/python3.13 /usr/local/bin/python3 \
    && ln -sf /usr/bin/pip3 /usr/local/bin/pip \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/* \
        /var/cache/debconf/* \
        /var/log/apt/* \
        /var/log/dpkg.log \
        /var/log/alternatives.log

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PATH="/usr/local/bin:$PATH"

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import os; assert os.getuid() == 10001; assert os.getgid() == 10001; assert os.path.isdir('/app')"]

USER 10001:10001

CMD ["python", "--version"]