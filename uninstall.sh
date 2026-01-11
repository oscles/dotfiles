#!/bin/bash

# Dotfiles Uninstallation Script
# This script removes symlinks created by stow

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

# Preview what will be removed
preview_removal() {
    print_header "Preview: What Will Be Removed"
    
    print_step "Running stow --dry-run -D to preview removal..."
    echo ""
    
    stow --dry-run --verbose -D . 2>&1 || true
    echo ""
}

# Uninstall all configurations
uninstall_all() {
    print_header "Uninstalling All Dotfiles"
    
    # Get list of directories
    local dirs=()
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            dirs+=("${dir%/}")
        fi
    done
    
    if [ ${#dirs[@]} -eq 0 ]; then
        print_warning "No configurations found to uninstall"
        return 0
    fi
    
    print_info "Found ${#dirs[@]} configuration(s) to uninstall: ${dirs[*]}"
    echo ""
    
    print_warning "This will remove all symlinks created by stow"
    print_warning "Your original configuration files will NOT be deleted"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Are you sure you want to continue? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
    
    echo ""
    
    for dir in "${dirs[@]}"; do
        print_step "Uninstalling $dir configuration..."
        
        if [ -d "$dir" ]; then
            if stow --verbose -D "$dir" 2>&1 | tee /tmp/stow_uninstall_output.log; then
                print_success "$dir configuration uninstalled"
            else
                print_error "Failed to uninstall $dir configuration"
                print_info "Check /tmp/stow_uninstall_output.log for details"
            fi
        else
            print_warning "$dir directory not found, skipping"
        fi
        echo ""
    done
    
    print_success "All dotfiles uninstalled successfully"
    echo ""
}

# Uninstall specific configuration
uninstall_specific() {
    local config="$1"
    
    if [ -z "$config" ]; then
        print_error "No configuration specified"
        return 1
    fi
    
    if [ ! -d "$config" ]; then
        print_error "Configuration directory '$config' not found"
        return 1
    fi
    
    print_header "Uninstalling $config Configuration"
    
    print_warning "This will remove symlinks for $config configuration"
    echo ""
    
    read -p "$(echo -e ${YELLOW}Are you sure you want to continue? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
    
    echo ""
    print_step "Uninstalling $config configuration..."
    
    if stow --verbose -D "$config"; then
        print_success "$config configuration uninstalled successfully"
    else
        print_error "Failed to uninstall $config configuration"
        return 1
    fi
    
    echo ""
}

# Main function
main() {
    print_header "Dotfiles Uninstallation Script"
    print_info "This script will remove symlinks created by stow"
    print_info "Your original files will NOT be deleted"
    echo ""
    
    check_stow
    echo ""
    
    # Preview removal if not skipping
    if [ "$1" != "--skip-preview" ] && [ "$1" != "--force" ]; then
        preview_removal
        echo ""
    fi
    
    if [ -n "$1" ] && [ "$1" != "--skip-preview" ] && [ "$1" != "--force" ]; then
        uninstall_specific "$1"
    else
        uninstall_all
    fi
    
    echo ""
    print_info "To reinstall, run: ./install.sh"
    echo ""
}

# Run main function
main "$@"
