# from https://www.drupal.org/requirements/php#drupalversions
FROM php:7.4.33-apache

# PHP 7.4 is EOL: rebuild it from the PHP security team's source backport of
# CVE-2026-109618/CVE-2026-109619 (https://www.php.net/archive/2026.php, 2026-10-21)
ENV PHP_SRC_COMMIT=712e60f9edfd03f0960fc4fc3c2c375f42b90aa2
ENV PHP_SRC_SHA256=c85c8cae6cd97c8688eb0bb2385d2341b74606153d19c3c8688183c3bc760d47

# Debian bullseye is EOL: its packages moved from deb/security.debian.org to archive.debian.org
RUN sed -i \
	-e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' \
	-e 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' \
	/etc/apt/sources.list

# rebuild PHP (CLI + mod_php) from the backport source with the base image's configure options,
# and make it the source docker-php-ext-install uses for our extensions
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		autoconf bison re2c dpkg-dev file g++ gcc libc-dev make pkg-config xz-utils \
		apache2-dev libargon2-dev libcurl4-openssl-dev libonig-dev libreadline-dev \
		libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev \
	; \
	\
	configureOptions="$(php-config --configure-options)"; \
	curl -fsSL "https://github.com/php/php-src/archive/${PHP_SRC_COMMIT}.tar.gz" -o /tmp/php-src.tar.gz; \
	echo "${PHP_SRC_SHA256} */tmp/php-src.tar.gz" | sha256sum -c -; \
	mkdir -p /usr/src/php-backport; \
	tar -xzf /tmp/php-src.tar.gz -C /usr/src/php-backport --strip-components=1; \
	\
	cd /usr/src/php-backport; \
	./buildconf --force; \
	export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"; \
	./configure $configureOptions; \
	make -j "$(nproc)"; \
	make install; \
	make distclean; \
	\
	cd /usr/src; \
	rm -f php.tar.xz php.tar.xz.asc; \
	tar -cJf php.tar.xz php-backport; \
	rm -rf php-backport /tmp/php-src.tar.gz; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

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
                libzip-dev \
	; \
	\
	docker-php-ext-configure gd --with-jpeg; \
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

RUN apt-get update
RUN apt-get install -y default-mysql-client

COPY mmoda-frontend-drupal /var/www/mmoda

#ADD dist/less-7.x-4.0.tar.gz /var/www/mmoda/sites/all/modules/less

COPY httpd.conf /etc/apache2/apache2.conf

RUN mkdir -pv /var/www/mmoda/sites/default/files && \
    chown www-data:www-data /var/www/mmoda/sites/default/files

# Composer pinned; drush 7 needs symfony/yaml 2.x (EOL), whose security advisories Composer blocks by default:
# exempt only that package
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer global config --json policy.advisories.ignore '["symfony/yaml"]' && \
    composer global require drush/drush:7.*

RUN apt install ssl-cert

COPY default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

RUN curl -fSL https://ftp.drupal.org/files/projects/webform-7.x-4.18.tar.gz | tar xzvf - -C /var/www/mmoda/sites/all/modules
RUN curl -fSL https://ftp.drupal.org/files/projects/swiftmailer-7.x-1.7.tar.gz | tar xzvf - -C /var/www/mmoda/sites/all/modules

ADD dev /var/www/mmoda/dev/


ADD mmoda-frontend-drupal/sites/default/files/ /frontend-default-files/

RUN cd /var/www/mmoda && composer require --no-security-blocking "swiftmailer/swiftmailer:^5.0"

#RUN apt-get install netcat -y
