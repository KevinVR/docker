FROM php:7.2-fpm

LABEL vendor="MyBB Team"
LABEL version="1.9.0"
LABEL maintainer="Kane Valentine <kane@cute.im>"

# install some tools for debugging within the container if needed
RUN set -ex; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends \
		git \
		vim \
		curl \
		patch

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libmemcached-dev \
		libpng-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j$(nproc) gd mysqli opcache pgsql; \
	\
	pecl channel-update pecl.php.net; \
	pecl install memcached; \
	docker-php-ext-enable memcached; \
	\
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

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
                echo 'file_uploads=On'; \
                echo 'upload_max_filesize=10M'; \
                echo 'post_max_size=10M'; \
                echo 'max_execution_time=20'; \
                echo 'memory_limit=256M'; \
        } > /usr/local/etc/php/conf.d/mybb-recommended.ini

ENV MYBB_VERSION 190

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
