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
