#!/bin/bash

if tput setaf 1 &> /dev/null; then
    tput sgr0; # reset colors
	echo "TPUT"
    BOLD=$(tput bold);
    RESET=$(tput sgr0);
    BLACK=$(tput setaf 235)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 142)
    YELLOW=$(tput setaf 214)
    BLUE=$(tput setaf 66)
    PURPLE=$(tput setaf 175)
    CYAN=$(tput setaf 37)
    GRAY=$(tput setaf 246)
    WHITE=$(tput setaf 223)
    ORANGE=$(tput setaf 208)
else
	echo "NO TPUT"
    BOLD='';
    RESET="\e[0m";
    BLACK="\e[1;30m";
    BLUE="\e[1;34m";
    CYAN="\e[1;36m";
    GREEN="\e[1;32m";
    ORANGE="\e[1;33m";
    PURPLE="\e[1;35m";
    RED="\e[1;31m";
    VIOLET="\e[1;35m";
    WHITE="\e[1;37m";
    YELLOW="\e[1;33m";
fi;

# function prompt-setup {
# 	STATUS_COLOR=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
# 	export STATUS_COLOR
# }

function prompt-left {
	STATUS_COLOR=$(if [[ $? == 0 ]]; then echo -n "${BLUE}"; else echo -n "${RED}"; fi)
	prompt_path="$(basename $(dirname "$PWD"))/$BOLD$(basename "$PWD")"
	echo "\[$STATUS_COLOR\]─\[$RESET\]\[$STATUS_COLOR\]░▒▓\[$REVERSE\] ${prompt_path} \[$RESET\]\[$STATUS_COLOR\]▓▒░\[$STATUS_COLOR\] ▷\[$RESET\] "
}

function prompt() {
    # ret_code=$?
	local prompt_left="$(prompt-left)"
	prompt_path="$(basename $(dirname "$PWD"))/\[$BOLD\]$(basename "$PWD")"
    PS1="\[$YELLOW\]\u \[$RESET\]at \[$BLUE\]\H ░▒▓\[$RESET\]in \[$RED\]\w\n\[$YELLOW\]$vim$ret_str▓▒░\\[$RESET\] "
	PS1="\[$STATUS_COLOR\]─\[$RESET\]\[$STATUS_COLOR\]░▒▓\[$REVERSE\] $prompt_path \[$RESET\]\[$STATUS_COLOR\]▓▒░\[$STATUS_COLOR\] ▷\[$RESET\] "
}
export PROMPT_COMMAND=prompt
export PS2="\[$blue\]continue -> \[$reset\]"
