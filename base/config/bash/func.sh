# --
# Attaches to the given or latest TMUX session
function tat {
	local session="$1"
	local sid=""
	if [ -z "$session" ]; then
		session=$(tmux list-session | tail -n1 | cut -d: -f1)
		sid="$session"
	else
		sid=$(tmux list-session | grep "$session" | tail -n1 | cut -d: -f1)
	fi
	if [ -z "$sid" ]; then
		echo "!!! ERR Could not find a running tmux session $session"
	else
		tmux attach-session -t "$sid"
	fi
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
