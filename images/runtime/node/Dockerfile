FROM debian:13 AS node-source

ARG NODE_VERSION=22.23.3

# Builder-only packages are intentionally resolved from the current Debian 13
# repository so security updates can be consumed without stale package pins.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xz-utils \
    && ARCH="$(dpkg --print-architecture)" \
    && case "${ARCH}" in \
        amd64) NODE_ARCH="x64" ;; \
        arm64) NODE_ARCH="arm64" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
        "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
        -o /tmp/node.tar.xz \
    && mkdir -p /node \
    && tar -xJf /tmp/node.tar.xz -C /node --strip-components=1 \
    && rm -f /tmp/node.tar.xz \
    && rm -rf /var/lib/apt/lists/*


FROM ghcr.io/sm-joe/enterprise-hardened-debian:13

ARG NODE_VERSION=22.23.3

LABEL org.opencontainers.image.title="Enterprise Hardened Node.js"
LABEL org.opencontainers.image.description="CIS L1-aligned enterprise Node.js 22 LTS runtime image"
LABEL org.opencontainers.image.vendor="Enterprise Hardened Images"
LABEL org.opencontainers.image.source="https://github.com/sm-joe/enterprise-hardened-images"
LABEL org.opencontainers.image.licenses="Internal"
LABEL org.opencontainers.image.base.name="ghcr.io/sm-joe/enterprise-hardened-debian:13"
LABEL org.opencontainers.image.security.profile="cis-l1-aligned"
LABEL org.opencontainers.image.security.non-root="true"
LABEL org.opencontainers.image.runtime.version="${NODE_VERSION}"

COPY --from=node-source /node/ /usr/local/

ENV NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false \
    PATH="/usr/local/bin:$PATH"

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["node", "-e", "const fs=require('fs'); if(process.getuid()!==10001 || process.getgid()!==10001 || !fs.existsSync('/app')) process.exit(1)"]

USER 10001:10001

CMD ["node", "--version"]