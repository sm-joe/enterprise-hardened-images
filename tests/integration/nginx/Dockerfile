FROM ghcr.io/sm-joe/enterprise-hardened-nginx:1.28

COPY app/index.html /usr/share/nginx/html/index.html

USER 10001:10001

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]