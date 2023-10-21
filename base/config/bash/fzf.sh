if [ ! -d "$HOME/.fzf" ]; then
	echo "DO ... FZF Not found, installing it"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	echo "DONE!"
fi
# SEE: https://github.com/lincheney/fzf-tab-completion#bash
# if [ ! -d "$HOME/.config/bash/fzf-completion.sh" ]; then
# 	source "$HOME/.config/bash/fzf-completion.sh" 
# 	bind -x '"\t": fzf_bash_completion'
# fi
# EOF
