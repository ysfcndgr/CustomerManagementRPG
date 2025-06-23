# Use Eclipse Temurin OpenJDK 17 as base image
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/customerupdate-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"] 