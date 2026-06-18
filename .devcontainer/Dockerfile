FROM wordpress:php8.3-apache

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system packages including MariaDB server
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
		ca-certificates \
		git \
		unzip \
		mariadb-server \
		mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
	&& apt-get install -y --no-install-recommends nodejs \
	&& rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer \
	&& rm composer-setup.php

# Development-friendly PHP defaults.
RUN printf "memory_limit=512M\nupload_max_filesize=64M\npost_max_size=64M\n" > /usr/local/etc/php/conf.d/devcontainer.ini

# Add vscode user and give sudo access
RUN useradd -ms /bin/bash vscode \
	&& usermod -aG www-data vscode \
	&& apt-get update \
	&& apt-get install -y sudo \
	&& echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& rm -rf /var/lib/apt/lists/*

# Setup MariaDB
RUN service mariadb start \
	&& mysql -e "CREATE DATABASE wordpress;" \
	&& mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';" \
	&& mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';" \
	&& mysql -e "FLUSH PRIVILEGES;" \
	&& service mariadb stop

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html/ \
	&& chmod g+w -R /var/www/html/ \
	&& find /var/www/html/ -type d -exec chmod g+s {} \;

# Create a startup script that starts both services
RUN echo '#!/bin/bash\nservice mariadb start\napache2-foreground' > /usr/local/bin/start-services.sh \
	&& chmod +x /usr/local/bin/start-services.sh

CMD ["/usr/local/bin/start-services.sh"]
