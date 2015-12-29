FROM php:5-apache

# Install libxslt, zlib and Git
RUN apt-get update \
    && apt-get install -y \
        git \
        libxslt1-dev \
        ssmtp \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# enable mysqli, xsl and zlib PHP modules
RUN docker-php-ext-install \
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
