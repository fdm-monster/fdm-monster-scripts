#!/bin/bash
# Convenience script to run all tests locally
# Usage: ./install/linux/test/run-tests.sh [--docker|--bats|--shellcheck|--all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "\n${YELLOW}===================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}===================================${NC}\n"
}

run_shellcheck() {
    print_header "Running Shellcheck"

    if ! command -v shellcheck &> /dev/null; then
        echo -e "${RED}shellcheck not found. Install it:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install shellcheck"
        echo "  macOS: brew install shellcheck"
        exit 1
    fi

    shellcheck "$ROOT_DIR/install/linux/install.sh" "$ROOT_DIR/install/linux/macvlan-setup.sh"
    echo -e "${GREEN}Shellcheck passed!${NC}"
}

run_bats() {
    print_header "Running Bats Unit Tests"

    if ! command -v bats &> /dev/null; then
        echo -e "${RED}bats not found. Install it:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install bats"
        echo "  macOS: brew install bats-core"
        echo "  Or: https://github.com/bats-core/bats-core"
        exit 1
    fi

    bats "$SCRIPT_DIR/install.bats"
    echo -e "${GREEN}Bats tests passed!${NC}"
}

run_docker() {
    print_header "Running Docker Integration Tests"

    if ! command -v docker &> /dev/null; then
        echo -e "${RED}docker not found. Install Docker first.${NC}"
        exit 1
    fi

    cd "$ROOT_DIR"

    # Build and run all test stages
    local targets=("test-normal" "test-custom-env" "test-chroot" "test-validation")

    for target in "${targets[@]}"; do
        echo -e "\n${YELLOW}Testing: $target${NC}"
        docker build -f install/linux/Dockerfile.test \
            --target "$target" \
            -t "fdm-monster-test-$target" .
        docker run --rm "fdm-monster-test-$target"
    done

    echo -e "${GREEN}Docker tests passed!${NC}"
}

# Parse command line arguments
case "${1:-all}" in
    --shellcheck)
        run_shellcheck
        ;;
    --bats)
        run_bats
        ;;
    --docker)
        run_docker
        ;;
    --all|*)
        run_shellcheck
        run_bats
        run_docker
        echo -e "\n${GREEN}===================================${NC}"
        echo -e "${GREEN}All tests passed!${NC}"
        echo -e "${GREEN}===================================${NC}\n"
        ;;
esac
