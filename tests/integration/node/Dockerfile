FROM ghcr.io/sm-joe/enterprise-hardened-node:22

COPY app/package.json /app/package.json
COPY app/server.js /app/server.js

USER 10001:10001

EXPOSE 8080

CMD ["node", "/app/server.js"]