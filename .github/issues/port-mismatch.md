# Port Configuration Mismatch Between Scripts and Documentation

## Issue Description
There's an inconsistency between the port configured in the setup scripts and what's documented in the README.md file.

## Current Behavior
- `wp-setup.sh` configures WordPress for port 8000:
  ```bash
  --url="http://localhost:8000"
  ```
- `README.md` documents port 8080:
  ```markdown
  WordPress site: http://localhost:8080
  ```

## Impact
- Documentation confusion for new developers
- Potential access issues when following README instructions
- Inconsistent developer experience

## Expected Behavior
All documentation and configuration should reference the same port consistently.

## Proposed Solution
1. Standardize on port 8000 (current working port)
2. Update README.md to reflect correct port
3. Ensure all documentation references port 8000

## Files to Update
- [ ] `README.md` - Update WordPress site URL
- [ ] Any other documentation mentioning port 8080
- [ ] Verify `devcontainer.json` port forwarding matches

## Labels
- `bug`
- `documentation`
- `good first issue`

## Priority
Medium - Affects developer onboarding and documentation accuracy