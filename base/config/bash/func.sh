# --
# Attaches to the given or latest TMUX session

if [ -n "${TERM_MULTIPLEXER}" ]; then
	echo -n ""
elif [ -n "$(which zellij 2> /dev/null)" ]; then
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

# EOF
