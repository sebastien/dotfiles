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

# EOF
