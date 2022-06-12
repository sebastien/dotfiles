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
# Allows to store and restore paths
CD_STORE_PATH=$HOME/.cache/bash
CD_LAST=
CD_EXT="git appenv hg gitmodules"
function cd-store {
	local path=$(pwd)
	local timestamp=$(date +"%Y%m%d%H%M%S%3N")
	local dbpath="$CD_STORE_PATH/cdstore.log"
	if [ ! -d "$CD_STORE_PATH" ]; then
		mkdir -p "$CD_STORE_PATH";
	elif [ -e "$dbpath" ] && [ "$(wc -l "$dbpath" | cut -d' ' -f1)" -ge 10000 ]; then
		local tmp=$(mktemp)
		tail -n 10000 "$dbpath" > $tmp
		mv -f $tmp "$dbpath"
	fi
	local meta=""
	for ext in $CD_EXT; do
		if [ -e "$path/.$ext" ]; then
			if [ -z "$meta" ]; then
				meta=$ext
			else
				meta+=" $ext"
			fi
		fi
	done
	export CD_LAST="$dbpath"
	echo "$timestamp|$meta|$path" >> "$dbpath"
}

function cd-last {
	local dbpath="$CD_STORE_PATH/cdstore.log"
	if [ -e "$dbpath" ]; then
		if [ -z "$1" ]; then
			export CD_LAST=$(tail -n1 "$dbpath" | cut -d'|' -f3)
		else
			export CD_LAST=$(grep "$1" "$dbpath" | tail -n1 | cut -d'|' -f3)
		fi
	else
		export CD_LAST="."
	fi
	echo -n "$CD_LAST"
}

function cd-restore {
	cd "$(cd-last $1)"
}

function cd-prompt-helper {
	if [ -z "$CD_LAST" ]; then
		cd-restore
		export CD_LAST=$(pwd)
	else
		cd-store
	fi
}

function cd-log {
	local dbpath="$CD_STORE_PATH/cdstore.log"
	if [ -e "$dbpath" ]; then
		if [ -z "$1" ]; then
			cat "$dbpath"
		else
			grep "$1" "$dbpath"
		fi
	fi
}

# EOF
