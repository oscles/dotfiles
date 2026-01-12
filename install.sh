#!/bin/bash

# Dotfiles Installation Script
# This script installs dotfiles using GNU Stow and manages Homebrew packages

set -e  # Exit on error

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Setup Homebrew PATH after installation
setup_homebrew_path() {
    # Detect architecture and Homebrew path
    if [[ -d "/opt/homebrew/bin" ]]; then
        # Apple Silicon (M1/M2/M3)
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d "/usr/local/bin" ]]; then
        # Intel Mac
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Verify brew is available, if not try shellenv
    if ! command_exists brew; then
        # Try to evaluate Homebrew's shellenv script
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_deps=()
    
    if ! command_exists brew; then
        print_error "Homebrew is not installed"
        missing_deps+=("homebrew")
    else
        print_success "Homebrew is installed"
        print_info "Homebrew version: $(brew --version | head -n1)"
    fi
    
    if ! command_exists stow; then
        print_warning "GNU Stow is not installed"
        missing_deps+=("stow")
    else
        print_success "GNU Stow is installed"
        print_info "Stow version: $(stow --version | head -n1)"
    fi
    
    # Check Oh My Zsh (required for zsh configuration)
    if [ -d "zsh" ]; then
        if [ -d "$HOME/.oh-my-zsh" ]; then
            print_success "Oh My Zsh is installed"
        else
            print_warning "Oh My Zsh is not installed"
            missing_deps+=("ohmyzsh")
        fi
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_header "Installing Missing Dependencies"
        
        if [[ " ${missing_deps[@]} " =~ " homebrew " ]]; then
            print_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            print_success "Homebrew installed"
            
            # Add Homebrew to PATH
            setup_homebrew_path
            print_info "Homebrew added to PATH"
        fi
        
        if [[ " ${missing_deps[@]} " =~ " stow " ]]; then
            print_step "Installing GNU Stow..."
            brew install stow
            print_success "GNU Stow installed"
        fi
        
        if [[ " ${missing_deps[@]} " =~ " ohmyzsh " ]]; then
            print_step "Installing Oh My Zsh..."
            if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
                print_success "Oh My Zsh installed successfully"
            else
                print_error "Failed to install Oh My Zsh"
                print_info "You can install it manually: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
            fi
        fi
    fi
    
    echo ""
}

# Test stow installation (dry-run)
test_stow() {
    print_header "Testing Stow Installation (Dry Run)"
    
    print_step "Running stow -n (simulation) to preview changes..."
    echo ""
    
    # Check for conflicts first
    local has_conflicts=false
    if stow -n --verbose . 2>&1 | grep -q "existing target.*since neither a link nor a directory"; then
        has_conflicts=true
        print_warning "Existing files detected that will conflict"
        print_info "The installation will use --adopt to backup and replace them"
        echo ""
    fi
    
    if stow -n --verbose . 2>&1 | grep -q "LINK:"; then
        print_success "Stow simulation completed successfully"
        print_info "Review the output above to see what will be installed"
        echo ""
        
        read -p "$(echo -e ${YELLOW}Do you want to continue with the installation? [y/N]: ${NC})" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Installation cancelled by user"
            exit 0
        fi
    else
        print_warning "No new symlinks to create (files may already be installed)"
    fi
    
    echo ""
}

