# --
# # Bash Prompt
#
# --
# NOTE: The trick is that colors need to be put between \[ and\] in the prompt.
# SEE: https://en.wikipedia.org/wiki/ANSI_escape_code
# SEE: https://stackoverflow.com/questions/1133031/shell-prompt-line-wrapping-issue#2774197
# SEE: https://stackoverflow.com/questions/1133031/shell-prompt-line-wrapping-issue
# SEE: https://stackoverflow.com/questions/37424743/sometimes-cursor-jumps-to-start-of-line-in-bash-prompt

# if [[ "$SHELL_TYPE" == "bash" ]]; then
#   shopt -s extglob # function uses extended globbing
# fi

HAS_MPSTAT=$(which mpstat 2>/dev/null)

case $HOSTNAME in
bench*)
	HOSTICON="🧰 "
	;;
?renade*|?osmos*)
	HOSTICON="💻 "
	;;
central*)
	HOSTICON="🏟️ "
	;;
cerise*)
	HOSTICON="🍒 "
	;;
X1T*)
	HOSTICON="📓 "
	;;
AL-*)
	HOSTICON="🏦 "
	;;
esac

function strip-ansi() {
	# shopt -s extglob # function uses extended globbing
	printf %s "${1//$'\e'\[*([0-9;])m/}"
}

function strip-prompt() {
	strip-ansi "$1" | sed 's/\\\[//g;s/\\\]//g'
}

function palette {
	for C in {0..255}; do
		tput setab "$C"
		echo -n "$C "
	done
	tput sgr0
	echo
}

if [ -z "$NOCOLOR" ]; then
	CYAN="$(tput setaf 33)"
	BLUE_DK="$(tput setaf 27)"
	BLUE="$(tput setaf 33)"
	BLUE_LT="$(tput setaf 117)"
	GREEN="$(tput setaf 34)"
	YELLOW="$(tput setaf 220)"
	GOLD="$(tput setaf 214)"
	GOLD_DK="$(tput setaf 208)"
	PURPLE_DK="$(tput setaf 55)"
	PURPLE="$(tput setaf 92)"
	PURPLE_LT="$(tput setaf 163)"
	RED="$(tput setaf 124)"
	ORANGE="$(tput setaf 202)"
	BOLD="$(tput bold)"
	REVERSE="$(tput rev)"
	RESET="$(tput sgr0)"
elif tput setaf 1 &>/dev/null; then
	CYAN=""
	BLUE_DK=""
	BLUE=""
	BLUE_LT=""
	GREEN=""
	YELLOW=""
	GOLD=""
	GOLD_DK=""
	PURPLE_DK=""
	PURPLE=""
	PURPLE_LT=""
	RED=""
	ORANGE=""
	BOLD=""
	REVERSE=""
	RESET=""
fi

# Path
# [remotehost]
# ▒█~/W/tlang » ▓▒░cd appenv/    ⏲ default|1 ⑂ R103+|103 ⋐ tlang:projects:tdoc

function scm-type {
	git branch >/dev/null 2>/dev/null && echo '±' && return
	hg root >/dev/null 2>/dev/null && echo '☿' && return
	echo '○'
}

function prompt-setup {
	STATUS_COLOR=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
	export STATUS_COLOR
	# We change the current directory
	if declare -f -F cd-prompt-helper >/dev/null; then
		cd-prompt-helper
	fi
}

function prompt-left {
	prompt_path="$(basename $(dirname "$PWD"))/\[$BOLD\]$(basename "$PWD")"
	echo "$HOSTICON\[$STATUS_COLOR\]─\[$RESET\]\[$STATUS_COLOR\]░▒▓\[$REVERSE\] ${prompt_path} \[$RESET\]\[$STATUS_COLOR\]▓▒░\[${STATUS_COLOR}\] ▷\[${RESET}\] "
}

function prompt-right {
	# NOTE: This has got to be the first line
	process_count=$(ps -u "$USER" | wc -l)
	# As usual, Arch Linux has a great [Bash/Prompt customization](https://wiki.archlinux.org/index.php/Bash/Prompt_customization)
	# page.
	# SEE: https://unix.stackexchange.com/questions/9605/how-can-i-detect-if-the-shell-is-controlled-from-ssh#9607
	if [[ $(who am i) =~ \([-a-zA-Z0-9\.]+\)$ ]]; then
		session_type="┈⦗ssh@$HOSTNAME⦘"
	else
		session_type=""
	fi
	# We get Git information
	scm_summary=""
	git_branch=$(git branch --no-color -l 2>/dev/null)
	if [ -n "$git_branch" ]; then
		git_branch_count=$(echo "$git_branch" | wc -l)
		git_branch_current=$(echo "$git_branch" | grep '*' | cut -d' ' -f2)
		git_staged_count=$(git diff --cached --numstat | wc -l)
		git_unstaged_count=$(git diff --numstat | wc -l)
		git_rev_number=$(git rev-list --count HEAD)
		scm_summary="\[$RESET\]\[$PURPLE_DK\]⟜\[$PURPLE\]\[$BOLD\]${git_branch_current}\[$RESET\]\[$PURPLE_DK\]⋲ \[$PURPLE\]${git_branch_count} $(scm-type)R\[$PURPLE_LT\]${git_rev_number}\[$BOLD\]+${git_unstaged_count}\[$RESET\]\[$PURPLE\]+${git_staged_count}\[$PURPLE_DK\]\[$RESET\]"
	fi
	if [ -n "$APPENV_STATUS" ] || [ -e ".appenv" ]; then
		appenv_status=" \[$GOLD_DK\]$(if [ -e ".appenv" ]; then echo "▶"; else echo "▷"; fi)\[$GOLD\]$APPENV_STATUS\[$GOLD_DK\] "
	fi
	# Warnings
	# This is the disk capacity in %
	stat_hdd_capacity=$(df -h . | tail -n1 | awk '{print $5}')
	# This is the memory left in kB
	if [ -e "/proc/meminfo" ]; then
		stat_mem_free=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
	else
		state_mem_free=""
	fi
	# FROM: https://stackoverflow.com/questions/9229333/how-to-get-overall-cpu-usage-e-g-57-on-linux#9229580
	# NOTE: I tried different options and used the one that's the fastest. We don't
	# want thr prompt to take too long.
	if [ ! -z "$HAS_MPSTAT" ]; then
		stat_cpu_usage=$(mpstat | awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }')
	fi
	echo "${appenv_status}${scm_summary}\[$PURPLE_DK\]⛬ ${process_count} ○$(date '+%T')\[$PURPLE\]${session_type}\[$RESET\]"
}

if [ -z "$SHELL_TYPE" ] || [[ "$SHELL_TYPE" == "bash" ]]; then
	function prompt() {
		# If we have cd-store, we call it

		prompt-setup
		prompt_left="$(prompt-left)"
		prompt_right="$(prompt-right)"
		prompt_left_noctrl=$(strip-prompt "$prompt_left")
		prompt_right_noctrl=$(strip-prompt "$prompt_right")
		prompt_right_len="${#prompt_right_noctrl}"
		# NOTE: Not sure why we have a manual correction, but here we go
		prompt_right_padded=$(printf "%$(($COLUMNS - ${#prompt_right_noctrl} + 3))s%s" "" "$prompt_right")

		PS1="$prompt_right_padded\n$prompt_left"
	}
	export PROMPT_COMMAND=prompt
fi

# EOF
