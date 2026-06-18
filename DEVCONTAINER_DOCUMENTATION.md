# Dev Container Documentation

## Overview

This repository is a `wp-content` template, not a full WordPress installation.

The Dev Container provides:

- `wordpress:php8.3-apache` as the base runtime
- MariaDB inside the same container
- Node.js 20
- Composer
- WP-CLI

The running WordPress root is `/var/www/html`. The repository is mounted at `/workspaces/<repository-name>`, and the bootstrap script links `/var/www/html/wp-content` to that workspace path.

## Files

```text
.devcontainer/
├── devcontainer.json
├── Dockerfile
├── start-wp.sh
└── wp-setup.sh
```

## Startup Flow

`postStartCommand` runs [.devcontainer/start-wp.sh](/Users/alfredonavas/WORDPRESS/epdc-base/.devcontainer/start-wp.sh), which:

1. starts MariaDB
2. starts Apache
3. runs [.devcontainer/wp-setup.sh](/Users/alfredonavas/WORDPRESS/epdc-base/.devcontainer/wp-setup.sh)
4. reloads Apache
5. verifies that `http://localhost:8000` responds

## Bootstrap Flow

[.devcontainer/wp-setup.sh](/Users/alfredonavas/WORDPRESS/epdc-base/.devcontainer/wp-setup.sh) is intentionally idempotent. It:

1. confirms WordPress core exists in `/var/www/html`
2. replaces the image’s default `wp-content` directory with a symlink to the mounted repository root
3. configures Apache to listen on port `8000`
4. waits for MariaDB readiness instead of using a fixed sleep
5. creates `wp-config.php` only when needed
6. installs WordPress only on first run
7. activates the template theme when present
8. optionally imports `.sql` files from `.devcontainer/data/`

## Runtime Defaults

- Site URL: `http://localhost:8000`
- Admin username: `admin`
- Admin password: `password`
- Database name: `wordpress`
- Database user: `wp_user`
- Database password: `wp_pass`
- PHP memory limit: `512M`

## Design Choices

- No `docker-compose.yml`: the setup stays compatible with standard VS Code Dev Containers using a single Dockerfile.
- No committed WordPress core: the base image owns `/var/www/html`, while Git owns only `wp-content`.
- No automatic dependency installation for Composer or npm: setup stays explicit and predictable for template consumers.
- No default third-party plugin installation: the base template should not silently mutate local state beyond WordPress bootstrap.

## Known Constraints

- MariaDB runs in the same container as Apache and PHP. That is acceptable for a local template, but it is not meant to mirror production topology.
- The bootstrap script uses fixed local credentials for convenience. Change them if you derive a stricter internal template from this repo.
- Composer-managed plugins are installed into `plugins/`, which is ignored by Git in this base template.

## Verification Commands

Run these inside the Dev Container:

```bash
wp core version
php -v
node -v
composer --version
wp --info
mysql --version
ls -l /var/www/html/wp-content
```

Expected result for the last command:

```text
/var/www/html/wp-content -> /workspaces/<repository-name>
```
