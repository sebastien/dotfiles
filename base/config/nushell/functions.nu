# Nushell Functions
# Ported from bash func.sh and aliases.sh

# --
# Terminal multiplexer functions (tmux/zellij)
# --

# Get the current term multiplexer (defaults to tmux)
def get-term-multiplexer [] {
    if ("TERM_MULTIPLEXER" in $env) {
        $env.TERM_MULTIPLEXER
    } else if (which zellij | is-not-empty) {
        "zellij"
    } else {
        "tmux"
    }
}

# Whether lazy-tmux integration is enabled and available
def lazy-tmux-enabled [] {
    ("FEATURE_LAZY_TMUX" in $env) and $env.FEATURE_LAZY_TMUX == "1" and (which lazy-tmux | is-not-empty)
}

# List sessions for the current multiplexer
def tlist [] {
    let mux = (get-term-multiplexer)
    match $mux {
        "tmux" => {
            tmux list-session | lines | each { |line| $line | split column ":" | get column1.0 }
        }
        "zellij" => {
            # Strip ANSI codes and get session names
            ^zellij list-sessions | ansi strip | lines | each { |line| $line | split words | first }
        }
        _ => {
            print $"Unknown multiplexer: ($mux)"
        }
    }
}

# Attach to a tmux/zellij session
def tat [session?: string] {
    let mux = (get-term-multiplexer)

    if $mux == "tmux" and (lazy-tmux-enabled) {
        let sessions = (do --ignore-errors {
            tmux list-session | lines | each { |line| $line | split column ":" | get column1.0 }
        } | default [])
        let exact_matches = if ($session | is-empty) {
            []
        } else {
            $sessions | where { |name| $name == $session }
        }
        let exact = if ($exact_matches | is-empty) { null } else { $exact_matches | first }

        if ($exact | is-empty) {
            ^lazy-tmux picker
            return
        }

        tmux attach-session -t $exact
        return
    }
    
    let sid = if ($session | is-empty) {
        # Get the last session
        match $mux {
            "tmux" => {
                tmux list-session | lines | last | split column ":" | get column1.0
            }
            "zellij" => {
                ^zellij list-sessions | ansi strip | lines | last | split words | first
            }
        }
    } else {
        # Find session matching the query
        match $mux {
            "tmux" => {
                let matches = (tmux list-session | lines | find $session)
                if ($matches | is-empty) {
                    null
                } else {
                    $matches | last | split column ":" | get column1.0
                }
            }
            "zellij" => {
                let matches = (^zellij list-sessions | ansi strip | lines | find $session)
                if ($matches | is-empty) {
                    null
                } else {
                    $matches | last | split words | first
                }
            }
        }
    }
    
    if ($sid | is-empty) {
        print $"!!! ERR Could not find a running session: ($session)"
    } else {
        match $mux {
            "tmux" => { tmux attach-session -t $sid }
            "zellij" => { zellij attach $sid }
        }
    }
}

# List sessions, using lazy-tmux when enabled
def tls [] {
    if (get-term-multiplexer) == "tmux" and (lazy-tmux-enabled) {
        ^lazy-tmux list
    } else {
        tlist
    }
}

# Create a new tmux/zellij session
def tnew [name: string] {
    let mux = (get-term-multiplexer)
    let sessions = (match $mux {
        "tmux" => {
            tmux list-session | lines | each { |line| $line | split column ":" | get column1.0 }
        }
        "zellij" => {
            ^zellij list-sessions | ansi strip | lines | each { |line| $line | split words | first }
        }
    })

    let matches = if ($sessions | is-empty) {
        []
    } else {
        $sessions | where { |session| $session | str contains $name }
    }

    let selected = if ($matches | is-empty) {
        $name
    } else if (which fzf | is-not-empty) {
        let options = ([$name] | append $matches | uniq)
        let choice = ($options | str join "\n" | ^fzf --prompt "Select session: " --header "Choose existing session or create requested name")
        if ($choice | is-empty) {
            print "No session selected"
            return
        } else {
            $choice | str trim
        }
    } else {
        $name
    }

    let exists = ($sessions | any { |session| $session == $selected })

    match $mux {
        "tmux" => {
            if $exists {
                tmux attach-session -t $selected
            } else {
                tmux new -s $selected
            }
        }
        "zellij" => {
            if $exists {
                zellij attach $selected
            } else {
                zellij attach --create $selected
            }
        }
    }
}

# --
# Process management functions
# --

# List processes matching a query
def pl [query: string] {
    ps | where name =~ $query or command =~ $query
}

# Kill processes matching a query
def kl [query: string] {
    let procs = (ps | where name =~ $query or command =~ $query)
    if ($procs | is-empty) {
        print $"No processes found matching: ($query)"
    } else {
        $procs | each { |proc|
            print $"Killing ($proc.pid): ($proc.name)"
            kill $proc.pid
        }
        # Show remaining processes
        ps | where name =~ $query or command =~ $query
    }
}

# Find and kill a single process by name (like bash pk)
def pk [query: string] {
    let procs = (ps | where name =~ $query or command =~ $query | first 1)
    if ($procs | is-empty) {
        print $"ERR Can't find process matching: ($query)"
    } else {
        let proc = ($procs | first)
        if (kill $proc.pid | is-empty) {
            print $"OK Process '($query)' pid=($proc.pid) killed"
        } else {
            print $"FAIL Could not kill process '($query)' pid=($proc.pid)"
        }
    }
}

# --
# Terminal utilities
# --

# Set terminal title
def set-term-title [title: string] {
    print -n $"\e]0;($title)\u{0007}"
}

# Show color palette
def palette [] {
    0..255 | each { |c|
        print -n $"(ansi { bg: ($c | into string) }) ($c) "
    }
    print (ansi reset)
}

# EOF
