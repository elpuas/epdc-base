--------------------------------------------------
AGENT
--------------------------------------------------
  
  You are an expert in WordPress, PHP, and related web development technologies.
  
  Key Principles
  - Write concise, technical responses with accurate PHP examples.
  - Follow WordPress coding standards and best practices.
  - Use object-oriented programming when appropriate, focusing on modularity.
  - Prefer iteration and modularization over duplication.
  - Use descriptive function, variable, and file names.
  - Use lowercase with hyphens for directories (e.g., wp-content/themes/my-theme).
  - Favor hooks (actions and filters) for extending functionality.
  
  PHP/WordPress
  - Use PHP 7.4+ features when appropriate (e.g., typed properties, arrow functions).
  - Follow WordPress PHP Coding Standards.
  - Use strict typing when possible: declare(strict_types=1);
  - Utilize WordPress core functions and APIs when available.
  - File structure: Follow WordPress theme and plugin directory structures and naming conventions.
  - Implement proper error handling and logging:
    - Use WordPress debug logging features.
    - Create custom error handlers when necessary.
    - Use try-catch blocks for expected exceptions.
  - Use WordPress's built-in functions for data validation and sanitization.
  - Implement proper nonce verification for form submissions.
  - Utilize WordPress's database abstraction layer (wpdb) for database interactions.
  - Use prepare() statements for secure database queries.
  - Implement proper database schema changes using dbDelta() function.
  
  Dependencies
  - WordPress (latest stable version)
  - Composer for dependency management (when building advanced plugins or themes)
  
  WordPress Best Practices
  - Use WordPress hooks (actions and filters) instead of modifying core files.
  - Implement proper theme functions using functions.php.
  - Use WordPress's built-in user roles and capabilities system.
  - Utilize WordPress's transients API for caching.
  - Implement background processing for long-running tasks using wp_cron().
  - Use WordPress's built-in testing tools (WP_UnitTestCase) for unit tests.
  - Implement proper internationalization and localization using WordPress i18n functions.
  - Implement proper security measures (nonces, data escaping, input sanitization).
  - Use wp_enqueue_script() and wp_enqueue_style() for proper asset management.
  - Implement custom post types and taxonomies when appropriate.
  - Use WordPress's built-in options API for storing configuration data.
  - Implement proper pagination using functions like paginate_links().
  
  Key Conventions
  1. Follow WordPress's plugin API for extending functionality.
  2. Use WordPress's template hierarchy for theme development.
  3. Implement proper data sanitization and validation using WordPress functions.
  4. Use WordPress's template tags and conditional tags in themes.
  5. Implement proper database queries using $wpdb or WP_Query.
  6. Use WordPress's authentication and authorization functions.
  7. Implement proper AJAX handling using admin-ajax.php or REST API.
  8. Use WordPress's hook system for modular and extensible code.
  9. Implement proper database operations using WordPress transactional functions.
  10. Use WordPress's WP_Cron API for scheduling tasks.
  


--------------------------------------------------
SECTION 1 — Repository Overview
--------------------------------------------------
- This repository is the `wp-content` directory only.
- WordPress core is not versioned here; it is bootstrapped automatically in the Dev Container and linked to this repo’s `wp-content`.
- Development depends on the Dev Container for a consistent environment.

--------------------------------------------------
SECTION 2 — Development Environment Rules
--------------------------------------------------
- The repository MUST be opened using the Dev Container.
- Do not assume local PHP, MySQL, or Node installations.
- All work must assume PHP 8.3 and Node 20 as provided by the Dev Container.

--------------------------------------------------
SECTION 3 — Git Workflow Rules
--------------------------------------------------
Branching:
- Always branch off `main`.
- Branch naming convention (lowercase, hyphen-separated, no spaces):
  - `feature/<short-description>`
  - `fix/<short-description>`
  - `chore/<short-description>`
  - `refactor/<short-description>`
- Avoid vague names like `update` or `changes`.

Commits:
- Use conventional commits:
  - `feat: add block registration`
  - `fix: correct meta query`
  - `chore: update dependencies`
  - `refactor: improve service structure`
- Keep commits atomic.
- No multi-purpose commits.
- Do not include unrelated file changes.

Pull Requests:
- Describe what changed.
- Describe why.
- List commands executed if relevant.

--------------------------------------------------
SECTION 4 — Allowed Commands
--------------------------------------------------
Composer (root):
- `composer install`
- `composer require`
- `composer run lint`
- `composer run fix`
- `composer run stan`
- `composer run test`

Node (theme tooling):
- `npm install`
- `npm run start`
- `npm run build`

Rules:
- Run `composer dump-autoload` when adding PHP classes.
- Never modify lock files unless dependency changes are intentional.
- Never manually download plugins.
- Always use Composer (WPackagist) for plugins.

--------------------------------------------------
SECTION 5 — Coding Standards
--------------------------------------------------
PHP:
- WordPress Coding Standards (WPCS) via PHPCS.
- Short array syntax.
- Prefer namespaced plugin architecture.
- Avoid global function pollution.
- No direct DB queries without preparation.

JavaScript:
- ES6+.
- `const`/`let` only.
- Explicit ternary expressions.
- No `var`.
- Use `@wordpress/scripts` tooling only.

Formatting:
- Tabs.
- No semicolons.
- Single quotes.

--------------------------------------------------
SECTION 6 — Safety Rules
--------------------------------------------------
The agent must never:
- Modify Dev Container configuration unless explicitly instructed.
- Add Docker Compose if not present.
- Install global packages.
- Introduce new tooling without approval.
- Change project structure.
