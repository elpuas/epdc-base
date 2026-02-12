# WordPress Development Environment

This repository contains the `wp-content` directory for WordPress development using a Dev Container setup. WordPress core is not versioned here but is automatically bootstrapped in the Dev Container.

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code

## Getting Started

### 1. Open in Dev Container

**⚠️ Important: This repository MUST be opened using the Dev Container for proper functionality.**

1. Clone this repository
2. Open VS Code
3. Open the project folder in VS Code
4. When prompted, click "Reopen in Container" or use the command palette:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Dev Containers: Reopen in Container"
   - Select the command

The dev container will automatically:
- Set up PHP 8.3 and Node 20
- Install WordPress core
- Configure MySQL database
- Link this `wp-content` directory to the WordPress installation

### 2. Access Your Site

Once the container is running:
- **WordPress site**: http://localhost:8000
- **Database**: Available internally to the container
- **File system**: Your `wp-content` changes are automatically synced

## Development Commands

### Composer (PHP Dependencies & Tools)

```bash
# Install PHP dependencies
composer install

# Add new dependencies
composer require vendor/package

# Refresh autoloader (run after adding new PHP classes)
composer dump-autoload

# Code quality tools
composer run lint    # Check PHP code style
composer run fix     # Fix PHP code style issues
composer run stan    # Run PHPStan static analysis
composer run test    # Run PHPUnit tests
```

### Node.js (Theme Development)

```bash
# Navigate to your theme directory first
cd themes/your-theme-name

# Install dependencies
npm install

# Development mode (watch files)
npm run start

# Production build
npm run build
```

## Project Structure

```
wp-content/
├── src/              # Custom EPDC namespaced PHP classes
├── plugins/          # WordPress plugins (managed via Composer)
├── themes/           # Custom themes
├── uploads/          # Media uploads
├── composer.json     # PHP dependencies and scripts
├── vendor/           # Composer dependencies
└── README.md         # This file
```

## Development Workflow

### Branching Strategy

Always branch off `main` using the naming convention:

```bash
# Feature branches
git checkout -b feature/short-description

# Bug fixes
git checkout -b fix/short-description

# Maintenance tasks
git checkout -b chore/short-description

# Code refactoring
git checkout -b refactor/short-description
```

### Commit Messages

Use conventional commits:

```bash
feat: add new block registration
fix: correct meta query syntax
chore: update dependencies
refactor: improve service structure
```

### Adding Plugins

**Never manually download plugins.** Use Composer via WPackagist:

```bash
# Add a plugin from the WordPress repository
composer require wpackagist-plugin/plugin-name

# Example: Adding Contact Form 7
composer require wpackagist-plugin/contact-form-7
```

### Custom PHP Classes

Store your custom namespaced PHP classes in the `src/` directory using the `EPDC\` namespace:

```php
<?php
namespace EPDC;

class MyService {
    public function init(): void {
        // Your code here
    }
}
```

After adding new classes, refresh the autoloader:

```bash
composer dump-autoload
```

### Code Standards

#### PHP
- Follow WordPress Coding Standards (WPCS)
- Use short array syntax: `[]` instead of `array()`
- Prefer namespaced architecture
- Avoid global function pollution
- Always prepare database queries

#### JavaScript
- Use ES6+ features
- Use `const`/`let` only (no `var`)
- Single quotes for strings
- No semicolons
- Use `@wordpress/scripts` tooling

#### Formatting
- Use tabs for indentation
- Single quotes for strings
- No trailing semicolons

## Troubleshooting

### Container Won't Start
1. Ensure Docker Desktop is running
2. Try rebuilding the container:
   - Command palette: "Dev Containers: Rebuild Container"

### WordPress Site Not Loading
1. Check that port 8080 isn't in use by another application
2. Restart the dev container

### Permission Issues
- The dev container handles file permissions automatically
- If you encounter issues, try rebuilding the container

## Important Notes

- **Never modify** Dev Container configuration files unless explicitly instructed
- **Don't install** global packages or tools outside the container
- **Always use** the provided Composer and npm commands
- **Never commit** `vendor/` or `node_modules/` directories (they're in `.gitignore`)

## Support

For development environment issues:
1. Check this README first
2. Verify you're using the Dev Container
3. Try rebuilding the container
4. Check the project's issue tracker

---

Happy coding! 🚀