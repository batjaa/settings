# Batjaa's dotfiles

1. Use Safari to add your SSH keys to github. Clone the repository. In macos terminal simply `bash` will do.

1. To update, `cd` into your local `dotfiles` repository and then (remember to use bash):

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

1. Here’s an example `~/.path` file that adds `/usr/local/bin` to the `$PATH`:

```bash
export PATH="/usr/local/bin:$PATH"
```

1. Add custom commands without creating a new fork to `~/.extra`

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

1. When setting up a new Mac, you may want to set some sensible macOS defaults: `bash ./.macos`

1. Get (Homebrew)[https://brew.sh]

1. `./brew.sh`

## Thanks to…

* [Ben Bernard](http://blog.benjaminbernard.com/) and his [homedir repository](https://github.com/benbernard/HomeDir)
* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
* [Addy Osmani](http://www.addyosmani.com/) and his [dtofiles repository](https://github.com/addyosmani/dotfiles)
