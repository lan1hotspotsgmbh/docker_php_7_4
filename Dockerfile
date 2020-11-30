FROM php:7.4-fpm-alpine
RUN apk add -U --no-cache libpng-dev libmcrypt-dev unixodbc-dev libxml2-dev libzip-dev build-base autoconf \
    && apk add --no-cache oniguruma-dev libmcrypt-dev autoconf g++ gcc make build-base libmcrypt-dev bzip2-dev curl-dev libxml2-dev libjpeg-turbo-dev libpng-dev krb5-dev imap-dev icu-dev openldap-dev libmcrypt-dev unixodbc-dev libxml2-dev libzip-dev libxslt-dev net-snmp-dev libwebp-dev libxpm-dev freetds-dev freetype-dev sqlite-dev imagemagick-dev \
    && docker-php-ext-configure gd --with-xpm --with-webp --with-jpeg --with-freetype \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure ldap \
    && docker-php-ext-configure hash --with-mhash \
    && docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr \
    && docker-php-ext-install -j$(nproc) exif bcmath bz2 calendar ctype curl dba gd pdo  pdo_mysql mysqli pdo_odbc xml json zip fileinfo ftp iconv imap intl mbstring  opcache session snmp simplexml soap sockets xmlrpc  xmlwriter \
    && docker-php-ext-enable mbstring \
    && export CFLAGS="-I/usr/src/php" \
    && docker-php-ext-install -j$(nproc) xmlreader xmlwriter pdo_sqlite \
    && pecl install mcrypt \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable mysqli \
    && pecl install imagick \
    && pecl install -o -f redis \
    && docker-php-ext-enable imagick \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable redis \
    && pecl install radius-1.4.0b1 && docker-php-ext-enable radius \
    \
    && pecl clear-cache \
    && docker-php-source delete \
    && rm -rf /tmp/pear \
    && apk del --purge autoconf g++ make build-base .build-deps \
    && rm -rf /var/cache/apk/* /usr/src/* /tmp/* /usr/lib/php/build \
    \
    && wget https://getcomposer.org/download/2.0.7/composer.phar -O /usr/local/bin/composer \
    && chmod 777 /usr/local/bin/composer \
    && { \
      echo '[PHP]\ndate.timezone = "Europe/Berlin"'; \
    } > /usr/local/etc/php/conf.d/tzone.ini \
    && { \
      echo '[PHP]\nmemory_limit=1G'; \
    } > /usr/local/etc/php/conf.d/memory-limit.ini \
    && wget https://browscap.org/stream?q=Full_PHP_BrowsCapINI -O /usr/local/etc/php/php_browscap.ini \
    && { \
          echo '[browscap]'; \
          echo 'browscap = "/usr/local/etc/php/php_browscap.ini"'; \
    } > /usr/local/etc/php/conf.d/browscap.ini \
    && { \
      echo '[Session]'; \
      echo 'session.save_handler = files'; \
      echo 'session.use_strict_mode = 0'; \
      echo 'session.use_cookies = 1'; \
      echo 'session.cookie_secure = 1'; \
      echo 'session.use_only_cookies = 1'; \
      echo 'session.name = PHPSESSID'; \
      echo 'session.auto_start = 0'; \
      echo 'session.cookie_lifetime = 0'; \
      echo 'session.cookie_path = /'; \
      echo 'session.cookie_domain ='; \
      echo 'session.cookie_httponly ='; \
      echo 'session.serialize_handler = php'; \
      echo 'session.gc_probability = 1'; \
      echo 'session.gc_divisor = 1000'; \
      echo 'session.gc_maxlifetime = 30000'; \
      echo 'session.referer_check ='; \
      echo 'session.cache_limiter = nocache'; \
      echo 'session.cache_expire = 180'; \
      echo 'session.use_trans_sid = 0'; \
      echo 'session.hash_function = 0'; \
      echo 'session.hash_bits_per_character = 5'; \
      echo 'url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"'; \
  } > /usr/local/etc/php/conf.d/session.ini \
  && { \
      echo '[global]'; \
      echo 'include=etc/php-fpm.d/*.conf'; \
      } > /usr/local/etc/php-fpm.conf \
  && { \
      echo '[www]'; \
      echo 'user = www-data'; \
      echo 'group = www-data'; \
      echo 'listen = 127.0.0.1:9000'; \
      echo ''; \
      echo 'pm = dynamic'; \
      echo 'pm.max_children = 40'; \
      echo 'pm.start_servers = 15'; \
      echo 'pm.min_spare_servers = 15'; \
      echo 'pm.max_spare_servers = 25'; \
      echo 'pm.process_idle_timeout = 10s'; \
      echo 'pm.max_requests = 500'; \
      } > /usr/local/etc/php-fpm.d/www.conf

USER www-data
