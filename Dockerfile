# syntax=docker/dockerfile:1

################################################################################
# Stage 1: Resolve dependencies
FROM ubuntu:22.04 AS deps

# Установка Java и утилит
RUN apt-get update && \
    apt-get install -y wget curl unzip openjdk-17-jdk maven nasm build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Копируем Maven wrapper и конфиги
COPY --chmod=0755 mvnw mvnw
COPY .mvn/ .mvn/

# Скачиваем зависимости
RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 ./mvnw dependency:go-offline -DskipTests

################################################################################
# Stage 2: Build application
FROM deps AS package

WORKDIR /build

COPY ./src src/
RUN --mount=type=bind,source=pom.xml,target=pom.xml \
    --mount=type=cache,target=/root/.m2 \
    ./mvnw package -DskipTests && \
    mv target/$(./mvnw help:evaluate -Dexpression=project.artifactId -q -DforceStdout)-$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout).jar target/app.jar

################################################################################
# Stage 3: Extract layers
FROM package AS extract

WORKDIR /build
RUN java -Djarmode=layertools -jar target/app.jar extract --destination target/extracted

################################################################################
# Stage 4: Final runtime image
FROM ubuntu:22.04 AS final

# Устанавливаем только JRE и NASM (для компиляции/запуска ассемблера)
RUN apt-get update && \
    apt-get install -y openjdk-17-jre nasm build-essential && \
    rm -rf /var/lib/apt/lists/*

# Создаем небезопасного пользователя
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" \
    --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser
USER appuser

WORKDIR /app

# Копируем слои приложения
COPY --from=extract /build/target/extracted/dependencies/ ./
COPY --from=extract /build/target/extracted/spring-boot-loader/ ./
COPY --from=extract /build/target/extracted/snapshot-dependencies/ ./
COPY --from=extract /build/target/extracted/application/ ./

EXPOSE 8877

ENTRYPOINT [ "java", "org.springframework.boot.loader.launch.JarLauncher" ]
