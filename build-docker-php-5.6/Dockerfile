FROM alpine:edge
MAINTAINER pauloamgomes <pauloamgomes@gmail.com>

ENV MOODLE_VERSION ${MOODLE_VERSION}
ENV MOODLE_HOSTNAME ${MOODLE_HOSTNAME}
ENV MOODLE_DB_NAME ${MOODLE_DB_NAME}
ENV MOODLE_USER ${MOODLE_USER}
ENV MOODLE_PASS ${MOODLE_PASS}

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
        php5-dev \
        pcre-dev \

        # PHP packages
        php5 \
        php5-common \
        php5-cli \
        php5-fpm \
        php5-opcache \
        php5-dom \
        php5-xml \
        php5-xmlreader \
        php5-ctype \
        php5-ftp \
        php5-gd \
        php5-json \
        php5-posix \
        php5-curl \
        php5-pdo \
        php5-pdo_mysql \
        php5-sockets \
        php5-zlib \
        php5-mcrypt \
        php5-pcntl \
        php5-mysql \
        php5-mysqli \
        php5-sqlite3 \
        php5-bz2 \
        php5-pear \
        php5-exif \
        php5-phar \
        php5-openssl \
        php5-posix \
        php5-zip \
        php5-calendar \
        php5-iconv \
        php5-imap \
        php5-soap \
        php5-memcache \
        php5-redis \
        php5-xdebug \
        php5-xsl \
        php5-ldap \
        php5-bcmath \
        php5-memcached \
        php5-apcu \
        php5-pgsql \
        php5-pdo_pgsql \

        # Nginx packages
        nginx \

        && \

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
        /etc/php5/php.ini && \

    echo "error_log = \"/proc/self/fd/2\"" | tee -a /etc/php5/php.ini

# Copy configs
COPY config/00_opcache.ini /etc/php5/conf.d/
COPY config/php-fpm.conf /etc/php5/
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

# Copy supervisor config
COPY config/supervisord.conf /etc/supervisord.conf

# Copy entrypoint
COPY docker-entrypoint.sh /

WORKDIR /var/www/moodle
VOLUME /var/www/moodle
EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
