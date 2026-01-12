# Disable UI sound effects
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show files in Finder ordered by kind
defaults write com.apple.finder ArrangeBy -string "kind"

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

#  Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1

# Shorter delay before key repeat (12ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 12

# Auto-hide Dock
defaults write com.apple.dock autohide -bool true

# Show battery percentage in menu bar
# Works on macOS Sequoia (15.x) and later, including Tahoe (26.x)
defaults write com.apple.controlcenter BatteryShowPercentage -bool true

# Reload SystemUIServer to apply changes
killall SystemUIServer 2>/dev/null || true

