#!/bin/bash

# Ensure script runs with appropriate permissions
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Change to the directory where your application is located
cd /path/to/your/application || exit 1

# Install Composer (if not already installed)
if [ ! -f /usr/local/bin/composer ]; then
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --quiet
    RESULT=$?
    rm composer-setup.php

    if [ $RESULT -ne 0 ]; then
        >&2 echo 'ERROR: Composer installation failed'
        exit 1
    fi

    mv composer.phar /usr/local/bin/composer
fi

# Install Composer dependencies
echo "Installing Composer dependencies..."
COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --optimize-autoloader

# Check the exit code of the last command (composer install)
if [ $? -ne 0 ]; then
    >&2 echo "ERROR: Composer dependencies installation failed"
    exit 2
fi

echo "Composer dependencies installed successfully"
exit 0

