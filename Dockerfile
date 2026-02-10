ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm

ARG HOST_UID=1000
ARG HOST_GID=1000

RUN apt-get update && apt-get install -y \
    nginx \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    zip \
    unzip \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN set -eux; \
    if getent group www-data >/dev/null; then \
        groupmod -o -g ${HOST_GID} www-data; \
    else \
        groupadd -o -g ${HOST_GID} www-data; \
    fi; \
    if getent passwd www-data >/dev/null; then \
        usermod -o -u ${HOST_UID} -g www-data www-data; \
    else \
        useradd -o -u ${HOST_UID} -g www-data -m -s /bin/bash www-data; \
    fi

COPY nginx.conf /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY laravel.mk /usr/local/share/laravel.mk

WORKDIR /var/www/html
RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
