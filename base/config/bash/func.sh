# --
# Attaches to the given or latest TMUX session

if [ -n "${TERM_MULTIPLEXER}" ]; then
	echo -n ""
elif [ -n "$(which zellij 2>/dev/null)" ]; then
	export TERM_MULTIPLEXER=zellij
else
	export TERM_MULTIPLEXER=tmux
fi

function tat {
	local session="$1"
	local sid=""
	if [ -z "$session" ]; then
		case $TERM_MULTIPLEXER in
		tmux)
			session=$(tmux list-session | tail -n1 | cut -d: -f1)
			sid="$session"
			;;
		zellij)
			session=$(NO_COLOR=1 zellij list-sessions | sed 's/\x1B\[[0-9;]*m//g' | tail -n1 | cut -d' ' -f1)
			sid="$session"
			;;
		esac
	else
		case $TERM_MULTIPLEXER in
		tmux)
			sid=$(tmux list-session | grep "$session" | tail -n1 | cut -d: -f1)
			;;
		zellij)
			sid=$(zellij list-sessions | sed 's/\x1B\[[0-9;]*m//g' | grep "$session" | tail -n1 | cut -d' ' -f1)
			;;
		esac
	fi
	if [ -z "$sid" ]; then
		echo "!!! ERR Could not find a running tmux session $session"
	else
		case $TERM_MULTIPLEXER in
		tmux)
			tmux attach-session -t "$sid"
			;;
		zellij)
			zellij attach "$sid"
			;;
		esac
	fi
}
function tlist {
	case $TERM_MULTIPLEXER in
	tmux)
		tmux list-session | cut -d: -f1
		;;
	zellij)
		zellij list-sessions | sed 's/\x1B\[[0-9;]*m//g' | cut -d' ' -f1
		sid="$session"
		;;
	esac
}

function tnew {
	case $TERM_MULTIPLEXER in
	tmux)
		tmux new -t "$1"
		;;
	zellij)
		zellij attach --create "$1"
		;;
	esac
}

function znew {
	zellij attach --create "$1"
}

function zat {
	local session="$1"
	local sid=""
	if [ -z "$session" ]; then
		session=$(NO_COLOR=1 zellij list-sessions | sed 's/\x1B\[[0-9;]*m//g' | tail -n1 | cut -d' ' -f1)
		sid="$session"
	else
		sid=$(zellij list-sessions | sed 's/\x1B\[[0-9;]*m//g' | grep "$session" | tail -n1 | cut -d' ' -f1)
	fi
	if [ -z "$sid" ]; then
		echo "!!! ERR Could not find a running zellij session $session"
	else
		zellij attach "$sid"
	fi
}

function tls {
	tmux list-session | cut -d: -f1
}

function zls {
	zellij list-sessions 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' | awk '{print $1}'
}

function zkill {
	local session="$1"
	local sessions
	local target_session=""

	# Get list of sessions (both active and exited)
	sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' | awk '{print $1}')

	if [ -z "$sessions" ]; then
		echo "No zellij sessions found"
		return 1
	fi

	local session_count=$(echo "$sessions" | wc -l)

	if [ -n "$session" ]; then
		# Session name provided, find matching session (partial match allowed)
		target_session=$(echo "$sessions" | grep "^${session}" | head -n1)
		if [ -z "$target_session" ]; then
			echo "!!! ERR Could not find zellij session '$session'"
			return 1
		fi
	elif [ "$session_count" -eq 1 ]; then
		# Only one session exists, use it
		target_session=$(echo "$sessions" | head -n1)
	else
		# Multiple sessions, use fzf to select
		if command -v fzf >/dev/null 2>&1; then
			target_session=$(echo "$sessions" | fzf --prompt="Select session to kill: ")
			if [ -z "$target_session" ]; then
				echo "No session selected"
				return 1
			fi
		else
			echo "Multiple sessions found but fzf is not installed:"
			echo "$sessions"
			echo "Usage: zkill <session-name>"
			return 1
		fi
	fi

	echo "Killing zellij session: $target_session"
	zellij delete-session "$target_session" --force 2>/dev/null || zellij kill-session "$target_session"
}

# --
# Kills the process with the given name
function pl {
	if [ -z "$1" ]; then
		echo "Need to give a query string to lookup corresponding processes"
	else
		ps aux | grep $1 | grep -v grep
	fi

}

function kl {
	if [ -z "$1" ]; then
		echo "Need to give a query string to lookup corresponding processes"
	else
		for pid in $(ps aux | grep $1 | grep -v grep | awk '{print $2}'); do
			echo "Killing $pid"
			kill -9 $pid
		done
		ps aux | grep $1 | grep -v grep
	fi

}

# --
# Sets the term title
function do-set-term-title {
	echo -ne "\033]0;$1\007"
}
# EOF
