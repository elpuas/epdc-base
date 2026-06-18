#!/bin/bash

set -euo pipefail

SITE_TITLE='Dev Site'
ADMIN_USER='admin'
ADMIN_PASS='password'
ADMIN_EMAIL='admin@localhost.com'
PLUGINS=''
WP_RESET=false
DEFAULT_THEME_SLUG='epdc-base'
WP_ROOT='/var/www/html'
DB_NAME='wordpress'
DB_USER='wp_user'
DB_PASS='wp_pass'
DB_SOCKET='/run/mysqld/mysqld.sock'
SITE_URL='http://localhost:8000'
SHOULD_IMPORT_SQL=false
DEVDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "$DEVDIR/.." >/dev/null 2>&1 && pwd)"
WP_CONTENT_SOURCE="$REPO_ROOT"

wait_for_database() {
	local attempt=1
	local max_attempts=30

	echo 'Waiting for MariaDB...'

	while [ "$attempt" -le "$max_attempts" ]; do
		if mysqladmin --socket="$DB_SOCKET" -u"$DB_USER" -p"$DB_PASS" ping --silent >/dev/null 2>&1; then
			echo 'MariaDB is ready.'
			return 0
		fi

		echo "MariaDB not ready yet (attempt $attempt/$max_attempts)"
		sleep 2
		attempt=$((attempt + 1))
	done

	echo 'MariaDB did not become ready in time.'
	return 1
}

ensure_wordpress_core() {
	if [ -f "$WP_ROOT/wp-load.php" ]; then
		echo 'WordPress core files are present.'
		return
	fi

	echo 'Downloading WordPress core files...'
	rm -rf /tmp/wp-download
	mkdir -p /tmp/wp-download

	wp core download --path=/tmp/wp-download
	cp -R /tmp/wp-download/. "$WP_ROOT/"
	rm -rf /tmp/wp-download
}

ensure_wp_content_link() {
	local target

	target="$(readlink -f "$WP_ROOT/wp-content" 2>/dev/null || true)"
	if [ "$target" = "$WP_CONTENT_SOURCE" ]; then
		echo 'wp-content is already linked to the workspace.'
		return
	fi

	echo 'Linking wp-content to the workspace...'
	sudo rm -rf "$WP_ROOT/wp-content"
	ln -s "$WP_CONTENT_SOURCE" "$WP_ROOT/wp-content"
}

configure_apache() {
	echo 'Configuring Apache for port 8000...'

	if ! grep -q '^Listen 8000$' /etc/apache2/ports.conf; then
		echo 'Listen 8000' | sudo tee -a /etc/apache2/ports.conf >/dev/null
	fi

	sudo tee /etc/apache2/sites-available/wordpress-8000.conf >/dev/null <<'EOF'
<VirtualHost *:8000>
	ServerName localhost
	DocumentRoot /var/www/html
	DirectoryIndex index.php

	<Directory /var/www/html>
		Options FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

	sudo a2ensite wordpress-8000 >/dev/null 2>&1
}

reset_wordpress() {
	if ! $WP_RESET; then
		echo 'Preserving existing WordPress installation.'
		return
	fi

	echo 'Resetting WordPress installation...'
	SHOULD_IMPORT_SQL=true

	if [ -f "$WP_ROOT/wp-config.php" ]; then
		wp db reset --yes --path="$WP_ROOT" 2>/dev/null || true
		sudo rm -f "$WP_ROOT/wp-config.php"
	fi

	if [ -n "$PLUGINS" ]; then
		wp plugin delete $PLUGINS --path="$WP_ROOT" 2>/dev/null || true
	fi
}

install_wordpress() {
	if [ -f "$WP_ROOT/wp-config.php" ]; then
		echo 'WordPress is already configured.'
		return
	fi

	echo 'Creating wp-config.php and installing WordPress...'
	SHOULD_IMPORT_SQL=true
	wp config create \
		--path="$WP_ROOT" \
		--dbhost="localhost:$DB_SOCKET" \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbpass="$DB_PASS" \
		--skip-check

	wp core install \
		--path="$WP_ROOT" \
		--url="$SITE_URL" \
		--title="$SITE_TITLE" \
		--admin_user="$ADMIN_USER" \
		--admin_password="$ADMIN_PASS" \
		--admin_email="$ADMIN_EMAIL" \
		--skip-email

	if [ -n "$PLUGINS" ]; then
		wp plugin install $PLUGINS --activate --path="$WP_ROOT"
	fi
}

import_sql_dumps() {
	if ! $SHOULD_IMPORT_SQL; then
		return
	fi

	if [ ! -d "$DEVDIR/data" ]; then
		return
	fi

	shopt -s nullglob
	local sql_files=("$DEVDIR"/data/*.sql)

	if [ "${#sql_files[@]}" -eq 0 ]; then
		shopt -u nullglob
		return
	fi

	echo 'Importing SQL dumps from .devcontainer/data...'
	for sql_file in "${sql_files[@]}"; do
		wp db import "$sql_file" --path="$WP_ROOT"
	done
	shopt -u nullglob
}

activate_theme() {
	if [ ! -d "$WP_CONTENT_SOURCE/themes/$DEFAULT_THEME_SLUG" ]; then
		return
	fi

	echo "Activating theme: $DEFAULT_THEME_SLUG"
	wp theme activate "$DEFAULT_THEME_SLUG" --path="$WP_ROOT" >/dev/null 2>&1 || true
}

echo 'Setting up WordPress...'

cd "$WP_ROOT"

ensure_wordpress_core
ensure_wp_content_link
configure_apache
wait_for_database
reset_wordpress
install_wordpress
import_sql_dumps
activate_theme
