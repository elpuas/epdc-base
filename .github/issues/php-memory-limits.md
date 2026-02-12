# PHP Memory Limits Not Applied Globally

## Issue Description
PHP memory limits are only applied to specific commands (like WordPress core download) but not set globally, which can cause issues with plugins and themes that require more memory.

## Current Behavior
```bash
# Memory limit only applied to core download
php -d memory_limit=512M /usr/local/bin/wp core download
```

## Problems
- Memory limit only applies to the single WP-CLI command
- Plugins and themes may hit default PHP memory limits during development
- Inconsistent memory allocation across different operations
- No global PHP memory configuration

## Impact
- Potential memory exhaustion errors during plugin installation
- Theme compilation failures
- Inconsistent behavior across different WordPress operations
- Developer confusion when memory limits vary by operation

## Proposed Solution
Set PHP memory limits globally in the container configuration:

### Option 1: Update php.ini
```dockerfile
# In Dockerfile
RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/memory.ini
```

### Option 2: Environment Variable
```dockerfile
# In Dockerfile  
ENV PHP_MEMORY_LIMIT=512M
```

### Option 3: Apache PHP Configuration
```apache
# In virtual host configuration
php_admin_value memory_limit "512M"
```

## Acceptance Criteria
- [ ] Set global PHP memory limit to 512M (or configurable value)
- [ ] Remove individual memory limit overrides from scripts
- [ ] Test with memory-intensive plugins/themes
- [ ] Document memory configuration in DEVCONTAINER_DOCUMENTATION.md
- [ ] Ensure memory limits persist across container restarts

## Files to Update
- [ ] `Dockerfile` - Add global PHP memory configuration
- [ ] `wp-setup.sh` - Remove individual memory overrides
- [ ] `.devcontainer/devcontainer.json` - Consider environment variables
- [ ] Documentation updates

## Testing
- [ ] Install memory-intensive plugins (e.g., page builders)
- [ ] Test theme compilation with large asset files
- [ ] Verify memory limits with `php -i | grep memory_limit`

## Labels
- `enhancement`
- `configuration`
- `php`
- `performance`

## Priority
Medium - Prevents potential memory-related issues during development