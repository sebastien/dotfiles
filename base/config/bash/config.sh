BASH_BASE=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

set -o vi
shopt -s extglob
shopt -s checkwinsize


# Nicer shell experience
# FROM <https://opensource.com/article/20/3/fish-shell>
export GREP_OPTIONS="--color=auto"; # make grep colorful
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD; # make ls more colorful as well
export HISTSIZE=32768; # Larger bash history (allow 32³ entries; default is 500)
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups; # Remove duplicates from history. I use `git status` a lot.
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"; # Make some commands not show up in history
export LANG="en_US.UTF-8"; # Language formatting is still important
export LC_ALL="en_US.UTF-8"; # byte-wise sorting and force language for those pesky apps
export MANPAGER="less -X"; # Less is more

function load-source () {
	if [ -e "$1" ]; then source "$1"; else echo "Could not source: $1"; fi
}

# NOTE: We need to set that before any sourcing, as this would erase the
# COMMAND_PROMPT variable.
if [ "$TILIX_ID" ] || [ "$VTE_VERSION" ]; then source /etc/profile.d/vte.sh; fi
load-source "$BASH_BASE/setup.sh"
load-source "$BASH_BASE/aliases.sh"
load-source "$BASH_BASE/env.sh"
load-source "$HOME/.cargo/env"
# load-source "$HOME/.local/bin/appenv.bash"
load-source "$HOME/Workspace/Community/appenv/bin/appenv.bash"
load-source "$HOME/.nix-profile/etc/profile.d/nix.sh"
load-source "$HOME/.local/src/z/z.sh"
# We need to that later on
load-source "$BASH_BASE/preexec.sh"
load-source "$BASH_BASE/prompt.sh"
if [ -s "$(which direnv 2> /dev/null)" ]; then eval "$(direnv hook bash)"; fi

# EOF
