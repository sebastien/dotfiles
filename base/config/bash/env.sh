export EDITOR=nvim
export PAGER=bat
export GOPATH=$HOME/.local/share/go
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
export NPM_PACKAGES="$HOME/.local/share/npm"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export DENO_INSTALL="$HOME/.deno"
export BUN_INSTALL="$HOME/.bun"
export SINK_DIFF="nvim -d"
export PATH="$DENO_INSTALL/bin:$GOPATH/bin:$NPM_PACKAGES/bin/:$HOME/.cargo/bin:$BUN_INSTALL/bin:$HOME/.codon/bin:$PATH"
# EOF
