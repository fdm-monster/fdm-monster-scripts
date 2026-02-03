# Testing the FDM Monster Installation Script

This directory contains tests for the FDM Monster installation script.

## Docker-based Integration Tests

The Docker tests validate the script in a realistic Linux environment.

### Running Docker Tests

```bash
# Build and run tests
docker build -f install/linux/Dockerfile.test -t fdm-monster-install-test .
docker run --rm fdm-monster-install-test

# Run specific test stages
docker build -f install/linux/Dockerfile.test --target test-validation -t fdm-monster-shellcheck .
docker run --rm fdm-monster-shellcheck
```

### Test Scenarios

1. **Normal Installation** - Validates basic script execution
2. **Custom Environment Variables** - Tests FDMM_HOME, FDMM_SERVICE_USER, etc.
3. **Chroot Simulation** - Tests FDMM_SERVICE_USER in chroot-like environments
4. **Static Analysis** - Runs shellcheck for code quality

## Unit Tests with Bats

Bats (Bash Automated Testing System) provides unit testing for individual functions and variables.

### Installing Bats

```bash
# On Ubuntu/Debian
sudo apt-get install bats

# On macOS
brew install bats-core

# Or install from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
```

### Running Unit Tests

```bash
# Run all tests
bats install/linux/test/install.bats

# Run with verbose output
bats -p install/linux/test/install.bats
```

### What's Tested

- Environment variable defaults and overrides
- CLI_VERSION constant
- SERVICE_USER configuration
- systemd service file generation
- Help and version flags

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test-install-script.yml`:

```yaml
name: Test Installation Script

on: [push, pull_request]

jobs:
  docker-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and test Docker
        run: |
          docker build -f install/linux/Dockerfile.test -t fdm-monster-install-test .
          docker run --rm fdm-monster-install-test

  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run shellcheck
        run: shellcheck install/linux/install.sh

  bats-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Bats
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      - name: Run Bats tests
        run: bats install/linux/test/install.bats
```

## Manual Testing Checklist

For full end-to-end testing on a real system:

- [ ] Fresh Ubuntu 22.04 installation
- [ ] Fresh Debian 12 installation
- [ ] Installation with default settings
- [ ] Installation with FDMM_HOME set
- [ ] Installation with FDMM_SERVICE_USER set
- [ ] Installation in chroot environment
- [ ] Service starts successfully
- [ ] CLI commands work (fdmm status, fdmm restart, etc.)
- [ ] Backup and restore functionality
- [ ] Uninstall removes all files

## Limitations

- Docker tests cannot fully validate systemd service functionality (requires privileged mode)
- Full integration testing requires a VM or real system
- Consider using Vagrant or LXC for more complete integration tests
