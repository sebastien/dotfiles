set -o vi
BASE=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

function load-source () {
	if [ -e "$1" ]; then source "$1"; else echo "Could not source: $1"; fi
}

# NOTE: We need to set that before any sourcing, as this would erase the
# COMMAND_PROMPT variable.
if [ "$TILIX_ID" ] || [ "$VTE_VERSION" ]; then source /etc/profile.d/vte.sh; fi
load-source "$BASE/setup.sh"
load-source "$HOME/.cargo/env"
load-source "$HOME/.local/bin/appenv.bash"
load-source "$HOME/.nix-profile/etc/profile.d/nix.sh"
load-source "$HOME/.local/src/z/z.sh"
load-source "$HOME/.config/bash/sync-history.sh"
load-source "$HOME/.config/bash/prompt.sh"
# We can't do load-sour

export EDITOR=nvim
alias e=nvim
alias pak-in="sudo apt install"
alias pak-fd="sudo apt search"
alias pak-ls="sudo dpkg -L"
alias ls="exa"

export PATH=$HOME/go/bin:$PATH
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"

# EOF
