ARG APP_ENV=dev
ARG COMPOSER_CACHE_DIR=../composer-cache

#############################################################################
# stage inicial
#############################################################################

FROM siutoba/php:7.4-alpine-3 as src

RUN apk --no-cache add \
    git yarn php7-openssl php7-phar php7-tokenizer php7-dom


COPY . /usr/local/build

WORKDIR /usr/local/build

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN echo "preparar el proyecto" \
    && cp -R ./templates/app/instalacion instalacion \
    && cp ./templates/app/entorno_toba.env entorno_toba.env

RUN echo "eliminar archivos innecesarios para alivianar la imagen" \
    && find . -type d -name ".git" | xargs rm -rf
	
#############################################################################
# stage dev
#############################################################################

FROM siutoba/php:7.4-alpine-3 as dev

# Environments
ENV PHP_DISPLAY_ERRORS  On

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN apk --no-cache add \
    php7-pgsql \
    php7-soap \
    php7-ldap \
    php7-xsl \
    php7-mysqli \
    php7-bcmath \
    vim \
    php7-ctype \
    php7-xmlwriter \
    php7-fileinfo \
    php7-iconv \
    php7-xmlreader \
    git \
    yarn \
    apache2 \
    php7-iconv \
    openjdk8-jre \
    postgresql-client \
    graphviz \
    mc \
    subversion \    
    nano

RUN apk --no-cache add msttcorefonts-installer fontconfig && update-ms-fonts && fc-cache -f
COPY --chown=apache:apache --from=src /usr/local/build /usr/local/app

WORKDIR /usr/local/app/docker

RUN ls -lh /usr/local/app/docker

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

RUN echo "ajustes de apache" \
    # https://stackoverflow.com/a/56645177
    && sed -i 's/^Listen 80$/Listen 0.0.0.0:80/' /etc/apache2/httpd.conf \
    && cp /usr/local/app/templates/app/toba.conf /etc/apache2/conf.d/toba.conf
ENTRYPOINT [ "/entrypoint.sh" ]

#############################################################################
# stage final                                                               #
#############################################################################
FROM ${APP_ENV} as final

# Environments
ENV PHP_MEMORY_LIMIT    1024M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M
ENV PHP_MAX_INPUT_VARS  15000
ENV PHP_LOGS_ERRORS  On

# Set environments
RUN sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini
RUN sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /etc/php7/php.ini
RUN sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini
RUN sed -i "s|;*max_input_vars =.*|max_input_vars = ${PHP_MAX_INPUT_VARS}|i" /etc/php7/php.ini
RUN sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini
RUN sed -i "s|;*display_errors =.*|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php7/php.ini
RUN sed -i "s|;*log_errors =.*|log_errors = ${PHP_LOGS_ERRORS}|i" /etc/php7/php.ini

EXPOSE 80

CMD [ "--serve" ]

