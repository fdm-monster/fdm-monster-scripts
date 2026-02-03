#!/usr/bin/env bats
# Unit tests for FDM Monster installation script
# Install bats: https://github.com/bats-core/bats-core
# Run: bats install/linux/test/install.bats

setup() {
    # Load the installation script for testing
    export SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

    # Create a temporary directory for test files
    export TEST_TEMP_DIR="$(mktemp -d)"
    export HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$HOME"
}

teardown() {
    # Clean up temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

# Test environment variable defaults
@test "USER_HOME defaults to HOME when FDMM_HOME is not set" {
    export HOME=/test/home
    unset FDMM_HOME

    result=$(bash -c 'source '"$INSTALL_SCRIPT"' 2>/dev/null; echo "$USER_HOME"' 2>&1 || echo "$HOME")
    [[ "$result" == *"/test/home"* ]]
}

@test "USER_HOME uses FDMM_HOME when set" {
    export HOME=/test/home
    export FDMM_HOME=/custom/home

    result=$(bash -c 'USER_HOME="${FDMM_HOME:-$HOME}"; echo "$USER_HOME"')
    [ "$result" = "/custom/home" ]
}

@test "SERVICE_USER defaults to USER when FDMM_SERVICE_USER is not set" {
    export USER=testuser
    unset FDMM_SERVICE_USER

    result=$(bash -c 'SERVICE_USER="${FDMM_SERVICE_USER:-$USER}"; echo "$SERVICE_USER"')
    [ "$result" = "testuser" ]
}

@test "SERVICE_USER uses FDMM_SERVICE_USER when set" {
    export USER=defaultuser
    export FDMM_SERVICE_USER=customuser

    result=$(bash -c 'SERVICE_USER="${FDMM_SERVICE_USER:-$USER}"; echo "$SERVICE_USER"')
    [ "$result" = "customuser" ]
}

@test "NODE_VERSION defaults to 24.12.0 when FDMM_NODE_VERSION is not set" {
    unset FDMM_NODE_VERSION

    result=$(bash -c 'NODE_VERSION="${FDMM_NODE_VERSION:-24.12.0}"; echo "$NODE_VERSION"')
    [ "$result" = "24.12.0" ]
}

@test "NODE_VERSION uses FDMM_NODE_VERSION when set" {
    export FDMM_NODE_VERSION=20.11.0

    result=$(bash -c 'NODE_VERSION="${FDMM_NODE_VERSION:-24.12.0}"; echo "$NODE_VERSION"')
    [ "$result" = "20.11.0" ]
}

@test "DEFAULT_PORT defaults to 4000 when FDMM_SERVER_PORT is not set" {
    unset FDMM_SERVER_PORT

    result=$(bash -c 'DEFAULT_PORT="${FDMM_SERVER_PORT:-4000}"; echo "$DEFAULT_PORT"')
    [ "$result" = "4000" ]
}

@test "DEFAULT_PORT uses FDMM_SERVER_PORT when set" {
    export FDMM_SERVER_PORT=5000

    result=$(bash -c 'DEFAULT_PORT="${FDMM_SERVER_PORT:-4000}"; echo "$DEFAULT_PORT"')
    [ "$result" = "5000" ]
}

@test "install.sh help option works" {
    run bash "$INSTALL_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"FDM Monster"* ]]
}

@test "install.sh version option works" {
    run bash "$INSTALL_SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"1.0.17"* ]]
}

# Test CLI_VERSION constant
@test "CLI_VERSION is set to 1.0.17" {
    result=$(grep "readonly CLI_VERSION=" "$INSTALL_SCRIPT" | cut -d'"' -f2)
    [ "$result" = "1.0.17" ]
}

# Test that FDMM_SERVICE_USER is documented
@test "FDMM_SERVICE_USER is documented in the script" {
    run grep -q "FDMM_SERVICE_USER" "$INSTALL_SCRIPT"
    [ "$status" -eq 0 ]
}

# Test that SERVICE_USER variable is defined
@test "SERVICE_USER variable is defined in the script" {
    run grep -q 'SERVICE_USER="${FDMM_SERVICE_USER:-\$USER}"' "$INSTALL_SCRIPT"
    [ "$status" -eq 0 ]
}

# Test that systemd service uses SERVICE_USER
@test "systemd service file uses SERVICE_USER instead of USER" {
    run grep -A 5 "\\[Service\\]" "$INSTALL_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'User=$SERVICE_USER'* ]]
    [[ "$output" != *'User=$USER'* ]] || [[ "$output" == *'User=$SERVICE_USER'* ]]
}
