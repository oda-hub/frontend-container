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

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
#ENV DRUPAL_VERSION 7.57
#ENV DRUPAL_MD5 44dec95a0ef56c4786785f575ac59a60

#RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
#	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
#	&& tar -xz --strip-components=1 -f drupal.tar.gz \
#	&& rm drupal.tar.gz \
#	&& chown -R www-data:www-data sites modules themes


#ENV PATH="$HOME/.config/composer/vendor/bin:$PATH"
RUN apt-get update
RUN apt-get install mysql-client -y

COPY astrooda_drupal7.tar.gz /astrooda_drupal7.tar.gz
RUN mkdir -pv /var/www/astrooda &&\
    tar xvzf  /astrooda_drupal7.tar.gz --wildcards --strip 1 -C /var/www/astrooda drupal7/*

ADD drupal-7.59.tar.gz /drupal-7.59
	
RUN apt-get install -y --no-install-recommends rsync
RUN rsync -avu /drupal-7.59/drupal-7.59/ /var/www/astrooda/drupal7/

COPY libraries.tar.gz /libraries.tar.gz
RUN tar xvzf  /libraries.tar.gz -C /var/www/astrooda/sites/all/ && \
    tar xvzf  /libraries.tar.gz -C /var/www/astrooda/sites/default


COPY modules_astrooda /var/www/astrooda/sites/all/modules/astrooda

COPY drupal7_sites_default_settings.php /var/www/astrooda/sites/default/settings.php

RUN ls -l /var/www/astrooda
RUN ls -l /var/www/astrooda/sites/all/libraries
RUN ls -l /var/www/astrooda/sites/default/libraries
RUN ls -l /var/www/astrooda/sites/all/modules/astrooda

#COPY drupal7/ /var/www/astrooda

#RUN apt-get update
#RUN cd /var/www/astrooda; drush cc all

COPY httpd.conf /etc/apache2/apache2.conf




#ADD datatables-7.x-1.2.tar.gz /var/www/astrooda/sites/all/modules/
#ADD DataTables-1.9.3.tgz /var/www/astrooda/sites/all/modules/datatables/
#RUN cd /var/www/astrooda/sites/all/modules/datatables/; mv DataTables-1.9.3 dataTables

COPY drupal7-astrooda /var/www/astrooda/sites/all/modules/astrooda
RUN ls -l /var/www/astrooda/sites/all/modules/astrooda

#RUN apt-get install git -y
#RUN git clone git@gitlab.astro.unige.ch:cdci/astrooda.git drupal7/sites/all/modules/astrooda

# vim:set ft=dockerfile:

RUN chmod -R 777 /var/www/astrooda/sites/default/files 

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global require drush/drush:7.* 

ADD ctools-7.x-1.14.tar.gz  /var/www/astrooda/sites/all/modules/ctools/
