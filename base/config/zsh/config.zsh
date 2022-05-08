source ~/.config/bash/prompt.sh
# NOTE: ZSH has some issues with the colors in the RPROMPT
PS1="$(prompt-setup)$(strip-ansi $(prompt-left))"
RPROMPT="$(strip-ansi $(prompt-right))"
# EOF
