#!/bin/bash

set -euo pipefail

echo 'Starting WordPress development environment...'

sudo service mariadb start
sudo service apache2 start >/dev/null 2>&1 || sudo service apache2 restart >/dev/null 2>&1

.devcontainer/wp-setup.sh

sudo service apache2 reload >/dev/null 2>&1 || sudo service apache2 restart >/dev/null 2>&1

if curl -fsS --connect-timeout 5 http://localhost:8000 >/dev/null; then
	echo 'WordPress is ready.'
	echo 'Site: http://localhost:8000'
	echo 'Admin: http://localhost:8000/wp-admin'
	echo 'Username: admin'
	echo 'Password: password'
else
	echo 'WordPress did not respond on http://localhost:8000.'
	echo 'Check Apache logs with: sudo tail -20 /var/log/apache2/error.log'
	exit 1
fi
