# Nushell Config File
# Main configuration - sources all modules
# Ported from bash config.sh

# --
# Core settings
# --
$env.config = {
    # Vi editing mode (like bash set -o vi)
    edit_mode: vi
    
    # Show banner on startup
    show_banner: false
    
    # History configuration (matching bash HISTSIZE, HISTCONTROL)
    history: {
        max_size: 32768                # HISTSIZE=32768
        sync_on_enter: true            # Share history between sessions
        file_format: "sqlite"          # Use sqlite for better performance
        isolation: false               # Share across sessions
    }
    
    # Completions
    completions: {
        case_sensitive: false
        quick: true                    # Auto-select when one option remains
        partial: true                  # Allow partial completion
        algorithm: "fuzzy"             # Fuzzy matching
        external: {
            enable: true               # Look in PATH for completions
            max_results: 100
        }
    }
    
    # File size format
    filesize: {
        metric: true
        format: "auto"
    }
    
    # Table display
    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
        header_on_separator: false
    }
    
    # Error display
    error_style: "fancy"
    
    # Hooks
    hooks: {
        # Pre-prompt hook - store directory for cd-search
        pre_prompt: [{ ||
            # Store directory visit for cd-search/z command
            # Uses external cd-store script
            ^cd-store $env.PWD
        }]
        
        # Environment change hook
        env_change: {
            PWD: []
        }
    }
    
    # Menus
    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
        }
    ]
    
    # Keybindings
    keybindings: [
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                    { edit: complete }
                ]
            }
        }
        {
            name: history_menu
            modifier: control
            keycode: char_r
            mode: [emacs, vi_insert, vi_normal]
            event: { send: menu name: history_menu }
        }
        {
            name: escape
            modifier: none
            keycode: escape
            mode: [emacs, vi_normal, vi_insert]
            event: { send: esc }
        }
        # Ctrl+L to clear screen
        {
            name: clear_screen
            modifier: control
            keycode: char_l
            mode: [emacs, vi_insert, vi_normal]
            event: { send: clearscreen }
        }
    ]
    
    # Cursor shapes for vi mode
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }
    
    # Color config
    color_config: {
        separator: white
        leading_trailing_space_bg: { attr: n }
        header: green_bold
        empty: blue
        bool: light_cyan
        int: white
        filesize: cyan
        duration: white
        date: purple
        range: white
        float: white
        string: white
        nothing: white
        binary: white
        cell_path: white
        row_index: green_bold
        record: white
        list: white
        block: white
        hints: dark_gray
        search_result: { bg: red fg: white }
        shape_and: purple_bold
        shape_binary: purple_bold
        shape_block: blue_bold
        shape_bool: light_cyan
        shape_closure: green_bold
        shape_custom: green
        shape_datetime: cyan_bold
        shape_directory: cyan
        shape_external: cyan
        shape_externalarg: green_bold
        shape_filepath: cyan
        shape_flag: blue_bold
        shape_float: purple_bold
        shape_garbage: { fg: white bg: red attr: b }
        shape_globpattern: cyan_bold
        shape_int: purple_bold
        shape_internalcall: cyan_bold
        shape_list: cyan_bold
        shape_literal: blue
        shape_match_pattern: green
        shape_matching_brackets: { attr: u }
        shape_nothing: light_cyan
        shape_operator: yellow
        shape_or: purple_bold
        shape_pipe: purple_bold
        shape_range: yellow_bold
        shape_record: cyan_bold
        shape_redirection: purple_bold
        shape_signature: green_bold
        shape_string: green
        shape_string_interpolation: cyan_bold
        shape_table: blue_bold
        shape_variable: purple
        shape_vardecl: purple
    }
}

# --
# Source all modules
# Note: Order matters - env should be sourced first in env.nu
# --

# Source prompt (defines PROMPT_COMMAND)
source ~/.config/nushell/prompt.nu

# Source aliases
source ~/.config/nushell/aliases.nu

# Source functions
source ~/.config/nushell/functions.nu

# Source cd-search (z command)
source ~/.config/nushell/cd-search.nu

# Source integrations (mise, direnv, etc.)
source ~/.config/nushell/integrations.nu

# --
# Optional integrations
# These files must exist - generate them with the commands shown below
# Uncomment the ones you want to use after generating the init files
# --

# Broot - file navigator
# Generate with: broot --print-shell-function nushell | save -f ~/.config/broot/launcher/nushell/br
# use ~/.config/broot/launcher/nushell/br *

# Mise - polyglot version manager
# Generate with: mkdir ~/.cache/mise; mise activate nu | save -f ~/.cache/mise/init.nu
# source ~/.cache/mise/init.nu

# Zoxide - smarter cd (alternative to cd-search)
# Generate with: mkdir ~/.cache/zoxide; zoxide init nushell | save -f ~/.cache/zoxide/init.nu
# source ~/.cache/zoxide/init.nu

# Starship - cross-shell prompt
# Generate with: mkdir ~/.cache/starship; starship init nu | save -f ~/.cache/starship/init.nu
# source ~/.cache/starship/init.nu

# Direnv - directory-specific environments
# Generate with: mkdir ~/.cache/direnv; direnv hook nu | save -f ~/.cache/direnv/init.nu
# source ~/.cache/direnv/init.nu

# EOF
