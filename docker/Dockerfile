# TilBuci — all-in-one Docker image
#
# Ubuntu + Apache 2.4 + PHP 8 + MariaDB, fully self-contained. The container
# asks only for the administrator e-mail and the install mode on first run and
# then performs the installation automatically.
#
# Build context: the ./docker directory (which contains setup/ with the
# installer, the source of truth for the TilBuci version shipped here).

FROM ubuntu:24.04

# Image version. Override at build time with:
#   docker build --build-arg TILBUCI_VERSION=25.0 ...
ARG TILBUCI_VERSION=25.0

LABEL org.opencontainers.image.title="TilBuci" \
      org.opencontainers.image.description="All-in-one TilBuci image: Apache, PHP 8 and MariaDB with a headless, prompt-driven installer." \
      org.opencontainers.image.version="${TILBUCI_VERSION}" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.source="https://github.com/lucasjunqueira-var/tilbuci"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=C.UTF-8 \
    TILBUCI_ROOT=/var/www/tilbuci \
    TILBUCI_PUBLIC=/var/www/tilbuci/public_html \
    TILBUCI_INSTALLER=/opt/tilbuci-installer \
    TILBUCI_DATA_DIR=/data \
    TILBUCI_INSTALL_MODE=multi \
    TILBUCI_AUTO_INSTALL=true \
    TILBUCI_AUTO_UPDATE=true \
    TILBUCI_KEEP_SETUP=false

# ---------------------------------------------------------------------------
# System packages: web server, PHP and database.
# PHP ZIP support (php-zip -> ZipArchive) is mandatory: the installer extracts
# part1.zip/part2.zip/part3.zip and TilBuci imports/exports movies as ZIP.
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-php \
        mariadb-server \
        mariadb-client \
        php \
        php-cli \
        php-mysql \
        php-mbstring \
        php-zip \
        php-curl \
        php-xml \
        php-gd \
        php-intl \
        php-bcmath \
        php-imap \
        zip \
        unzip \
        curl \
        ca-certificates \
        tini \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# PHP configuration (Apache module and CLI).
# ---------------------------------------------------------------------------
COPY php/php.ini /etc/php/8.3/apache2/conf.d/99-tilbuci.ini
COPY php/php.ini /etc/php/8.3/cli/conf.d/99-tilbuci.ini

# ---------------------------------------------------------------------------
# Apache configuration.
# ---------------------------------------------------------------------------
COPY apache/tilbuci.conf /etc/apache2/sites-available/tilbuci.conf
RUN a2enmod rewrite headers \
    && a2dissite 000-default \
    && a2ensite tilbuci

# Fail the build early if ZIP support is missing.
RUN php -m | grep -qi '^zip$' \
    && php -r "if (!class_exists('ZipArchive')) { fwrite(STDERR, 'ZipArchive is missing'); exit(1); }" \
    && command -v zip >/dev/null \
    && command -v unzip >/dev/null

# ---------------------------------------------------------------------------
# Application tree and installer.
# ---------------------------------------------------------------------------
RUN mkdir -p /var/www/tilbuci/public_html

# Installer (source of truth: docker/setup) goes to the public web root...
COPY setup/ /var/www/tilbuci/public_html/
# ...and a pristine copy is kept outside the web root for future updates.
COPY setup/ /opt/tilbuci-installer/

# Entrypoint, helpers, installer wrapper, update tool and URL helper.
COPY bin/tilbuci-common.sh  /usr/local/bin/tilbuci-common.sh
COPY bin/install.php        /usr/local/bin/tilbuci-install.php
COPY bin/tilbuci-update     /usr/local/bin/tilbuci-update
COPY bin/tilbuci-set-url.php /usr/local/bin/tilbuci-set-url.php
COPY bin/tilbuci-set-url    /usr/local/bin/tilbuci-set-url
COPY docker-entrypoint.sh   /usr/local/bin/docker-entrypoint.sh
COPY supervisord.conf       /etc/supervisor/conf.d/tilbuci.conf

RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/tilbuci-update /usr/local/bin/tilbuci-set-url

# ---------------------------------------------------------------------------
# MariaDB data directory inside the persistent volume.
# ---------------------------------------------------------------------------
RUN rm -rf /var/lib/mysql && ln -s /data/mysql /var/lib/mysql

# Ownership.
RUN chown -R www-data:www-data /var/www/tilbuci /opt/tilbuci-installer

EXPOSE 80
VOLUME ["/data"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD curl -sS -o /dev/null http://localhost/ || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
