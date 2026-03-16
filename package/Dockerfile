ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    unzip \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    groupadd -o -g ${HOST_GID} devuser; \
    useradd -o -u ${HOST_UID} -g devuser -m -s /bin/bash devuser; \
    mkdir -p /home/devuser/.composer/cache; \
    chown -R devuser:devuser /home/devuser; \
    git config --global --add safe.directory '*'

COPY package.mk /usr/local/share/package.mk

WORKDIR /app

USER devuser
