FROM php:8.0.5-fpm-alpine3.13

# Install dependencies
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpng-dev \
#     libjpeg62-turbo-dev \
#     libfreetype6-dev \
#     locales \
#     zip \
#     jpegoptim optipng pngquant gifsicle \
#     vim \
#     unzip \
#     git \
#     curl

# Clear cache
# RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#check system info
RUN cat /etc/os-release

# Install extensions
RUN docker-php-ext-install pdo pdo_mysql
RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-install zip

# # Install Composer  
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Change Directory
WORKDIR /var/www

# Copy composer.json and composer-lock.json
# Cz volume was mounting (merging) after the image built successfully. So, we need to copying the composer.json when installing depedency on build process
COPY ./src/composer.json ./src/composer.lock ./

# Composer command here
# RUN composer install
# RUN composer install --no-scripts --no-autoloader

# COPY ./src .
# RUN chmod +x artisan

# RUN composer dump-autoload --optimize

# DIGITAL OCEAN
# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY ../../src /var/www

# Copy existing application directory permissions
COPY --chown=www:www ../../src /var/www

# Change current user to www
USER www

# Composer command here
RUN composer install --no-scripts --no-autoloader
RUN php artisan migrate:fresh --seed
RUN composer dump-autoload --optimize

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]