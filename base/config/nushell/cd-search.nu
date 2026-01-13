# Nushell CD Search
# A utility to quickly jump between frequently changed paths
# Uses the cd-store script for all operations

# Store current directory in history
def cd-store [] {
    ^cd-store store $env.PWD
}

# Search and jump to a directory using fzf
def --env z [query?: string] {
    let selection = if ($query | is-empty) {
        (^cd-store search)
    } else {
        (^cd-store search $query)
    }
    
    let selection = ($selection | str trim)
    
    if ($selection | is-empty) {
        # User cancelled or no match
        return
    } else if ($selection | path exists) {
        if ($selection | path type) == "dir" {
            cd $selection
        } else {
            # It's a file, open in editor
            run-external $env.EDITOR $selection
        }
    } else {
        print $"-!- Selected path does not exist anymore: ($selection)"
    }
}

# Get the last visited directory
def cd-last [query?: string] {
    if ($query | is-empty) {
        ^cd-store last
    } else {
        ^cd-store last $query
    }
}

# Restore to the last directory
def --env cd-restore [query?: string] {
    let path = (cd-last $query | str trim)
    cd $path
}

# Show directory log
def cd-log [query?: string] {
    if ($query | is-empty) {
        ^cd-store log
    } else {
        ^cd-store log $query
    }
}

# Prune non-existent paths
def cd-prune [] {
    ^cd-store prune
}

# Show entry count
def cd-entries [] {
    ^cd-store entries
}

# Get log file path
def cd-log-path [] {
    ^cd-store path | str trim
}

# EOF
