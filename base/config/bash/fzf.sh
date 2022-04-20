if [ ! -d "$HOME/.fzf" ]; then
	echo "DO ... FZF Not found, installing it"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	echo "DONE!"
fi
# EOF
