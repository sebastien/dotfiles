# Nushell Config File
#
# version = "0.86.0"

# For more information on defining custom themes, see
# And here is the theme collection
# https://www.nushell.sh/book/coloring_and_theming.html
# https://github.com/nushell/nu_scripts/tree/main/themes

$env.config = {
    edit_mode: vi
     history: {
         sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
     }
     completions: {
          algorithm: "fuzzy"    # prefix or fuzzy
#         case_sensitive: false
#         quick: true    # set this to false to prevent auto-selecting completions when only one remains
#         partial: true    # set this to false to prevent partial filling of the prompt
#         external: {
#             enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
#             max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
#             completer: null # check 'carapace_completer' above as an example
         }
     }

# EOF

use '~/.config/broot/launcher/nushell/br' *
source "$HOME/.cargo/env.nu"
