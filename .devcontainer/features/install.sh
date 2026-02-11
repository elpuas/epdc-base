#!/usr/bin/env bash
set -e

EPDC_DIR="/usr/local/share/epdc-wp"
mkdir -p "$EPDC_DIR"

apt-get update

# MariaDB + tooling
apt-get install -y \
	mariadb-server \
	mariadb-client \
	curl \
	unzip \
	less \
	lsof

# WP-CLI
curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp

# Xdebug (PHP 8.3)
apt-get install -y php-pear php8.3-dev make gcc
printf "\n" | pecl install xdebug || true

XDEBUG_SO="$(php -r "echo ini_get('extension_dir');")/xdebug.so"
if [ -f "$XDEBUG_SO" ]; then
	cat > /etc/php/8.3/cli/conf.d/99-xdebug.ini <<'INI'
zend_extension=xdebug.so
xdebug.mode=debug,develop
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.log_level=0
INI
fi

# Scripts that make everything "1 click"
cat > "$EPDC_DIR/epdc-start.sh" <<'SH'
#!/usr/bin/env bash
set -e

WP_PATH="/workspaces/$(basename "$PWD")/wp"

# Start MariaDB (safe to run repeatedly)
service mariadb start >/dev/null 2>&1 || true

# Start PHP built-in server if not running
PORT=8000
if ! lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
	if [ -d "$WP_PATH" ]; then
		nohup php -S 0.0.0.0:$PORT -t "$WP_PATH" >/tmp/php-server.log 2>&1 &
	fi
fi
SH
chmod +x "$EPDC_DIR/epdc-start.sh"

cat > "$EPDC_DIR/epdc-init.sh" <<'SH'
#!/usr/bin/env bash
set -e

WORKSPACE="/workspaces/$(basename "$PWD")"
WP_PATH="$WORKSPACE/wp"
DB_NAME="wordpress"
DB_USER="root"
DB_PASS=""
DB_HOST="127.0.0.1"

# Ensure DB is up
service mariadb start >/dev/null 2>&1 || true

# Create DB if missing
mysql -h"$DB_HOST" -u"$DB_USER" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" || true

# Bootstrap WP once
if [ ! -f "$WP_PATH/wp-load.php" ]; then
	mkdir -p "$WP_PATH"
	wp core download --path="$WP_PATH" --allow-root

	wp config create \
		--path="$WP_PATH" \
		--dbname="$DB_NAME" \
		--dbuser="$DB_USER" \
		--dbhost="$DB_HOST" \
		--skip-check \
		--allow-root

	wp core install \
		--path="$WP_PATH" \
		--url="http://localhost:8000" \
		--title="EPDC Dev" \
		--admin_user="admin" \
		--admin_password="admin" \
		--admin_email="admin@example.com" \
		--allow-root
fi

# Link repo wp-content into wp install
if [ -d "$WORKSPACE/wp-content" ]; then
	rm -rf "$WP_PATH/wp-content"
	ln -s "$WORKSPACE/wp-content" "$WP_PATH/wp-content"
fi

echo ""
echo "-------------------------------------------"
echo "WordPress ready"
echo "URL: http://localhost:8000"
echo "User: admin"
echo "Password: admin"
echo "-------------------------------------------"
echo ""
SH
chmod +x "$EPDC_DIR/epdc-init.sh"