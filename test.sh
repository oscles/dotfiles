#!/bin/bash

# Dotfiles Testing Script
# This script tests the dotfiles installation without making any changes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Functions
print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}→${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${MAGENTA}ℹ${NC} $1"
}

# Check if stow is installed
check_stow() {
    if ! command -v stow >/dev/null 2>&1; then
        print_error "GNU Stow is not installed"
        print_info "Install it with: brew install stow"
        exit 1
    fi
    print_success "GNU Stow is installed"
}

# Test all configurations
test_all() {
    print_header "Testing All Configurations"
    
    print_step "Running stow --dry-run --verbose on all configurations..."
    echo ""
    
    if stow --dry-run --verbose .; then
        echo ""
        print_success "Dry-run test completed successfully"
        print_info "No changes were made to your system"
    else
        echo ""
        print_error "Dry-run test encountered issues"
        return 1
    fi
}

# Test specific configuration
test_specific() {
    local config="$1"
    
    if [ -z "$config" ]; then
        print_error "No configuration specified"
        return 1
    fi
    
    if [ ! -d "$config" ]; then
        print_error "Configuration directory '$config' not found"
        return 1
    fi
    
    print_header "Testing $config Configuration"
    
    print_step "Running stow --dry-run --verbose on $config..."
    echo ""
    
    if stow --dry-run --verbose "$config"; then
        echo ""
        print_success "Dry-run test for $config completed successfully"
    else
        echo ""
        print_error "Dry-run test for $config encountered issues"
        return 1
    fi
}

# List available configurations
list_configs() {
    print_header "Available Configurations"
    
    local configs=()
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            configs+=("${dir%/}")
        fi
    done
    
    if [ ${#configs[@]} -eq 0 ]; then
        print_warning "No configurations found"
        return 0
    fi
    
    print_info "Found ${#configs[@]} configuration(s):"
    for config in "${configs[@]}"; do
        echo "  • $config"
    done
    echo ""
}

# Main function
main() {
    print_header "Dotfiles Testing Script"
    print_info "This script tests the dotfiles installation without making changes"
    echo ""
    
    check_stow
    echo ""
    
    if [ "$1" == "--list" ] || [ "$1" == "-l" ]; then
        list_configs
        exit 0
    fi
    
    if [ -n "$1" ]; then
        test_specific "$1"
    else
        test_all
    fi
    
    echo ""
    print_info "To install these configurations, run: ./install.sh"
    echo ""
}

# Run main function
main "$@"
