export EDITOR=nvim
export PAGER=bat
export GOPATH=$HOME/.local/share/go
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
export NPM_PACKAGES="$HOME/.local/share/npm"
export PYTHONPATH="$HOME/.local/share/python:$PYTHONPATH"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export DENO_INSTALL="$HOME/.deno"
export BUN_INSTALL="$HOME/.bun"
export SINK_DIFF="nvim -d"
export TERM_MULTIPLEXER=tmux
if [ -e "$HOME/Workspace/data" ]; then
	export DATA_PATH="$HOME/Workspace/data"
fi
LOCAL_PATH="$DENO_INSTALL/bin:$GOPATH/bin:$NPM_PACKAGES/bin/:$HOME/.cargo/bin:$BUN_INSTALL/bin:$HOME/.codon/bin:$HOME/.nimble/bin"
if [ -e "$HOME/.local/src/Nim" ]; then
	export NIM_PATH="$HOME/.local/src/Nim"
	LOCAL_PATH="$LOCAL_PATH:$NIM_PATH/bin"
fi
export PATH="$LOCAL_PATH:$PATH"

function use-openai {
	export OPENAI_API_KEY="$OPENAI_TOKEN"
	export OPENAI_API_BASE=""
}

function use-openrouter {
	export OPENAI_API_KEY="$OPENAI_TOKEN"
	export OPENAI_API_BASE=""
}

use-openai
# EOF
