# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.0-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
		a2enmod ssl; \
		a2enmod proxy; \
		a2enmod proxy_balancer; \
		a2enmod proxy_http; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
                echo '[mail function]' \
                echo 'SMTP = postfix-relay'; \
                echo 'smtp_port = 25'; \
                echo 'sendmail_from = postmaster@in.odahub.io'; \
                echo 'sendmail_path = /usr/sbin/sendmail -t -i'; \
	} > /usr/local/etc/php/conf.d/mail.ini

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
#ENV DRUPAL_VERSION 7.57
#ENV DRUPAL_MD5 44dec95a0ef56c4786785f575ac59a60

#RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
#	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
#	&& tar -xz --strip-components=1 -f drupal.tar.gz \
#	&& rm drupal.tar.gz \
#	&& chown -R www-data:www-data sites modules themes

RUN apt-get update
RUN apt-get install mysql-client -y

COPY drupal7-for-astrooda/ /var/www/astrooda

#ADD dist/less-7.x-4.0.tar.gz /var/www/astrooda/sites/all/modules/less

COPY httpd.conf /etc/apache2/apache2.conf

RUN chown www-data:www-data /var/www/astrooda/sites/default/files

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require drush/drush:7.*

RUN apt install ssl-cert

COPY default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

RUN curl -fSL https://ftp.drupal.org/files/projects/webform-7.x-4.18.tar.gz | tar xzvf - -C /var/www/astrooda/sites/all/modules
#RUN curl -fSL https://ftp.drupal.org/files/projects/webform-6.0.3.tar.gz | tar xzvf - -C /var/www/astrooda/sites/all/modules

ADD dev /var/www/astrooda/dev/

RUN apt-get install sendmail -y
#RUN apt-get install postfix -y
RUN apt-get install netcat -y

#COPY drupal7-db-for-astrooda/drupal7-db-for-astrooda.sql /drupal7-db-for-astrooda.sql
