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
	local sessions=""

	case $TERM_MULTIPLEXER in
	tmux)
		sessions=$(tmux list-sessions 2>/dev/null | cut -d: -f1)
		;;
	zellij)
		sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' | awk '{print $1}')
		;;
	esac

	if [ -z "$sessions" ]; then
		echo "!!! ERR No running sessions found"
		return 1
	fi

	if [ -z "$session" ]; then
		local session_count
		session_count=$(echo "$sessions" | grep -c .)
		if [ "$session_count" -eq 1 ]; then
			sid="$sessions"
		else
			if command -v fzf >/dev/null 2>&1; then
				sid=$(echo "$sessions" | fzf --prompt="Select session: ")
				if [ -z "$sid" ]; then
					echo "No session selected"
					return 1
				fi
			else
				sid=$(echo "$sessions" | tail -n1)
			fi
		fi
	else
		# Check for exact match first
		sid=$(echo "$sessions" | grep "^${session}$")

		# If no exact match, check for partial matches
		if [ -z "$sid" ]; then
			local matches
			matches=$(echo "$sessions" | grep "$session")
			local match_count
			match_count=$(echo "$matches" | grep -c .)

			if [ "$match_count" -eq 0 ]; then
				echo "!!! ERR Could not find session matching '$session'"
				return 1
			elif [ "$match_count" -eq 1 ]; then
				# Only one partial match, use it
				sid="$matches"
			else
				# Multiple matches, use fzf to select
				if command -v fzf >/dev/null 2>&1; then
					sid=$(echo "$matches" | fzf --prompt="Select session: ")
					if [ -z "$sid" ]; then
						echo "No session selected"
						return 1
					fi
				else
					echo "!!! ERR Multiple sessions found matching '$session' but fzf is not installed:"
					echo "$matches"
					return 1
				fi
			fi
		fi
	fi

	if [ -z "$sid" ]; then
		echo "!!! ERR Could not find a running session"
		return 1
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
	local sessions=""

	# Get list of all sessions
	sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' | awk '{print $1}')

	if [ -z "$sessions" ]; then
		echo "!!! ERR No running zellij sessions found"
		return 1
	fi

	if [ -z "$session" ]; then
		# No session specified, use the most recent one
		sid=$(echo "$sessions" | tail -n1)
	else
		# Check for exact match first
		sid=$(echo "$sessions" | grep "^${session}$")

		# If no exact match, check for partial matches
		if [ -z "$sid" ]; then
			local matches
			matches=$(echo "$sessions" | grep "$session")
			local match_count
			match_count=$(echo "$matches" | grep -c .)

			if [ "$match_count" -eq 0 ]; then
				echo "!!! ERR Could not find zellij session matching '$session'"
				return 1
			elif [ "$match_count" -eq 1 ]; then
				# Only one partial match, use it
				sid="$matches"
			else
				# Multiple matches, use fzf to select
				if command -v fzf >/dev/null 2>&1; then
					sid=$(echo "$matches" | fzf --prompt="Select zellij session: ")
					if [ -z "$sid" ]; then
						echo "No session selected"
						return 1
					fi
				else
					echo "!!! ERR Multiple sessions found matching '$session' but fzf is not installed:"
					echo "$matches"
					return 1
				fi
			fi
		fi
	fi

	if [ -z "$sid" ]; then
		echo "!!! ERR Could not find a running zellij session"
		return 1
	else
		echo "Attaching to zellij session: $sid"
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

	local session_count=$(echo "$sessions" | grep -c .)

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
