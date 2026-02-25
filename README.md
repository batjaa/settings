# Batjaa's dotfiles

> My personal dotfiles and configurations for software development, stock trading, and photo editing on macOS.

**Compatible with:** macOS Sequoia (15.x) and Tahoe (16.x)  
**Last Updated:** December 2025

---

## 📋 Table of Contents

- [Quick Start (New Mac Setup)](#-quick-start-new-mac-setup)
- [Repository Contents](#-repository-contents)
- [Detailed Setup](#-detailed-setup)
  - [1. SSH Keys & Git](#1-ssh-keys--git)
  - [2. Shell Configuration](#2-shell-configuration)
  - [3. Additional Tools](#3-additional-tools)
- [Hammerspoon Keybindings](#-hammerspoon-keybindings)
- [Updating Dotfiles](#-updating-dotfiles)
- [Credits](#-credits)

---

## 🚀 Quick Start (New Mac Setup)

For a brand new MacBook Pro, follow these steps in order:

```bash
# 1. Install Xcode Command Line Tools
xcode-select --install

# 2. Generate SSH key and add to GitHub (see detailed section below)
ssh-keygen -t ed25519 -C "your_email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub
# Go to GitHub → Settings → SSH Keys → Add new key

# 3. Clone this repository
mkdir -p ~/git
cd ~/git
git clone git@github.com:batjaa/settings.git
cd settings

# 4. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 5. Install applications
./brew.sh

# 6. Set up shell dotfiles
./bootstrap.sh

# 7. Apply macOS system settings
chmod +x .macos
./.macos

# 8. Set up Hammerspoon (window management)
mkdir -p ~/.hammerspoon/Spoons
curl -L https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip -o /tmp/SpoonInstall.spoon.zip
unzip /tmp/SpoonInstall.spoon.zip -d ~/.hammerspoon/Spoons/
ln -sf ~/git/settings/.hammerspoon/init.lua ~/.hammerspoon/init.lua
open /Applications/Hammerspoon.app

# 9. Restart your Mac for all settings to take effect
```

---

## 📦 Repository Contents

### Core Configuration Files

| File | Description |
|------|-------------|
| `.bash_profile` | Main bash configuration, sources other files |
| `.bash_prompt` | Custom bash prompt with git integration |
| `.aliases` | Custom shell aliases and shortcuts |
| `.exports` | Environment variables (PATH, editor, etc.) |
| `.path` | Additional PATH modifications |
| `.gitconfig` | Git configuration and aliases |
| `.editorconfig` | Editor settings for consistent coding style |
| `.tmux.conf` | Tmux terminal multiplexer configuration |

### System Configuration

| File/Directory | Description |
|----------------|-------------|
| `.macos` | **macOS system defaults** - Disables animations, configures keyboard, Finder, Dock, Safari, and more |
| `.hammerspoon/` | **Window management** - Keyboard shortcuts for window positioning and app launching |
| `brew.sh` | **Homebrew packages** - Installs CLI tools and GUI applications |
| `bootstrap.sh` | Syncs dotfiles from this repo to home directory |

### Application Configurations

| Directory | Description |
|-----------|-------------|
| `iterm2/` | iTerm2 color schemes and profiles |
| `karabiner/` | Karabiner-Elements keyboard customization |
| `keyboard/` | Keychron Q1 keyboard configuration and keymaps |
| `sublime/` | Sublime Text snippets and settings |
| `git/` | Git merge tool and advanced git configurations |
| `bin/` | Custom executable scripts |

---

## 🔧 Detailed Setup

### 1. SSH Keys & Git

Generate SSH key and configure Git credentials:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "batjaa0615@gmail.com"

# Copy public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys

# Configure Git (add to ~/.extra to keep it private)
cat > ~/.extra << 'EOF'
# Git credentials
GIT_AUTHOR_NAME="Batjaa Batbold"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="batjaa0615@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
EOF

source ~/.extra
```

### 2. Shell Configuration

The `bootstrap.sh` script syncs dotfiles to your home directory:

```bash
cd ~/git/settings

# Interactive mode (asks for confirmation)
./bootstrap.sh

# Force mode (no confirmation)
./bootstrap.sh -f
```

**What it does:**
- Copies `.bash_profile`, `.aliases`, `.exports`, etc. to `~/`
- Excludes `.macos`, `README.md`, and app-specific configs
- Automatically sources `.bash_profile` after copying

**To update later:**
```bash
cd ~/git/settings
source bootstrap.sh
```

### 3. Additional Tools

#### Alfred

```bash
# After installation via brew.sh:
# 1. Apply license
# 2. Set hotkey to Cmd+Space (Spotlight is disabled in .macos)
# 3. Enable clipboard history with Cmd+Shift+C shortcut
# 4. Sync settings to ~/My Drive/Apps/Alfred (auto-configured in .macos)
```

#### Tmux Plugins

Tmux plugins are managed by [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm). Install TPM first, then install the plugins:

```bash
# 1. Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 2. Start tmux (or reload config if already running)
tmux
# Inside tmux: press Ctrl+A then R to reload config

# 3. Install plugins
# Inside tmux: press Ctrl+A then I (capital i) to install plugins
# TPM will clone and load all plugins listed in .tmux.conf
```

**Included plugins:**

| Plugin | Description |
|--------|-------------|
| `tmux-sensible` | Sensible defaults everyone can agree on |
| `tmux-resurrect` | Save/restore sessions across tmux restarts (`Ctrl+A Ctrl+S` to save, `Ctrl+A Ctrl+R` to restore) |
| `tmux-continuum` | Auto-saves sessions every 15 min and restores on tmux start |
| `tmux-yank` | Copy to system clipboard from copy mode |

**Updating plugins:** `Ctrl+A` then `U` (capital u) inside tmux.

#### GitHub CLI

```bash
# Install gh-dash extension for better PR/issue management
gh extension install dlvhdr/gh-dash
```

#### Google Drive

```bash
# After first launch:
# 1. Sign in
# 2. Configure to mirror files (not streaming)
```

#### Fonts

Install your custom fonts from Google Drive backup.

#### Node.js (via nvm)

```bash
# Load nvm (should be in .bash_profile)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# Install latest LTS
nvm install --lts
nvm use --lts
```

---

## ⌨️ Hammerspoon Keybindings

All keybindings are designed to avoid conflicts with macOS system shortcuts. See `.hammerspoon/init.lua` for complete details.

### Quick Reference

**Window Management:** `Ctrl+Alt+Cmd` + arrow keys or numbers (1-6)  
**App Launcher:** `Option` + number (1-6) or Escape  
**Window Grid:** `Ctrl+Escape`  
**System Info:** `Ctrl+Alt+Cmd+I`  
**Reload Config:** `Ctrl+Alt+Cmd+R`  
**Options Menu:** `Ctrl+Alt+Cmd+Shift+O`

### Features

- **Window Management:** Snap windows to halves, quarters, or full screen
- **App Launcher:** Quick access to Finder, iTerm, Chrome, Sublime, Slack, Spotify
- **Caffeine Mode:** Click ☕/💤 in menu bar to keep Mac awake
- **System Options:** Lock, sleep, display info, hotkey conflict checker
- **Auto-reload:** Config reloads automatically when edited

---

## 🔄 Updating Dotfiles

After making changes to files in this repository:

```bash
# Update shell dotfiles (copies to ~/)
cd ~/git/settings
source bootstrap.sh

# Hammerspoon (auto-synced via symlink, just reload)
# Press Ctrl+Alt+Cmd+R
# Or from Hammerspoon menu → Reload Config

# macOS system settings
./.macos

# Homebrew packages
./brew.sh
```

**Note:** Hammerspoon config updates automatically via symlink - just reload the config.

---

## 📝 Tips & Tricks

### Adding Custom Commands

Create `~/.extra` for commands you don't want to commit to the repo:

```bash
# Example: AWS credentials, API keys, etc.
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# Custom aliases
alias projects="cd ~/git"
```

This file is sourced by `.bash_profile` but not tracked by git.

### PATH Customization

Edit `~/.path` to add directories to your PATH:

```bash
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
```

### Git Merge Tool Setup

See `git/readme.md` for configuring Sublime Merge as your git diff/merge tool.

### Sublime Text Setup

See `sublime/readme.md` for:
- Package Control installation
- Recommended plugins
- Custom snippets
- Key bindings

---

## 🙏 Credits

This configuration is built upon the excellent work of:

* [Mathias Bynens](https://mathiasbynens.be/) - [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
* [Ben Bernard](http://blog.benjaminbernard.com/) - [homedir repository](https://github.com/benbernard/HomeDir)
* [Addy Osmani](http://www.addyosmani.com/) - [dotfiles repository](https://github.com/addyosmani/dotfiles)

---

## 📄 License

These are my personal configurations - feel free to use anything that's helpful!

---

**Questions or Issues?**  
Open an issue in this repository or submit a PR if you find improvements!
