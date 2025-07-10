# backend/Dockerfile
# Build stage - use matching JDK version 17.0.12
FROM eclipse-temurin:17.0.12_7-jdk-jammy as builder
WORKDIR /app
# Copy Maven wrapper & pom
COPY mvnw pom.xml ./
COPY .mvn .mvn
# Go offline
RUN ./mvnw dependency:go-offline -B
# Copy source & build
COPY src src
RUN ./mvnw package -DskipTests -B

# Runtime stage
FROM eclipse-temurin:17.0.12_7-jdk-jammy
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]