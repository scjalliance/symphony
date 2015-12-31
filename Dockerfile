FROM php:5-apache

# Install packages and libraries
RUN apt-get update \
    && apt-get install -y \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libxslt1-dev \
        php5-gd \
        ssmtp \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        gd \
        mysqli \
        xsl \
        zip

# enable mod_rewrite
RUN a2enmod rewrite

# set upload limit
RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 50M;" >> /usr/local/etc/php/conf.d/uploads.ini

# set timezone
RUN touch /usr/local/etc/php/conf.d/timezone.ini \
    && echo "[Date]" >> /usr/local/etc/php/conf.d/timezone.ini \
    && echo "date.timezone = \"America/Los_Angeles\";" >> /usr/local/etc/php/conf.d/timezone.ini

# set ssmtp
RUN touch /usr/local/etc/php/conf.d/ssmtp.ini \
    && echo "[mail function]" >> /usr/local/etc/php/conf.d/ssmtp.ini \
    && echo "sendmail_path = /usr/sbin/ssmtp -t;" >> /usr/local/etc/php/conf.d/ssmtp.ini

RUN rm -rf /var/www/html

# Clone Symphony, its submodules and the sample workspace
RUN git clone git://github.com/symphonycms/symphony-2.git /var/www/html \
    && git checkout --track origin/bundle \
    && git submodule update --init --recursive \
    && git clone git://github.com/symphonycms/workspace.git \
    && chown -R www-data:www-data .
