#!/bin/bash
set -e

cd /var/www/html

# Set up wp directory
mkdir -p wp
cd wp

echo "Installing WordPress..."

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."

attempts=0
until mysqladmin ping -h"$WP_DB_HOST" -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" --silent; do
  attempts=$((attempts+1))
  if [ "$attempts" -gt 20 ]; then
    echo "MySQL did not become available after multiple attempts"
    exit 1
  fi
  echo "MySQL is unavailable - sleeping"
  sleep 2
done

echo "MySQL is ready."

# Download and install WordPress
if [ ! -f wp-config.php ]; then
  echo "WordPress not found, downloading and configuring..."

  # Download WordPress core files.
  php -d memory_limit=512M /usr/local/bin/wp core download

  # Create wp-config.php
  wp config create \
    --dbname="wordpress" \
    --dbuser="wpuser" \
    --dbpass="wppassword" \
    --dbhost="db"

  # Detect if running inside GitHub Codespaces
  if [ -n "$CODESPACE_NAME" ]; then
    export WP_URL="https://${CODESPACE_NAME}-80.app.github.dev/wp"
    echo "Detected Codespace. Using WP_URL: $WP_URL"

    # Add Codespaces HTTPS/proxy fix (should be before ABSPATH definition)
    sed -i '/\/\*\* Sets up WordPress vars and included files\. \*\//i \
if (isset($_SERVER["HTTP_X_FORWARDED_HOST"]) && isset($_SERVER["HTTP_X_FORWARDED_PROTO"])) {\n\
    $_SERVER["HTTP_HOST"] = $_SERVER["HTTP_X_FORWARDED_HOST"];\n\
    $_SERVER["HTTPS"] = $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https" ? "on" : "off";\n\
}\n' wp-config.php
  else
    export WP_URL="http://localhost/wp"
  fi

  echo "DEBUG: WP_URL is currently: $WP_URL"

  # Install WordPress
  wp core install \
    --url="$WP_URL" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email

else
  echo "WordPress wp-config.php already exists, skipping installation."
fi

echo "WordPress setup complete."