#!/usr/bin/env bash


# to maintain cask ....
#     brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup`


# Install native apps

brew install caskroom/cask/brew-cask
brew tap caskroom/versions

brew cask install slate
brew cask install bettertouchtool
brew cask install alfred
brew cask install karabiner-elements

# daily
brew cask install dropbox
brew cask install slack
brew cask install google-drive-file-stream
brew cask install rescuetime
brew cask install vlc
brew cask install spotify

# dev
brew cask install iterm2
brew cask install sublime-text
brew cask install sublime-merge
brew cask install dash
brew cask install postman
brew cask install trailer
brew install hub
# brew cask install imagealpha
# brew cask install imageoptim

# quartzy
brew cask install sequel-pro
brew install composer
brew cask install jetbrains-toolbox

# fun
# brew cask install limechat
# brew cask install miro-video-converter
# brew cask install horndis               # usb tethering

# browsers
brew cask install google-chrome
brew cask install google-chrome-canary
brew cask install firefox-nightly
brew cask install chromium
brew cask install tor-browser

# video and photo editing
brew cask install adobe-creative-cloud

# less often
brew cask install viber
# brew cask install daisydisk # install using app store
# brew cask install balenaetcher
# brew cask install disk-inventory-x
# brew cask install screenflow4 # 4 specifically not 5.
