# Reuse Homebrew's environment in child shells.
if [ -z "${HOMEBREW_PREFIX:-}" ] || ! command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Add sbin to PATH
export PATH="/usr/local/sbin:$PATH"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
_settings_brew_prefix="${HOMEBREW_PREFIX:-}"
if [ -z "$_settings_brew_prefix" ] && command -v brew >/dev/null 2>&1; then
  _settings_brew_prefix="$(brew --prefix)"
fi
if [ -n "$_settings_brew_prefix" ] && [ -r "$_settings_brew_prefix/etc/profile.d/bash_completion.sh" ]; then
  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="$_settings_brew_prefix/etc/bash_completion.d";
  source "$_settings_brew_prefix/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi;
unset _settings_brew_prefix

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add direnv hook
eval "$(direnv hook bash)"

# Add NVM lazily; the legacy bootstrap copies this helper into $HOME.
[ ! -r "$HOME/.nvm_lazy" ] || . "$HOME/.nvm_lazy"
