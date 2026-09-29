FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

COPY app/pom.xml .
COPY app/src ./src

RUN mvn -B -DskipTests package

FROM ghcr.io/sm-joe/enterprise-hardened-java:21

COPY --from=builder \
    /build/target/enterprise-hardened-java-test-1.0.0.jar \
    /app/app.jar

USER 10001:10001

EXPOSE 8080

CMD ["java", "-jar", "/app/app.jar"]