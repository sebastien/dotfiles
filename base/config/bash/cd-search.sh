# --
# # CD Search
#
# A utility to quickly jump between frequently changed paths
#
# --
# Allows to store and restore paths

CD_STORE_PATH=$HOME/.cache/bash
CD_LAST=
CD_EXT="git appenv hg gitmodules"
CD_LOG_PATH=$CD_STORE_PATH/cdstore.log
CD_LOG_MAX_ENTRIES=1000

function cd-store {
	local path=$(pwd)
	local timestamp=$(date +"%Y%m%d%H%M%S%3N")
	local dbpath="$CD_LOG_PATH"
	if [ ! -d "$CD_STORE_PATH" ]; then
		mkdir -p "$CD_STORE_PATH"
	elif [ -e "$dbpath" ] && [ "$(wc -l "$dbpath" | cut -d' ' -f1)" -ge 10000 ]; then
		local tmp=$(mktemp)
		tail -n 10000 "$dbpath" >$tmp
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
	echo "$timestamp|$meta|$path" >>"$dbpath"
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

# --
# `cd-search QUERY?` searches through the log of directories
function cd-search {
	local selection="$(tac $CD_STORE_PATH/cdstore.log | cut -d'|' -f3 | sort | uniq | fzf --query="$1" --select-1 --exit-0)"
	if [ ! -z "$selection" ]; then
		if [ -d "$selection" ]; then
			cd "$selection"
		elif [ -e "$selection" ]; then
			$EDITOR "$selection"
		else
			echo "-!- Selected path does not exist anymore: $selection"
		fi
	else
		echo "-!- Could not find any match for: $selection"
	fi
}

function cd-log-pruned {
	local path
	while read line; do
		path="$(echo $line | cut -d'|' -f3)"
		if [ -e "$path" ]; then
			echo "$line"
		fi
	done <"$CD_LOG_PATH"
}

function cd-entries {
	wc -l "$CD_LOG_PATH"
}

function cd-log-size {
	du -hs "$CD_LOG_PATH"
}

function cd-prune {
	cd-log-pruned | tail "-n$CD_LOG_MAX_ENTRIES" >"$CD_LOG_PATH.tmp"
	mv "$CD_LOG_PATH.tmp" "$CD_LOG_PATH"
}

# if [ -e "$CD_LOG_PATH" ]; then
# 	cd-prune
# fi

# EOF
