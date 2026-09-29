FROM ghcr.io/sm-joe/enterprise-hardened-debian:13

ARG NGINX_VERSION=1.28.3-1~trixie

LABEL org.opencontainers.image.title="Enterprise Hardened Nginx"
LABEL org.opencontainers.image.description="CIS L1-aligned enterprise Nginx 1.28 runtime image"
LABEL org.opencontainers.image.vendor="Enterprise Hardened Images"
LABEL org.opencontainers.image.source="https://github.com/sm-joe/enterprise-hardened-images"
LABEL org.opencontainers.image.licenses="Internal"
LABEL org.opencontainers.image.base.name="ghcr.io/sm-joe/enterprise-hardened-debian:13"
LABEL org.opencontainers.image.security.profile="cis-l1-aligned"
LABEL org.opencontainers.image.security.non-root="true"
LABEL org.opencontainers.image.runtime.version="1.28"

USER root

# Nginx packages are obtained from the official Nginx Debian repository.
# The repository signing key fingerprint is verified before installation.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && curl -fsSL \
        https://nginx.org/keys/nginx_signing.key \
        -o /tmp/nginx_signing.key \
    && gpg --show-keys --with-colons /tmp/nginx_signing.key \
        | grep -q \
        "573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62" \
    && gpg --dearmor \
        -o /usr/share/keyrings/nginx-archive-keyring.gpg \
        /tmp/nginx_signing.key \
    && printf '%s\n' \
        'deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://nginx.org/packages/debian trixie nginx' \
        > /etc/apt/sources.list.d/nginx.list \
    && printf '%s\n' \
        'Package: *' \
        'Pin: origin nginx.org' \
        'Pin: release o=nginx' \
        'Pin-Priority: 900' \
        > /etc/apt/preferences.d/99nginx \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        "nginx=${NGINX_VERSION}" \
    && rm -f \
        /tmp/nginx_signing.key \
        /etc/apt/sources.list.d/nginx.list \
        /etc/apt/preferences.d/99nginx \
    && apt-get purge -y \
        curl \
        gnupg \
    && apt-get autoremove -y \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/apt/* \
        /var/cache/debconf/* \
        /var/log/apt/* \
        /var/log/dpkg.log \
        /var/log/alternatives.log

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p \
        /tmp/client_temp \
        /tmp/proxy_temp \
        /tmp/fastcgi_temp \
        /tmp/uwsgi_temp \
        /tmp/scgi_temp \
        /var/cache/nginx \
        /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && nginx -t \
    && rm -f /tmp/nginx.pid \
    && chown -R 10001:10001 \
        /tmp/client_temp \
        /tmp/proxy_temp \
        /tmp/fastcgi_temp \
        /tmp/uwsgi_temp \
        /tmp/scgi_temp \
        /var/cache/nginx \
    && chmod 0755 \
        /tmp/client_temp \
        /tmp/proxy_temp \
        /tmp/fastcgi_temp \
        /tmp/uwsgi_temp \
        /tmp/scgi_temp \
        /var/cache/nginx

WORKDIR /app

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["nginx", "-t"]

USER 10001:10001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]