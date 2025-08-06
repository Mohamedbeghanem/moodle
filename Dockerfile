FROM php:8.1-apache

# Install dependencies — including libicu-dev for 'intl'
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    # PHP extension deps
    libonig-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libxml2-dev \
    libicu-dev \
    # Build tools
    gcc \
    g++ \
    make \
    autoconf \
    pkg-config \
    # For Composer
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache & PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo_mysql \
        gd \
        zip \
        intl \
        mbstring \
    && a2enmod rewrite \
    && a2enmod headers

# Set working directory
WORKDIR /var/www/html

# Copy Moodle source
COPY src/ /var/www/html/

# Fix permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Create moodledata
RUN mkdir -p /var/www/moodledata && \
    chown -R www-data:www-data /var/www/moodledata && \
    chmod 777 /var/www/moodledata

EXPOSE 80

CMD ["apache2-foreground"]