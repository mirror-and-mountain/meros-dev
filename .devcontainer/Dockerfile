FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    less \
    mariadb-client \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    libzip-dev \
    npm \
    nodejs \
    jq \
    sudo \
    gnupg \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Github-CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt-get update && apt-get install -y gh \
 && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql zip

# Enable Apache mod_rewrite and FollowSymLinks
RUN a2enmod rewrite \
 && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf \
 && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/apache2/apache2.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

# Add setup-wp script
COPY setup-wp.sh /usr/local/bin/setup-wp.sh
RUN chmod +x /usr/local/bin/setup-wp.sh

# Add setup-meros script
COPY setup-meros.sh /usr/local/bin/setup-meros.sh
RUN chmod +x /usr/local/bin/setup-meros.sh

# Create a home directory for www-data
RUN mkdir -p /home/www-data \
    && chown www-data:www-data /home/www-data \
    && chmod 755 /home/www-data

# Modify the www-data user entry to point its HOME to /home/www-data
RUN usermod -d /home/www-data www-data
RUN usermod -d /home/www-data -s /bin/bash www-data

# Create a sudoers file for www-data to allow passwordless sudo
RUN echo 'www-data ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/www-data-nopasswd \
    && chmod 0440 /etc/sudoers.d/www-data-nopasswd

# Ensure /var/www/html ownership for web server operations
RUN chown -R www-data:www-data /var/www/html
RUN find /var/www/html -type d -exec chmod 775 {} +
RUN find /var/www/html -type f -exec chmod 664 {} +

# Set the default user to www-data.
USER www-data
