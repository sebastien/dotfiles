# Nushell Aliases
# Ported from bash aliases.sh

# --
# Editor aliases
# --
alias e = nvim
alias l = nvim -R

# --
# File listing with eza (if available, falls back to ls)
# --
def lst [path?: string = "."] {
    if (which eza | is-not-empty) {
        eza --long --tree $path
    } else {
        ls $path
    }
}

# Override ls to use eza if available
def lse [path?: string = "."] {
    if (which eza | is-not-empty) {
        eza $path
    } else {
        ^ls $path
    }
}

# --
# Package management (dnf/Fedora)
# --
alias pk-add = sudo dnf install
alias pk-rem = sudo dnf uninstall
alias pk-fd = sudo dnf search
alias do-release-upgrade = sudo dnf --refresh upgrade

# --
# Tools and utilities
# --
alias ned = nota-edit
alias s = kitten ssh

# JSON pretty print
def jsonpp [] {
    $in | from json | to json --indent 2
}

# Markdown less (using pandoc + w3m)
def mdless [file: string] {
    pandoc -s -f markdown -t html $file | w3m -dump -T text/html
}

# --
# Aider aliases
# --
alias aider-claude = aider --model anthropic/claude-3-opus --edit-format diff

# --
# Directory navigation
# Note: 'z' is defined in cd-search.nu
# --

# --
# Open command (Linux/GNOME)
# --
def open-file [path: string] {
    if (which gnome-open | is-not-empty) {
        gnome-open $path
    } else if (which xdg-open | is-not-empty) {
        xdg-open $path
    } else {
        echo "No open command found (tried gnome-open, xdg-open)"
    }
}

# --
# Reload aliases
# Note: In nushell, you need to restart nu or run: source ~/.config/nushell/aliases.nu
# This is because source requires a parse-time constant path
# --
def realias [] {
    print "To reload aliases, run:"
    print "  source ~/.config/nushell/aliases.nu"
    print "Or restart nushell"
}

# EOF
