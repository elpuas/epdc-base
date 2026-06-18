# WordPress `wp-content` Base Template

This repository versions the `wp-content` directory only.

WordPress core is provided inside the Dev Container and is not committed to this repository. On container startup, `/var/www/html/wp-content` is linked to this workspace so the running site uses the files in this repo.

## What Is Included

- PHP 8.3 on `wordpress:php8.3-apache`
- MariaDB running inside the Dev Container
- Node.js 20 for theme tooling
- Composer for PHP dependencies and quality tools
- WP-CLI for local WordPress management
- VS Code Dev Containers support

## What Is Not Included

- No `docker-compose.yml`
- No versioned WordPress core files
- No committed database dump or local database volume
- No automatic third-party plugin installation beyond what you add intentionally

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## First Run

1. Clone the repository.
2. Open the folder in VS Code.
3. Run `Dev Containers: Reopen in Container`.
4. Wait for the post-start setup to finish.
5. Open [http://localhost:8000](http://localhost:8000).

Default local credentials:

- Admin URL: `http://localhost:8000/wp-admin`
- Username: `admin`
- Password: `password`

The bootstrap script will:

- start MariaDB and Apache
- ensure WordPress core exists in `/var/www/html`
- link `/var/www/html/wp-content` to this repository
- create `wp-config.php` if needed
- install WordPress on first run
- activate the `epdc-base` theme when present

## Daily Development

Composer commands run from the repository root:

```bash
wp core version
wp user list
composer install
composer dump-autoload
composer run lint
composer run fix
composer run stan
composer run test
```

Theme tooling runs from the theme directory:

```bash
cd themes/epdc-base
npm install
npm run start
npm run build
```

Useful environment checks:

```bash
php -v
node -v
composer --version
wp --info
mysql --version
```

## Repository Rules

- Open the project in the Dev Container, not directly on the host machine.
- Do not commit WordPress core files.
- Do not commit local database files or ad hoc SQL exports.
- Use Composer for WordPress.org plugins when they should be part of the template.
- Run `composer dump-autoload` after adding PHP classes under `src/`.

## Template Notes

- The repository root is mounted under `/workspaces/<repository-name>`.
- Third-party plugins installed by Composer land in `plugins/`.
- Uploads are ignored by Git.
- If you want to preload a database, place `.sql` files in `.devcontainer/data/` before starting the container.
- If you need to reset the local site, set `WP_RESET=true` in [.devcontainer/wp-setup.sh](/Users/alfredonavas/WORDPRESS/epdc-base/.devcontainer/wp-setup.sh) and rebuild the container, then set it back to `false`.

## Troubleshooting

If the container builds but WordPress does not load:

1. Rebuild the container with `Dev Containers: Rebuild Container`.
2. Check Apache logs with `sudo tail -20 /var/log/apache2/error.log`.
3. Check MariaDB with `sudo service mariadb status`.
4. Confirm the workspace link with `ls -l /var/www/html/wp-content`.

If Composer or npm dependencies are missing, install them manually after the container starts. This template keeps dependency installation explicit rather than hiding it in container automation.
