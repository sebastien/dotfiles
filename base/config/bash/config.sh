BASH_BASE=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

set -o vi
shopt -s extglob
shopt -s checkwinsize

export PYENV_ROOT="$HOME/.pyenv"
if [ -e "$PYENV_ROOT" ]; then
	command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
	eval "$(pyenv init -)"
fi

if [ -z "$BASH_CONFIG_LOADED" ]; then

	#export BASH_CONFIG_LODAED="$(date +"%Y-%m-%dT%H:%M:%S:%3N")"
	# Nicer shell experience
	# FROM <https://opensource.com/article/20/3/fish-shell>
	export GREP_OPTIONS="--color=auto"     # make grep colorful
	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD # make ls more colorful as well
	export HISTSIZE=32768                  # Larger bash history (allow 32³ entries; default is 500)
	export HISTFILESIZE=$HISTSIZE
	export HISTCONTROL=ignoredups                         # Remove duplicates from history. I use `git status` a lot.
	export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help" # Make some commands not show up in history
	export LANG="en_US.UTF-8"                             # Language formatting is still important
	export LC_ALL="en_US.UTF-8"                           # byte-wise sorting and force language for those pesky apps
	export MANPAGER="less -X"                             # Less is more
	export CDPATH=.:$HOME/Workspace:$HOME
	export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive¬

	function load-source() {
		if [ -e "$1" ]; then
			source "$1"
		elif [ -z "$2" ]; then
			echo "Could not source: $1"
		fi
	}

	# NOTE: We need to set that before any sourcing, as this would erase the
	# COMMAND_PROMPT variable.
	if [ "$TILIX_ID" ] || [ "$VTE_VERSION" ]; then source /etc/profile.d/vte.sh; fi
	load-source "$BASH_BASE/setup.sh"
	load-source "$BASH_BASE/aliases.sh"
	load-source "$BASH_BASE/env.sh"
	load-source "$BASH_BASE/func.sh"
	load-source "$BASH_BASE/cd-search.sh"
	load-source "$HOME/.cargo/env" skip
	load-source "$HOME/.local/bin/appenv.bash"
	# NOTE: Not using z anymore
	# load-source "$HOME/.local/src/z/z.sh"
	# load-source "$HOME/Workspace/Community/appenv/bin/appenv.bash" silent
	load-source "$HOME/.nix-profile/etc/profile.d/nix.sh" silent
	# We need to that later on
	# load-source "$BASH_BASE/preexec.sh"
	load-source "$BASH_BASE/secrets.sh"
	load-source "$BASH_BASE/prompt.sh"
	load-source "$HOME/Workspace/nota/src/sh/libnota.sh"
	load-source "$HOME/.sdkman/bin/sdkman-init.sh" silent
	load-source "$HOME/.config/broot/launcher/bash/br"

	OS=$(uname)
	for completion in $BASH_BASE/completion.*.sh; do
		# For some reason FZF completion doesn't work in Darwin
		if [ "$completion" == "fzf" ] && [ "$OS" == "Darwin" ]; then
			pass=
		else
			load-source "$completion"
		fi
	done

	if [ -s "$(which direnv 2>/dev/null)" ]; then eval "$(direnv hook bash)"; fi

fi

# EOF
