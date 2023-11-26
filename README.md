# Batjaa's dotfiles

## Shell setup

1. Use Safari to add your SSH keys to github. Clone the repository. In macos terminal simply `bash` will do.

2. To update, `cd` into your local `dotfiles` repository and then (remember to use bash):

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

3. Here’s an example `~/.path` file that adds `/usr/local/bin` to the `$PATH`:

```bash
export PATH="/usr/local/bin:$PATH"
```

5. Add custom commands without creating a new fork to `~/.extra`

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Batjaa Batbold"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="batjaa0615@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

## MacOS setup

1. Get [Homebrew](https://brew.sh) and run `./brew.sh`

2. `./brew-cask.sh`

3. Set defaults: `./.macos`

4. Configure [Hammerspoon](http://www.hammerspoon.org)

  1. Install Hammerspoon

  ```
  brew install hammerspoon
  ```

  2. Install [SpoonInstall](https://www.hammerspoon.org/Spoons/SpoonInstall.html)

  ```
  unzip ~/Downloads/SpoonInstall.spoon.zip -d ~/.hammerspoon/Spoons/
  ```

  3. Copy config

  ```
  cp .hammerspoon/init.lua ~/.hammerspoon/init.lua
  ```

## Google drive

- Sign ing
- Configure

## Alfred setup

- Apply license
- Update hotkey
- Enable clipboard history

## Thanks to…

* [Ben Bernard](http://blog.benjaminbernard.com/) and his [homedir repository](https://github.com/benbernard/HomeDir)
* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
* [Addy Osmani](http://www.addyosmani.com/) and his [dtofiles repository](https://github.com/addyosmani/dotfiles)
