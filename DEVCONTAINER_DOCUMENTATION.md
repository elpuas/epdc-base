# Dev Container Documentation

## Overview

This WordPress development environment uses VS Code Dev Containers to provide a consistent, reproducible development setup. The container includes WordPress running on Apache with PHP 8.3, MariaDB database, Node.js 20, and all necessary development tools.

## Architecture

### Container Stack
- **Base**: `wordpress:php8.3-apache` Docker image
- **Database**: MariaDB (MySQL compatible)
- **Web Server**: Apache on port 8000
- **Runtime**: PHP 8.3 with WordPress optimizations
- **Build Tools**: Node.js 20, Composer, WP-CLI

### File Structure
```
.devcontainer/
├── devcontainer.json    # Main configuration
├── Dockerfile          # Container build instructions  
├── wp-setup.sh         # WordPress installation & setup
└── start-wp.sh         # Service startup script
```

## Component Analysis

### 1. devcontainer.json
**Purpose**: Defines the development container configuration for VS Code

**Key Functions**:
```jsonc
{
  "name": "WordPress",                    // Container display name
  "build": {                             // Container build configuration
    "dockerfile": "Dockerfile", 
    "context": "."
  },
  "forwardPorts": [8000, 3306],          // Expose WordPress and MySQL ports
  "workspaceFolder": "/workspaces/wp-content", // Maps repo to container path
  "settings": {                          // VS Code settings override
    "terminal.integrated.shell.linux": "/bin/bash",
    "php.suggest.basic": false           // Prevents duplicate PHP suggestions
  },
  "extensions": [                        // Auto-install VS Code extensions
    "felixfbecker.php-pack",            // PHP development tools
    "wordpresstoolbox.wordpress-toolbox", // WordPress specific tools
    "johnbillion.vscode-wordpress-hooks"  // WordPress hooks reference
  ],
  "postStartCommand": "...",             // Commands to run after container starts
  "remoteUser": "vscode"                 // Default user in container
}
```

**What It Does**:
- Sets up VS Code development environment
- Forwards localhost ports for web access
- Installs essential WordPress development extensions
- Configures PHP development settings
- Runs WordPress setup after container initialization

### 2. Dockerfile
**Purpose**: Builds the custom WordPress development container

**Installation Steps**:
```dockerfile
# Base WordPress image with PHP 8.3 and Apache
FROM wordpress:php8.3-apache

# System packages (curl, git, unzip, mariadb-server)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates git unzip mariadb-server mariadb-client

# Node.js 20 installation
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# WP-CLI installation (WordPress command line tool)
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp

# Composer installation (PHP dependency manager)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer
```

**User & Database Setup**:
```dockerfile
# vscode user with sudo access
RUN useradd -ms /bin/bash vscode \
    && usermod -aG www-data vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# MariaDB database creation
RUN service mariadb start \
    && mysql -e "CREATE DATABASE wordpress;" \
    && mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'wp_pass';" \
    && mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'localhost';"
```

**What It Does**:
- Creates complete LAMP stack (Linux, Apache, MySQL, PHP)
- Installs development tools (Node.js, Composer, WP-CLI)
- Configures database with WordPress-specific user
- Sets up proper file permissions for WordPress
- Creates vscode user with administrative privileges

### 3. wp-setup.sh
**Purpose**: Comprehensive WordPress installation and configuration script

**Configuration Variables**:
```bash
SITE_TITLE="Dev Site"              # WordPress site title
ADMIN_USER=admin                   # Admin username  
ADMIN_PASS=password               # Admin password (⚠️ Security concern)
ADMIN_EMAIL="admin@localhost.com" # Admin email
PLUGINS="advanced-custom-fields"  # Space-separated plugin list
WP_RESET=false                    # Whether to reset WordPress on rebuild
```

**Core Functions**:

1. **WordPress Core Download**:
   ```bash
   # Downloads WordPress if not present
   if [ ! -f wp-config-sample.php ]; then
       php -d memory_limit=512M /usr/local/bin/wp core download
       # Links user's wp-content directory
       sudo rm -rf wp-content && ln -s /workspaces/wp-content wp-content
   fi
   ```

