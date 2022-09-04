#!/usr/bin/env bash

# Install command-line tools using Homebrew

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Save Homebrew’s installed location
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
# brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
# brew install gnu-sed --with-default-names
# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install grep
# brew install openssh
brew install screen


# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install other useful binaries.
brew install wget
brew install ack
brew install brightness
brew install git
brew install git-lfs
brew install gh
brew install jq
brew install imagemagick --with-webp
brew install lua
brew install asdf
# brew install p7zip
# brew install pigz
# brew install pv
brew install rename
brew install tree
brew install vbindiff
brew install blueutil
# brew install zopfli

# Remove outdated versions from the cellar.
brew cleanup

# to maintain cask ....
#     brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup`


# Install native apps

# daily
# brew install slate # discontinued
brew install bettertouchtool
brew install slack
brew install rescuetime
brew install toggl-track
brew install alfred
brew install spotify
brew install google-drive
brew install 1password
brew install obsidian
brew install gifox
brew install htop

# dev
brew install iterm2
brew install p4v
brew install sublime-text
brew install visual-studio-code
brew install dash
brew install trailer
brew install hammerspoon
# brew install postman
brew install jetbrains-toolbox

# js
brew install nvm
# brew install yarn

# lamp-like stack
# brew install php
# brew install composer
# brew install sequel-pro


# communication
brew install discord
# brew install whatsapp
# brew install viber
# brew install telegram

# creativity
# brew install adobe-creative-cloud

# brew install imagealpha
# brew install imageoptim

# fun
# brew install limechat
# brew install miro-video-converter
# brew install horndis               # usb tethering
# brew install steam

# browsers
brew install google-chrome
# brew install google-chrome-canary
# brew install homebrew/cask-versions/firefox-developer-edition
# brew install webkit-nightly
# brew install chromium
# brew install tor-browser

# less often
# brew install screenflow4 # 4 specifically not 5.
brew install vlc
# brew install gpgtools
# brew install licecap
# brew install utorrent
# brew install garmin-express
brew install daisydisk
