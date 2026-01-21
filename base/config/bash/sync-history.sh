# Session-Prioritized Bash History
# ================================
# - Up/Down arrows: current session history first, then other sessions
# - Ctrl-R: fzf search across ALL sessions (current session prioritized)
# - Auto-cleanup: 7-day retention for session files
#
# How it works:
# - Each session saves to ${HISTFILE}.$$ (PID-based file)
# - On each prompt, history is rebuilt with current session loaded LAST
#   (which means it appears FIRST when navigating with up/down)
# - On exit, session history is merged into main HISTFILE
# - Orphaned session files from crashes are auto-merged

# -- History Settings --
export HISTFILESIZE=-1
export HISTSIZE=-1
export HISTCONTROL="ignoreboth:erasedups"
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
shopt -s histappend   # Append to history file instead of overwriting
shopt -s cmdhist      # Save multi-line commands as one entry

# -- Session History Management --

# Rebuild history with session priority on each prompt
# Current session is loaded LAST so it appears FIRST when pressing up arrow
__session_update_history() {
  # Save current session to its dedicated file
  history -a "${HISTFILE}.$$"
  # Clear in-memory history
  history -c
  # Load main history file (oldest, lowest priority)
  history -r "$HISTFILE"
  # Load other active sessions (middle priority)
  for f in $(ls ${HISTFILE}.[0-9]* 2>/dev/null | grep -v "${HISTFILE}.$$\$"); do
    history -r "$f"
  done
  # Load current session LAST (highest priority - appears first with up arrow)
  history -r "${HISTFILE}.$$"
}

# -- Enhanced Ctrl-R with FZF --

# Search ALL history with fzf, current session entries prioritized
__history_fzf_search() {
  # Ensure all histories are loaded
  __session_update_history
  local selected
  # Remove line numbers, reverse order (most recent first), search with fzf
  selected=$(HISTTIMEFORMAT= history | \
    sed 's/^ *[0-9]* *//' | \
    tac | \
    awk '!seen[$0]++' | \
    fzf --height 40% \
        --no-sort \
        --tiebreak=index \
        --query="${READLINE_LINE}" \
        --bind 'ctrl-r:toggle-sort' \
        --prompt="history> ")
  if [[ -n "$selected" ]]; then
    READLINE_LINE="$selected"
    READLINE_POINT=${#READLINE_LINE}
  fi
}

# Bind Ctrl-R to fzf search if fzf is available
if command -v fzf >/dev/null 2>&1; then
  bind -x '"\C-r": __history_fzf_search'
fi

# -- PROMPT_COMMAND Integration --

if [[ "$PROMPT_COMMAND" != *__session_update_history* ]]; then
  export PROMPT_COMMAND="__session_update_history; $PROMPT_COMMAND"
fi

# -- Session Cleanup on Exit --

# Merge session history into main history file on clean exit
__merge_session_history() {
  if [[ -e "${HISTFILE}.$$" ]]; then
    cat "${HISTFILE}.$$" >> "$HISTFILE"
    \rm -f "${HISTFILE}.$$"
  fi
}
trap __merge_session_history EXIT

# -- Orphaned Session Recovery --

# Detect and merge history files from crashed sessions
__cleanup_orphaned_sessions() {
  local active_pids
  active_pids=$(pgrep -x bash 2>/dev/null || pgrep bash 2>/dev/null || echo "")
  
  for f in "${HISTFILE}".[0-9]*; do
    [[ -f "$f" ]] || continue
    local pid="${f##*.}"
    # Skip current session
    [[ "$pid" == "$$" ]] && continue
    # Check if PID is still active
    if ! echo "$active_pids" | grep -q "^${pid}$"; then
      echo "Merging orphaned history: $(basename "$f")"
      cat "$f" >> "$HISTFILE"
      \rm -f "$f"
    fi
  done
}
__cleanup_orphaned_sessions

# -- Auto-Cleanup Old Session Files (7 days) --

find "$(dirname "$HISTFILE")" -maxdepth 1 \
  -name "$(basename "$HISTFILE").[0-9]*" \
  -mtime +7 \
  -delete 2>/dev/null

# EOF
