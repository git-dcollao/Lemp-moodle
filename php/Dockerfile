FROM php:8.2-fpm-alpine

# Moodle 5.1 requiere: PHP 8.0.5+ (8.1 recomendado)
# Extensiones requeridas: curl, dom, fileinfo, filter, hash, iconv, intl, json, libxml, mbstring, openssl, pcre, pdo, session, simplexml, xml, xmlreader, xmlrpc, zip, zlib

# Instalar dependencias del sistema
RUN apk add --no-cache --update \
    bash \
    curl \
    git \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    libzip-dev \
    libxml2-dev \
    oniguruma-dev \
    icu-dev \
    postgresql-dev \
    zip \
    unzip \
    nodejs \
    npm \
    supervisor \
    tzdata \
    rsyslog \
    busybox-suid \
    # Para cron
    dcron \
    curl-dev \
    openssl-dev

# Configurar zona horaria
ENV TZ=America/Santiago

# Instalar extensiones de PHP necesarias para Moodle 5.1
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        pdo_pgsql \
        intl \
        xmlrpc \
        zip \
        soap \
        mbstring \
        exif \
        bcmath \
        opcache \
        sockets \
        pcntl \
    && pecl install redis-5.3.7 \
    && docker-php-ext-enable redis \
    && pecl install xdebug-3.2.1 \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps \
    && rm -rf /tmp/pear

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer \
    --version=2.5.5

# Instalar Node.js y npm para compilación de temas
RUN npm install -g grunt

# Configurar usuario y permisos
RUN adduser -D -g 'www' -u 1000 www-user \
    && chown -R www-user:www-user /var/www

# Configurar PHP-FPM para usar usuario específico
RUN sed -i "s/user = www-data/user = www-user/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i "s/group = www-data/group = www-user/g" /usr/local/etc/php-fpm.d/www.conf

# Directorio de trabajo
WORKDIR /var/www/html

# Script de inicio personalizado
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
