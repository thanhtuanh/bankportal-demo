FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/auth-service-*.jar app.jar

EXPOSE 8081

ENV SPRING_PROFILES_ACTIVE=docker

CMD ["java", "-jar", "app.jar"]
