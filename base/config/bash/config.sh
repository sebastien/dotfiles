BASH_BASE=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

set -o vi
shopt -s extglob

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
load-source "$HOME/.local/bin/appenv.bash"
load-source "$HOME/.nix-profile/etc/profile.d/nix.sh"
load-source "$HOME/.local/src/z/z.sh"
# We need to that later on
load-source "$BASH_BASE/sync-history.sh"
load-source "$BASH_BASE/prompt.sh"

# EOF