2. **Apache Configuration**:
   ```bash
   # Configures Apache for port 8000
   echo "Listen 8000" | sudo tee -a /etc/apache2/ports.conf
   # Creates virtual host configuration
   sudo bash -c 'cat > /etc/apache2/sites-available/wordpress-8000.conf'
   ```

3. **Database Connection**:
   ```bash
   # Waits for database availability with retry logic
   for i in {1..10}; do
       if mysql -h localhost -u wp_user -pwp_pass -e "SELECT 1"; then
           break
       fi
       sleep 2
   done
   ```

4. **WordPress Installation**:
   ```bash
   # Creates wp-config.php and installs WordPress
   wp config create --dbhost="localhost:/run/mysqld/mysqld.sock" \
                   --dbname="wordpress" --dbuser="wp_user" --dbpass="wp_pass"
   wp core install --url="http://localhost:8000" --title="$SITE_TITLE" \
                  --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL"
   ```

5. **Plugin & Theme Management**:
   ```bash
   # Installs and activates specified plugins
   if [ -n "$PLUGINS" ]; then
       wp plugin install $PLUGINS --activate
   fi
   # Activates custom theme if available
   if [ -d "/workspaces/wp-content/themes/epdc-base" ]; then
       wp theme activate epdc-base
   fi
   ```

**What It Does**:
- Downloads and configures WordPress core
- Sets up Apache virtual host for port 8000
- Creates WordPress database connection
- Installs WordPress with specified admin credentials
- Activates plugins and themes
- Provides data import functionality
- Handles existing installations gracefully

### 4. start-wp.sh
**Purpose**: Service startup script with status feedback

**Functions**:
```bash
# Service startup
sudo service mariadb start    # Start database
sudo service apache2 restart # Start web server

# Health check
if curl -s --connect-timeout 5 http://localhost:8000 >/dev/null; then
    echo "✅ WordPress is responding!"
else
    echo "❌ WordPress is not responding. Check the logs:"
fi

# Theme activation
if [ -d "themes/epdc-base" ]; then
    wp theme activate epdc-base
fi
```

**What It Does**:
- Starts MariaDB and Apache services
- Tests WordPress connectivity
- Provides clear status feedback
- Activates custom theme
- Displays access URLs and credentials

## Workflow Integration

### Startup Sequence
1. **Container Build**: Dockerfile creates base environment
2. **VS Code Integration**: devcontainer.json configures editor
3. **Post-Start Command**: Runs `wp-setup.sh` automatically
4. **Service Health Check**: `start-wp.sh` validates setup

### Port Configuration
- **Port 8000**: WordPress website access
- **Port 3306**: MySQL database (internal only)
- **Auto-forwarding**: VS Code automatically forwards ports to localhost

### File System Mapping
```
Host: ./wp-content/              → Container: /workspaces/wp-content/
Container: /var/www/html         → WordPress root directory
Container: /var/www/html/wp-content → Symlink to /workspaces/wp-content
```

## Current Challenges & Areas for Improvement

###  Configuration Issues

1. **Port Mismatch**:
   ```bash
   # wp-setup.sh configures port 8000
   --url="http://localhost:8000"
   
   # But README.md mentions port 8080
   WordPress site: http://localhost:8080
   ```
   **Impact**: Documentation confusion, potential access issues
   **Solution**: Standardize on single port across all documentation

2. **Service Startup Race Condition**:
   ```bash
   postStartCommand: "sudo service mariadb start && sleep 5 && .devcontainer/wp-setup.sh"
   ```
   **Issue**: Fixed 5-second delay may not be sufficient
   **Impact**: Setup failures on slower systems
   **Current Mitigation**: wp-setup.sh has retry logic, but it's inconsistent

3. **Memory Limits**:
   ```bash
   php -d memory_limit=512M /usr/local/bin/wp core download
   ```
   **Issue**: Only applied to download command
   **Impact**: Potential memory issues with plugins/themes
   **Solution**: Set memory limits globally in PHP configuration

