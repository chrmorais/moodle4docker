FROM alpine:edge
MAINTAINER pauloamgomes <pauloamgomes@gmail.com>

# Install packages
RUN echo 'http://alpine.gliderlabs.com/alpine/edge/main' > /etc/apk/repositories && \
    echo 'http://alpine.gliderlabs.com/alpine/edge/community' >> /etc/apk/repositories && \
    echo 'http://alpine.gliderlabs.com/alpine/edge/testing' >> /etc/apk/repositories && \

    apk add --update \
        bash \
        libressl \
        ca-certificates \
        openssh-client \
        rsync \
        git \
        curl \
        wget \
        gzip \
        tar \
        patch \
        perl \
        pcre \
        imap \
        mariadb-client \

        # Supervisor
        supervisor \

        # Temp packages
        build-base \
        autoconf \
        libtool \
        php7-dev \
        pcre-dev \

        # PHP packages
        php7 \
        php7-fpm \
        php7-opcache \
        php7-session \
        php7-dom \
        php7-xml \
        php7-xmlreader \
        php7-ctype \
        php7-ftp \
        php7-gd \
        php7-json \
        php7-posix \
        php7-curl \
        php7-pdo \
        php7-pdo_mysql \
        php7-sockets \
        php7-zlib \
        php7-mcrypt \
        php7-mysqli \
        php7-bz2 \
        php7-phar \
        php7-openssl \
        php7-posix \
        php7-zip \
        php7-calendar \
        php7-iconv \
        php7-imap \
        php7-soap \
        php7-dev \
        php7-pear \
        php7-redis \
        php7-mbstring \
        php7-exif \
        php7-xsl \
        php7-ldap \
        php7-bcmath \
        php7-oauth \
        php7-apcu \
        php7-intl \
        php7-xmlrpc \

        # Nginx packages
        nginx \

        && \

    # Create symlinks for backward compatibility
    ln -sf /usr/bin/php7 /usr/bin/php && \
    ln -sf /usr/sbin/php-fpm7 /usr/bin/php-fpm && \

    # Cleanup
    apk del --purge \
        *-dev \
        build-base \
        autoconf \
        libtool \
        && \

    rm -rf \
        /usr/include/php \
        /usr/lib/php/build \
        /var/cache/apk/* \
        /tmp/*

# Generate ssl certificates
RUN mkdir -p /etc/ssl/private && \
    mkdir -p /etc/ssl/certs && \
    openssl req -subj '/CN=localhost/O=Moodle Docker/C=UK' -new \
    -newkey rsa:2048 -days 365 -nodes -x509 \
    -keyout /etc/ssl/private/moodle.key \
    -out /etc/ssl/certs/moodle.crt

# Configure php.ini
RUN sed -i \
        -e "s/^expose_php.*/expose_php = Off/" \
        -e "s/^;date.timezone.*/date.timezone = UTC/" \
        -e "s/^memory_limit.*/memory_limit = -1/" \
        -e "s/^max_execution_time.*/max_execution_time = 300/" \
        -e "s/^; max_input_vars.*/max_input_vars = 2000/" \
        -e "s/^post_max_size.*/post_max_size = 256M/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 256M/" \
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^display_startup_errors.*/display_startup_errors = On/" \
        -e "s/^track_errors.*/track_errors = On/" \
        /etc/php7/php.ini && \

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php7/php.ini

# Copy configs
COPY config/00_opcache.ini /etc/php7/conf.d/
COPY config/php-fpm.conf /etc/php7/
COPY config/moodle.conf /etc/nginx/conf.d/default.conf

# Create nginx run dir
RUN mkdir -p /run/nginx

# Tweak nginx config
RUN sed -i -e"s/user nginx/user www-data/" /etc/nginx/nginx.conf && \
    sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/client_max_body_size 1m;/client_max_body_size 100m;\n\tclient_body_temp_path \/tmp 1 2;\n\tclient_body_buffer_size 256k;\n\tclient_body_in_file_only off;\n/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

# Create user www-data
RUN adduser -u 82 -D -S -G www-data www-data

WORKDIR /var/www/moodle
VOLUME /var/www/moodle
EXPOSE 80 443

# Download moodle and extract it
RUN  curl https://codeload.github.com/moodle/moodle/tar.gz/v3.2.1 -o /tmp/moodle-latest-32.tgz && \
    tar xfz /tmp/moodle-latest-32.tgz -C /tmp && \
    mv /tmp/moodle-3.2.1 /var/www/moodle/html && \
    mkdir /var/www/moodle/data && \
    chown -R www-data:www-data /var/www/moodle

# Copy supervisor config
COPY config/supervisord.conf /etc/supervisord.conf

# Copy entrypoint
COPY docker-entrypoint.sh /

RUN du -sh /var/www/moodle > /tmp/status.txt

ENTRYPOINT ["/docker-entrypoint.sh"]
