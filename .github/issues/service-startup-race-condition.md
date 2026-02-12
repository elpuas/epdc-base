# Service Startup Race Condition in Dev Container

## Issue Description
The current service startup sequence uses a fixed 5-second delay which may not be sufficient on slower systems, leading to setup failures.

## Current Behavior
```bash
postStartCommand: "sudo service mariadb start && sleep 5 && .devcontainer/wp-setup.sh"
```

## Problems
- Fixed 5-second delay may not be sufficient on slower hardware
- Setup failures occur when MariaDB isn't fully ready
- wp-setup.sh has retry logic, but it's inconsistent with the postStartCommand

## Impact
- Setup failures on slower development machines
- Inconsistent container initialization
- Developer frustration with failed container builds

## Proposed Solution
Replace fixed delay with proper service readiness checks:

```bash
# Wait for MariaDB to be fully ready
wait_for_mariadb() {
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if mysqladmin ping -h localhost --silent; then
            echo "MariaDB is ready!"
            return 0
        fi
        echo "Waiting for MariaDB... (attempt $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "MariaDB failed to start within expected time"
    return 1
}
```

## Acceptance Criteria
- [ ] Remove fixed `sleep 5` from postStartCommand
- [ ] Implement proper service readiness checks
- [ ] Ensure consistent startup on various hardware configurations
- [ ] Add timeout with clear error messages
- [ ] Test on slower development machines

## Files to Update
- [ ] `devcontainer.json` - Update postStartCommand
- [ ] `wp-setup.sh` - Improve database readiness checks
- [ ] Consider creating dedicated service startup script

## Labels
- `bug`
- `reliability`
- `devcontainer`

## Priority
High - Affects container reliability and developer productivity