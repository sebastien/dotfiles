# Do we have appenv?
APPENV_DEV_PATH=$HOME/Workspace/Perso/appenv
if [ ! -e "$APPENV_DEV_PATH/bin/appenv.bash" ] && [ ! -e "$HOME/.local/bin/appenv.bash" ]; then
	curl https://raw.githubusercontent.com/sebastien/appenv/master/install.sh | bash
fi

if [ ! -d "$HOME/.fzf" ]; then
	echo "DO ... FZF Not found, installing it"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	echo "DONE!"
fi

APP_MISE="$(which mise 2>/dev/null)"
if [ -n "$APP_MISE" ] && [ -e "$APP_MISE" ]; then
	eval "$($APP_MISE activate bash)"
fi

# SEE: https://github.com/lincheney/fzf-tab-completion#bash
# if [ ! -d "$HOME/.config/bash/fzf-completion.sh" ]; then
# 	source "$HOME/.config/bash/fzf-completion.sh"
# 	bind -x '"\t": fzf_bash_completion'
# fi
#

# EOF