### 🟡 Reliability Issues

1. **Database Connection Errors**:
   ```bash
   # 10-attempt retry with 2-second delays
   for i in {1..10}; do
       if mysql -h localhost -u wp_user -pwp_pass -e "SELECT 1"; then
           break
       fi
       sleep 2
   done
   ```
   **Issue**: If database isn't ready after 20 seconds, setup continues anyway
   **Impact**: WordPress installation may fail silently

2. **No Error Handling for Critical Operations**:
   ```bash
   wp core install --url="http://localhost:8000" --title="$SITE_TITLE"
   # No check if installation succeeded
   ```
   **Impact**: Failed installations aren't detected

3. **File Permission Issues**:
   ```dockerfile
   RUN chown -R www-data:www-data /var/www/html/ \
       && chmod g+w -R /var/www/html/
   ```
   **Issue**: Permissions may not persist through volume mounts
   **Impact**: WordPress may not be able to write files

### 🟢 Performance Considerations

1. **Container Size**:
   - Multiple package installations without cleanup
   - Node.js installed but not optimized for WordPress
   - All tools installed regardless of usage

2. **Startup Time**:
   - Downloads WordPress core on every fresh container
   - Multiple service startups in sequence
   - Plugin installations during setup

3. **Development Workflow**:
   - No hot reloading for theme development
   - Manual theme activation required
   - No asset building integration

## Recommended Improvements

### Priority 1: Reliability Improvements
```bash
# Better error handling
if ! wp core install --url="http://localhost:8000" --title="$SITE_TITLE"; then
    echo "❌ WordPress installation failed!"
    exit 1
fi

# Health check functions
check_database_connection() {
    wp db check 2>/dev/null || return 1
}

check_wordpress_installation() {
    wp core is-installed 2>/dev/null || return 1
}
```

### Priority 2: Configuration Standardization
```jsonc
// Standardize ports in devcontainer.json
"forwardPorts": [8000, 3306],
"portsAttributes": {
    "8000": {
        "label": "WordPress Dev Site",
        "onAutoForward": "notify"
    }
}
```

### Priority 3: Performance Optimizations
```dockerfile
# Multi-stage build for smaller image size
FROM node:20-alpine AS node
FROM wordpress:php8.3-apache

# Copy only necessary Node.js components
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
```

## Best Practices for Usage

### Daily Development
1. Always use `composer dump-autoload` after adding PHP classes
2. Use `npm run start` for theme development with file watching
3. Access admin at http://localhost:8000/wp-admin (admin/password)

### Database Management
```bash
# Export database
wp db export backup.sql

# Import database 
wp db import backup.sql

# Reset database (⚠️ Destructive)
wp db reset --yes
```

### Plugin Development
```bash
# Install new plugin
composer require wpackagist-plugin/plugin-name

# Activate plugin
wp plugin activate plugin-name

# Check plugin status
wp plugin status
```

### Troubleshooting
```bash
# Check service status
sudo service apache2 status
sudo service mariadb status

# View logs
sudo tail -f /var/log/apache2/error.log
wp cli info

# Reset container (nuclear option)
# Rebuild container in VS Code: Ctrl+Shift+P > "Dev Containers: Rebuild Container"
```

## Conclusion

The current dev container setup provides a solid foundation for WordPress development with some areas for optimization around reliability and configuration. The modular script approach makes it maintainable and provides predictable credentials that enhance the developer experience.

The setup successfully provides:
- ✅ Consistent PHP 8.3 + WordPress environment
- ✅ Integrated development tools (Composer, WP-CLI, Node.js)
- ✅ VS Code integration with WordPress-specific extensions
- ✅ Local database with persistence

Key areas for optimization:
- 🟡 Reliability: Better error handling and service startup
- 🟡 Configuration: Port standardization and documentation  
- 🟢 Performance: Container optimization and faster startup

This documentation should be updated as improvements are implemented to maintain accuracy and usefulness for the development team.