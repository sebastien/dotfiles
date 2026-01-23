#!/bin/bash

# Local per-shell history configuration
# This makes each terminal session have its own separate command history

# Generate a unique history file per shell session using process ID
# This ensures each terminal window has its own isolated history
if [ -z "$HISTFILE" ]; then
    # Use process ID to create unique history file per session
    LOCAL_HISTFILE="$HOME/.bash_history.$$"
    export HISTFILE="$LOCAL_HISTFILE"
fi

# Set history size - keep it reasonable for per-session history
# 1000 commands per session should be sufficient
HISTSIZE=1000
HISTFILESIZE=1000

# History control settings for local session
# ignoredups: don't store duplicate consecutive commands
# ignorespace: don't store commands that start with space (for privacy)
HISTCONTROL=ignoreboth

# Don't synchronize history with other sessions
# This prevents the prompt from sharing history between terminals
if [ "$BASH_VERSION" ]; then
    # Remove any existing history synchronization from PROMPT_COMMAND
    # We want each session to maintain its own independent history
    if [[ "$PROMPT_COMMAND" == *"history -a"* ]]; then
        # Create new PROMPT_COMMAND without history synchronization
        NEW_PROMPT_COMMAND=""
        IFS=';' read -ra CMD_PARTS <<< "$PROMPT_COMMAND"
        for part in "${CMD_PARTS[@]}"; do
            part=$(echo "$part" | xargs)  # trim whitespace
            if [[ "$part" != "history -a" && "$part" != "history -c" && "$part" != "history -r" ]]; then
                if [ -n "$NEW_PROMPT_COMMAND" ]; then
                    NEW_PROMPT_COMMAND+="; "
                fi
                NEW_PROMPT_COMMAND+="$part"
            fi
        done
        export PROMPT_COMMAND="$NEW_PROMPT_COMMAND"
    fi
fi

# Ensure we don't append to global history
# Each session should start with a clean slate
if [ -f "$HISTFILE" ]; then
    # Clear existing session history file to start fresh
    > "$HISTFILE"
fi

# Set time format for history (optional but useful)
HISTTIMEFORMAT='%F %T '

# Make sure we don't share history between sessions
export HISTFILE HISTSIZE HISTFILESIZE HISTCONTROL HISTTIMEFORMAT