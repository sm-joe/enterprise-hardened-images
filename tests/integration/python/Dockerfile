FROM ghcr.io/sm-joe/enterprise-hardened-python:3.13

COPY app/app.py /app/app.py

USER 10001:10001

EXPOSE 8080

CMD ["python3", "/app/app.py"]