# Install dotfiles with stow
install_dotfiles() {
    print_header "Installing Dotfiles"
    
    # Clean system files before installation
    print_step "Cleaning system files (.DS_Store)..."
    find . -name ".DS_Store" -type f -delete 2>/dev/null || true
    print_success "System files cleaned"
    echo ""
    
    # Get list of directories to stow
    local dirs=()
    for dir in */; do
        if [ -d "$dir" ] && [ "$dir" != ".git/" ]; then
            dirs+=("${dir%/}")
        fi
    done
    
    if [ ${#dirs[@]} -eq 0 ]; then
        print_error "No directories found to install"
        return 1
    fi
    
    print_info "Found ${#dirs[@]} configuration(s) to install: ${dirs[*]}"
    echo ""
    
    for dir in "${dirs[@]}"; do
        print_step "Installing $dir configuration..."
        
        if [ -d "$dir" ]; then
            # First check for conflicts using simulation
            print_info "Checking for existing files..."
            local has_conflicts=false
            if stow -n --verbose "$dir" 2>&1 | grep -q "existing target.*since neither a link nor a directory"; then
                has_conflicts=true
                print_warning "Existing files detected for $dir configuration"
                print_info "Using --adopt to backup and replace existing files..."
            fi
            
            # Install with --adopt if conflicts detected, otherwise normal install
            if [ "$has_conflicts" = true ]; then
                if stow --adopt --verbose "$dir" 2>&1 | tee /tmp/stow_output.log; then
                    print_success "$dir configuration installed (existing files backed up)"
                    print_info "Original files were backed up in the dotfiles directory"
                    
                    # Clean up cache and temporary files that might have been adopted
                    print_step "Cleaning up cache and temporary files..."
                    find "$dir" -type f \( -name "*.log" -o -name "*.cache" -o -name "state.vscdb" \) -delete 2>/dev/null || true
                    find "$dir" -type d \( -name "Cache" -o -name "CachedData" -o -name "workspaceStorage" -o -name "logs" -o -name "History" -o -name "CachedExtensions" -o -name "CachedExtensionVSIXs" -o -name "globalStorage" -o -name "snippets" \) -exec rm -rf {} + 2>/dev/null || true
                    print_success "Cache files cleaned"
                else
                    print_error "Failed to install $dir configuration even with --adopt"
                    print_info "Check /tmp/stow_output.log for details"
                    return 1
                fi
            else
                if stow --verbose "$dir" 2>&1 | tee /tmp/stow_output.log; then
                    print_success "$dir configuration installed"
                else
                    print_error "Failed to install $dir configuration"
                    print_info "Check /tmp/stow_output.log for details"
                    return 1
                fi
            fi
        else
            print_warning "$dir directory not found, skipping"
        fi
        echo ""
    done
    
    print_success "All dotfiles installed successfully"
    echo ""
}

# Install Homebrew packages
install_homebrew_packages() {
    print_header "Installing Homebrew Packages"
    
    if [ ! -f "Brewfile" ]; then
        print_warning "Brewfile not found, skipping Homebrew installation"
        return 0
    fi
    
    print_step "Installing packages from Brewfile..."
    print_info "This may take a while depending on your internet connection"
    print_info "If some packages fail, the installation will continue..."
    echo ""
    
    # Temporarily disable exit on error for brew bundle
    set +e
    brew bundle install
    local bundle_exit_code=$?
    set -e
    
    if [ $bundle_exit_code -eq 0 ]; then
        print_success "All Homebrew packages installed successfully"
    else
        print_warning "Some Homebrew packages may have failed to install"
        print_info "This is normal - some packages may already be installed or unavailable"
        print_info "You can run 'brew bundle' manually later to retry failed packages"
        print_info "Continuing with the rest of the installation..."
    fi
    
    echo ""
    return 0
}

# Apply system preferences
apply_system_preferences() {
    if [ ! -f "system-preferences.sh" ]; then
        print_warning "system-preferences.sh not found, skipping system preferences"
        return 0
    fi
    
    print_header "Applying System Preferences"
    print_step "Configuring macOS system preferences..."
    echo ""
    
    if bash system-preferences.sh; then
        print_success "System preferences applied successfully"
    else
        print_warning "Some system preferences may not have been applied"
        print_info "You can run './system-preferences.sh' manually to retry"
    fi
    
    echo ""
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --apps-only        Install only Homebrew packages (skip dotfiles)"
    echo "  --skip-test        Skip dry-run test before installation"
    echo "  --help, -h         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                 # Full installation with prompts"
    echo "  $0 --apps-only     # Install only Homebrew packages"
    echo "  $0 --skip-test    # Skip dry-run test"
}

# Main installation function
main() {
    # Check for help flag
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    # Check for apps-only flag
    if [[ "$1" == "--apps-only" ]]; then
        print_header "Homebrew Packages Installation"
        print_info "This script will install only Homebrew packages from Brewfile"
        print_info "Script location: $SCRIPT_DIR"
        echo ""
        
        # Check prerequisites (only Homebrew needed)
        if ! command_exists brew; then
            print_error "Homebrew is not installed"
            print_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            print_success "Homebrew installed"
            
            # Add Homebrew to PATH
            setup_homebrew_path
            print_info "Homebrew added to PATH"
        else
            print_success "Homebrew is installed"
            print_info "Homebrew version: $(brew --version | head -n1)"
        fi
        
        echo ""
        
        # Install Homebrew packages
        if [ -f "Brewfile" ]; then
            # Temporarily disable exit on error
            set +e
            install_homebrew_packages
            local install_result=$?
            set -e
            
            # Final summary
            print_header "Installation Complete!"
            if [ $install_result -eq 0 ]; then
                print_success "Homebrew packages installation completed"
            else
                print_warning "Homebrew packages installation completed with some warnings"
            fi
            echo ""
            print_info "Installed packages include:"
            echo "  • Applications (Cursor, Docker, Slack, Brave, etc.)"
            echo "  • CLI Tools (git, fnm, pnpm, pyenv)"
            echo "  • Fonts (JetBrains Mono, Zed Mono)"
            echo "  • VS Code/Cursor extensions"
            echo ""
        else
            print_error "Brewfile not found"
            exit 1
        fi
        
        return 0
    fi
    
    # Normal installation flow
    print_header "Dotfiles Installation Script"
    print_info "This script will install your dotfiles using GNU Stow"
    print_info "Script location: $SCRIPT_DIR"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Ask if user wants to test first
    if [ "$1" != "--skip-test" ]; then
        read -p "$(echo -e ${YELLOW}Do you want to run a dry-run test first? [Y/n]: ${NC})" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            test_stow
        fi
    fi
    
    # Install dotfiles
    install_dotfiles
    
    # Ask about Homebrew packages
    if [ -f "Brewfile" ]; then
        read -p "$(echo -e ${YELLOW}Do you want to install Homebrew packages? [Y/n]: ${NC})" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # Temporarily disable exit on error to continue even if some packages fail
            set +e
            install_homebrew_packages
            set -e
        else
            print_info "Skipping Homebrew package installation"
            print_info "You can run 'brew bundle' later to install packages"
        fi
    fi
    
    # Apply system preferences
    apply_system_preferences
    
    # Final summary
    print_header "Installation Complete!"
    print_success "Your dotfiles have been installed successfully"
    echo ""
    print_info "Next steps:"
    echo "  • Restart your terminal or run: source ~/.zshrc"
    echo "  • Configure any application-specific settings"
    echo "  • Review installed configurations"
    echo ""
    print_info "To uninstall, run: stow -D ."
    echo ""
}

# Run main function
main "$@"
