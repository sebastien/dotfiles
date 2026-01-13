# --
# # CD Search
#
# A utility to quickly jump between frequently changed paths
# Uses the cd-store script for all operations
#
# --

# Wrapper functions that call cd-store script

function cd-store {
    command cd-store store "$@"
}

function cd-search {
    local selection
    selection=$(command cd-store search "$1")
    if [ -n "$selection" ]; then
        if [ -d "$selection" ]; then
            cd "$selection"
        elif [ -e "$selection" ]; then
            $EDITOR "$selection"
        else
            echo "-!- Selected path does not exist anymore: $selection"
        fi
    fi
}

# Alias z to cd-search
alias z=cd-search

function cd-last {
    command cd-store last "$@"
}

function cd-restore {
    cd "$(cd-last "$1")"
}

function cd-log {
    command cd-store log "$@"
}

function cd-prune {
    command cd-store prune
}

function cd-entries {
    command cd-store entries
}

function cd-prompt-helper {
    cd-store
}

# EOF
