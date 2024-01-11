alias e=nvim
alias l="nvim -R"
if [ -n "$(which eza 2>/dev/null)" ]; then
	alias lst="eza --long --tree"
	alias ls="eza"
fi
alias pk-add="sudo dnf install"
alias pk-rem="sudo dnf uninstall"
alias pk-fd="sudo dnf search"
# alias pk-ls="sudo dpkg -L"
alias ned="nota-edit"
alias open="gnome-open"
alias realias="source $HOME/.config/bash/aliases.sh"
alias do-release-upgrade="sudo dnf --refresh upgrade;sudo dnf system-upgrade --releasever="
alias jsonpp="python3 -m json.tool"
alias mdless="pandoc -s -f markdown -t html \!* | w3m -dump -T text/html"
alias z="cd-search"

# --
# Kills the given process, found by grepping the command name
function pk {
	local process=$(ps aux | grep "$1" | grep -v grep | head -n1)
	if [ -z "$process" ]; then
		echo "ERR Can't find process matching: $1"
	else
		local pid=$(echo $process | awk '{print $2}')
		if kill -9 $pid; then
			echo "OK Process '$1' pid=$pid killed"
		else
			echo "FAIL Could not kill process '$1' pid=$pid"
		fi
	fi
}
# EOF
