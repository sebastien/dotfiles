# Nushell Integrations
# Tool integrations ported from bash config.sh and setup.sh

# --
# Mise (polyglot version manager)
# https://mise.jdx.dev/
# --
def setup-mise [] {
    if (which mise | is-not-empty) {
        # Generate and source mise activation
        # Note: In nushell, we need to use the hook system
        print "Mise detected - run 'mise activate nu' and add to config if not already done"
    }
}

# --
# Direnv (directory-specific environments)
# https://direnv.net/
# --
def setup-direnv [] {
    if (which direnv | is-not-empty) {
        # Direnv hook for nushell
        # Note: direnv has native nushell support
        print "Direnv detected - run 'direnv hook nu' and add to config if not already done"
    }
}

# --
# Pyenv (Python version manager)
# https://github.com/pyenv/pyenv
# Note: Pyenv PATH setup is done in env.nu
# --
def setup-pyenv [] {
    # Pyenv paths are set in env.nu during startup
    # This function is kept for compatibility
    null
}

# --
# Broot (file navigator)
# https://dystroy.org/broot/
# --
# Note: Broot integration is handled via 'use' in config.nu
# The br function allows directory navigation

# --
# FZF (fuzzy finder)
# https://github.com/junegunn/fzf
# Note: FZF options should be set in env.nu
# --
def setup-fzf [] {
    # FZF options are set in env.nu during startup
    null
}

# --
# Starship (optional prompt - if you prefer it over custom prompt)
# https://starship.rs/
# --
def setup-starship [] {
    if (which starship | is-not-empty) {
        print "Starship detected - to use it, add to config.nu:"
        print "  use ~/.cache/starship/init.nu"
        print "  mkdir ~/.cache/starship"
        print "  starship init nu | save -f ~/.cache/starship/init.nu"
    }
}

# --
# Zoxide (smarter cd - alternative to cd-search)
# https://github.com/ajeetdsouza/zoxide
# --
def setup-zoxide [] {
    if (which zoxide | is-not-empty) {
        print "Zoxide detected - to use it instead of cd-search, add to config.nu:"
        print "  zoxide init nushell | save -f ~/.cache/zoxide/init.nu"
        print "  source ~/.cache/zoxide/init.nu"
    }
}

# --
# Carapace (shell completion)
# https://carapace.sh/
# --
def setup-carapace [] {
    if (which carapace | is-not-empty) {
        # Carapace provides completions for many commands
        $env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"
        print "Carapace detected for completions"
    }
}

# --
# SSH TTY fix (for nvim remote)
# Note: This should be set in env.nu
# --
def setup-ssh-tty [] {
    # SSH_TTY is set in env.nu during startup
    null
}

# --
# Run all setup functions
# --
def setup-all-integrations [] {
    setup-pyenv
    setup-fzf
    setup-ssh-tty
    
    # Print info about optional integrations
    print "---"
    print "Optional integrations available:"
    setup-mise
    setup-direnv
    setup-starship
    setup-zoxide
    setup-carapace
}

# Auto-run essential setup
setup-pyenv
setup-fzf
setup-ssh-tty

# EOF
