# Dotfiles

Personal dotfiles configuration for macOS, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Installation Scripts](#installation-scripts)
- [Testing with Stow](#testing-with-stow)
- [Structure](#structure)
- [Configuration Details](#configuration-details)
- [Maintenance](#maintenance)

## 🎯 Overview

This repository contains configuration files for various tools and applications:

- **Shell**: Zsh configuration with Oh My Zsh
- **Git**: Git configuration with conditional includes
- **Cursor**: Editor settings and extensions
- **Claude Desktop**: AI assistant configuration
- **SSH**: SSH configuration files
- **Homebrew**: Complete list of applications, fonts, and VS Code/Cursor extensions

## 📦 Prerequisites

Before installing these dotfiles, ensure you have:

1. **macOS** (tested on macOS Sonoma and later)
2. **Homebrew** installed:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. **GNU Stow** installed:
   ```bash
   brew install stow
   ```

## 🚀 Installation

### Quick Install

1. Clone this repository:
   ```bash
   git clone <your-repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Install all configurations:
   ```bash
   stow .
   ```

   This will symlink all configuration files to their appropriate locations in your home directory.

### Selective Installation

To install only specific configurations:

```bash
# Install only Git configuration
stow git

# Install only Zsh configuration
stow zsh

# Install multiple configurations
stow git zsh cursor
```

### Install Homebrew Packages

After installing the dotfiles, install all Homebrew packages and applications:

```bash
brew bundle
```

This will install:
- Command-line tools (git, fnm, pnpm, pyenv)
- Applications (Cursor, Docker, Slack, Brave, etc.)
- Fonts (JetBrains Mono, Zed Mono)
- VS Code/Cursor extensions

### Post-Installation Setup

After installing the dotfiles, you may need to configure API keys for some applications:

**Claude Desktop API Keys:**
1. Edit the configuration file:
   ```bash
   nano ~/Library/Application Support/Claude/claude_desktop_config.json
   ```
2. Replace the placeholder values:
   - `YOUR_CONTEXT7_API_KEY_HERE` → Your Context7 API key
   - `YOUR_NOTION_TOKEN_HERE` → Your Notion integration token
3. Restart Claude Desktop

See the [Claude Desktop Configuration](#claude-desktop-configuration) section for more details.

## 🛠️ Installation Scripts

This repository includes convenient installation scripts that provide colored output and interactive prompts to guide you through the installation process.

### Installation Script (`install.sh`)

The main installation script automates the entire setup process:

```bash
./install.sh
```

**Features:**
- ✅ Checks and installs prerequisites (Homebrew, GNU Stow)
- 🧪 Optional dry-run test before installation
- 📦 Installs all dotfiles configurations
- 🍺 Optionally installs Homebrew packages
- 🎨 Colored terminal output with progress indicators
- ⚠️ Interactive prompts for confirmation

**Options:**
```bash
# Skip the dry-run test
./install.sh --skip-test
```

**What it does:**
1. Checks if Homebrew and Stow are installed (installs them if missing)
2. Optionally runs a dry-run test to preview changes
3. Installs all dotfiles configurations using Stow
4. Optionally installs all Homebrew packages from Brewfile
5. Provides a summary of what was installed

### Testing Script (`test.sh`)

Test your dotfiles installation without making any changes:

```bash
# Test all configurations
./test.sh

# Test a specific configuration
./test.sh git
./test.sh zsh

# List available configurations
./test.sh --list
```

**Features:**
- 🧪 Dry-run testing without making changes
- 📋 Lists available configurations
- 🎨 Colored output showing what would happen
- ✅ Validates Stow installation

### Uninstallation Script (`uninstall.sh`)

Remove all installed dotfiles:

```bash
# Uninstall all configurations
./uninstall.sh

# Uninstall a specific configuration
./uninstall.sh git

# Skip preview and force uninstall
./uninstall.sh --force
```

**Features:**
- 👀 Preview what will be removed
- ⚠️ Safety confirmations before removal
- 🎨 Colored output with progress indicators
- 🔒 Only removes symlinks (doesn't delete original files)

**Safety:**
- Always shows a preview before removing anything
- Requires explicit confirmation
- Only removes symlinks created by Stow
- Your original configuration files are never deleted

## 🧪 Testing with Stow

Before applying changes, it's recommended to test what Stow will do using the `--dry-run` flag. This shows you what symlinks would be created without actually creating them.

### Test All Configurations

```bash
stow --dry-run .
```

This will show you:
- Which files would be symlinked
- Where they would be created
- Any conflicts that might occur

### Test Specific Configuration

```bash
# Test Git configuration
stow --dry-run git

# Test Zsh configuration
stow --dry-run zsh

# Test Cursor configuration
stow --dry-run cursor
```

### Verbose Output

For more detailed information about what Stow is doing:

```bash
stow --verbose --dry-run .
```

### Simulate Installation

To see exactly what would happen without making changes:

```bash
stow --simulate .
```

### Check for Conflicts

Before installing, check if any files already exist that would conflict:

```bash
stow --adopt --simulate .
```

The `--adopt` flag shows what would happen if existing files were backed up and replaced.

## 📁 Structure

```
.dotfiles/
├── Brewfile                 # Homebrew packages and applications
├── LICENSE                  # License file
├── README.md               # This file
├── install.sh              # Installation script with colored output
├── test.sh                 # Testing script for dry-run
├── uninstall.sh            # Uninstallation script
├── claude-desktop/         # Claude Desktop configuration
│   └── Library/
│       └── Application Support/
│           └── Claude/
│               └── claude_desktop_config.json
├── cursor/                  # Cursor editor configuration
│   └── Library/
│       └── Application Support/
│           └── Cursor/
│               └── User/
│                   ├── settings.json
│                   └── keybindings.json
├── git/                     # Git configuration
│   └── .gitconfig
├── ssh/                     # SSH configuration
│   └── (SSH config files)
└── zsh/                     # Zsh shell configuration
    ├── .zshrc
    └── .zprofile
```

### How Stow Works

Stow creates symlinks from the dotfiles directory to your home directory. For example:

- `git/.gitconfig` → `~/.gitconfig`
- `zsh/.zshrc` → `~/.zshrc`
- `cursor/Library/Application Support/Cursor/User/settings.json` → `~/Library/Application Support/Cursor/User/settings.json`

## ⚙️ Configuration Details

### Git Configuration

The Git configuration includes:
- User name and email
- Conditional includes for specific repositories (e.g., InnerPro)

### Zsh Configuration

The Zsh configuration includes:
- Oh My Zsh framework
- Custom plugins
- Environment variables for:
  - Node.js (via fnm)
  - Ruby (via rbenv)
  - Java (JDK 17)
  - Android SDK
  - ASDF version manager

### Cursor Configuration

Cursor settings include:
- Editor preferences
- Keybindings
- Extensions (managed via Brewfile)

### Claude Desktop Configuration

Claude Desktop configuration includes:
- MCP (Model Context Protocol) server configurations
- Filesystem access configuration
- Context7 integration
- Notion integration

**⚠️ Important:** After installation, you need to add your API keys to the configuration file:

1. Open the configuration file:
   ```bash
   ~/Library/Application Support/Claude/claude_desktop_config.json
   ```

2. Replace the placeholder values with your actual API keys:
   - `YOUR_CONTEXT7_API_KEY_HERE` → Your Context7 API key
   - `YOUR_NOTION_TOKEN_HERE` → Your Notion integration token

3. Restart Claude Desktop for the changes to take effect.

**Security Note:** API keys are stored as placeholders in this repository for security. Never commit actual API keys to version control.

### Homebrew Packages

The `Brewfile` includes:
- **CLI Tools**: git, fnm, pnpm, pyenv
- **Applications**: Cursor, Docker Desktop, Slack, Brave Browser, Android Studio, etc.
- **Fonts**: JetBrains Mono, Zed Mono
- **VS Code/Cursor Extensions**: 40+ extensions for development

## 🔧 Maintenance

### Updating Configurations

1. Make changes to files in the dotfiles directory
2. Test changes:
   ```bash
   stow --dry-run .
   ```
3. Apply changes:
   ```bash
   stow --restow .
   ```

The `--restow` flag will recreate all symlinks, updating any that have changed.

### Removing Configurations

To remove a configuration:

```bash
# Remove Git configuration
stow -D git

# Remove all configurations
stow -D .
```

### Adding New Configurations

1. Create a new directory in the dotfiles folder:
   ```bash
   mkdir -p new-tool
   ```

2. Add configuration files maintaining the directory structure:
   ```bash
   # Example: For a tool that uses ~/.config/tool/config.json
   mkdir -p new-tool/.config/tool
   cp ~/.config/tool/config.json new-tool/.config/tool/
   ```

3. Test the new configuration:
   ```bash
   stow --dry-run new-tool
   ```

4. Install it:
   ```bash
   stow new-tool
   ```

### Updating Homebrew Packages

To update the Brewfile with currently installed packages:

```bash
# Update Brewfile with installed packages
brew bundle dump --force
```

## 🔍 Troubleshooting

### Symlink Conflicts

If you encounter conflicts with existing files:

1. Backup existing files:
   ```bash
   mv ~/.zshrc ~/.zshrc.backup
   ```

2. Use `--adopt` to replace and backup:
   ```bash
   stow --adopt zsh
   ```

### Stow Not Found

If `stow` command is not found:

```bash
brew install stow
```

### Permission Issues

If you encounter permission issues, ensure you have write access to your home directory and the dotfiles directory.

## 📝 Notes

- Always test with `--dry-run` before applying changes
- Keep your dotfiles repository in version control
- Document any custom configurations or environment-specific settings
- The `Brewfile` is managed separately and should be updated when adding/removing Homebrew packages

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome!

---

**Happy coding! 🚀**
