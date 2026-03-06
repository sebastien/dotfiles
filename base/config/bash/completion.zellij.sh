if [ -n "$(which zellij 2>/dev/null)" ]; then
	source <(zellij setup --generate-completion bash)
fi
# EOF
