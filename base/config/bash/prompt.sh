# --
# # Bash Prompt
# --
# SEE: https://en.wikipedia.org/wiki/ANSI_escape_code

function strip-ansi() {
  shopt -s extglob # function uses extended globbing
  printf %s "${1//$'\e'\[*([0-9;])m/}"
}

function palette {
	for C in {0..255}; do
		tput setab $C
		echo -n "$C "
	done
	tput sgr0
	echo
}

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
NOT_BOLD="\\033[2m"
RESET="$(tput sgr0)"

# Path
# [remotehost]
# ▒█~/W/tlang » ▓▒░cd appenv/    ⏲ default|1 ⑂ R103+|103 ⋐ tlang:projects:tdoc

prompt() {
	# NOTE: This has got to be the first line
	process_count=$(ps -u "$USER" | wc -l)

	status_color=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
	# As usual, Arch Linux has a great [Bash/Prompt customization](https://wiki.archlinux.org/index.php/Bash/Prompt_customization)
	# page.
	# SEE: https://unix.stackexchange.com/questions/9605/how-can-i-detect-if-the-shell-is-controlled-from-ssh#9607
	session_type=$(if [[ $(who am i) =~ \([-a-zA-Z0-9\.]+\)$ ]] ; then echo -n ssh; fi)

	# We get Git information
	scm_summary=""
	git_branch=$(git branch --no-color -l 2> /dev/null)
	if [ -n "$git_branch" ]; then
		git_branch_count=$(echo "$git_branch" | wc -l)
		git_branch_current=$(echo "$git_branch" | grep '*' |  cut -d' ' -f2)
		git_staged_count=$(git diff --cached --numstat | wc -l)
		git_unstaged_count=$(git diff --numstat | wc -l)
		git_rev_number=$(git rev-list --count HEAD)
		scm_summary="$PURPLE$RESET$PURPLE$BOLD${git_branch_current} ⭄ ${git_branch_count} R$PURPLE_LT${git_rev_number}$BOLD+${git_unstaged_count}$RESET$PURPLE+${git_staged_count}$PURPLE_DK|$RESET"
	fi

	# Warnings
	# This is the disk capacity in %
	stat_hdd_capacity=$(df -h . | tail -n1 | awk '{print $5}')
	# This is the memory left in kB
	stat_mem_free=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
	# FROM: https://stackoverflow.com/questions/9229333/how-to-get-overall-cpu-usage-e-g-57-on-linux#9229580
	# NOTE: I tried different options and used the one that's the fastest. We don't
	# want thr prompt to take too long.
	stat_cpu_usage=$(mpstat | awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }')

	prompt_path="$(basename $(dirname "$PWD"))/$BOLD$(basename "$PWD")"
	prompt_left="${status_color}┈$RESET$status_color░▒▓$REVERSE ${prompt_path} $RESET$status_color▓▒░${status_color}»${RESET}"
	prompt_left_noctrl=$(strip-ansi "$prompt_left")
	prompt_right="${session_type}${scm_summary}$PURPLE_DK⛬ ${process_count} $(date '+%T')$RESET"
	prompt_right_noctrl=$(strip-ansi "$prompt_right")
	prompt_right_padded=$(printf "%$(($COLUMNS-${#prompt_right_noctrl}))s%s" "" "$prompt_right_noctrl")
	echo "${prompt_right_padded}"
	echo "${prompt_left}"
}

export PS1='$(prompt) '
# EOF
