# Nushell Environment Config File
# Ported from bash env.sh and config.sh

# --
# Core environment variables
# --
$env.EDITOR = "nvim"
$env.BROWSER = "firefox"
$env.PAGER = "bat"
$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"
$env.MANPAGER = "less -X"
$env.SINK_DIFF = "nvim -d"
$env.TERM_MULTIPLEXER = "tmux"

# --
# Development paths
# --
$env.GOPATH = ($env.HOME | path join ".local/share/go")
$env.GUIX_LOCPATH = ($env.HOME | path join ".guix-profile/lib/locale")
$env.NPM_PACKAGES = ($env.HOME | path join ".local/share/npm")
$env.DENO_INSTALL = ($env.HOME | path join ".deno")
$env.BUN_INSTALL = ($env.HOME | path join ".bun")
$env.PYENV_ROOT = ($env.HOME | path join ".pyenv")

# PYTHONPATH - only set if not empty
let python_path = ($env.HOME | path join ".local/share/python")
if ($python_path | path exists) {
    $env.PYTHONPATH = $python_path
}

# NODE_PATH
let node_modules_path = ($env.NPM_PACKAGES | path join "lib/node_modules")
if ($node_modules_path | path exists) {
    $env.NODE_PATH = $node_modules_path
}

# DATA_PATH
let data_path = ($env.HOME | path join "Workspace/data")
if ($data_path | path exists) {
    $env.DATA_PATH = $data_path
}

# CDPATH equivalent for nushell (used by some tools)
$env.CDPATH = $".:($env.HOME)/Workspace:($env.HOME)"

# Locale archive (Linux)
$env.LOCALE_ARCHIVE = "/usr/lib/locale/locale-archive"

# Ollama
$env.OLLAMA_API_BASE = "http://127.0.0.1:11434"

# --
# PATH construction
# --

# Start with existing PATH (handle both list and string formats)
$env.PATH = if ($env.PATH | describe | str starts-with "list") {
    $env.PATH
} else {
    $env.PATH | split row (char esep)
}

# Build list of paths to add (only if they exist)
let paths_to_add = [
    ($env.DENO_INSTALL | path join "bin")
    ($env.GOPATH | path join "bin")
    ($env.NPM_PACKAGES | path join "bin")
    ($env.HOME | path join ".cargo/bin")
    ($env.BUN_INSTALL | path join "bin")
    ($env.HOME | path join ".codon/bin")
    ($env.HOME | path join ".nimble/bin")
    ($env.HOME | path join ".local/bin")
    ($env.PYENV_ROOT | path join "bin")
    ($env.PYENV_ROOT | path join "shims")
]

# Add existing paths to PATH
for p in $paths_to_add {
    if ($p | path exists) {
        $env.PATH = ($env.PATH | prepend $p)
    }
}

# Nim path
let nim_path = ($env.HOME | path join ".local/src/Nim")
if ($nim_path | path exists) {
    $env.NIM_PATH = $nim_path
    let nim_bin = ($nim_path | path join "bin")
    if ($nim_bin | path exists) {
        $env.PATH = ($env.PATH | prepend $nim_bin)
    }
}

# Homebrew (macOS)
if ("/opt/homebrew/bin/brew" | path exists) {
    $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")
    $env.PATH = ($env.PATH | prepend "/opt/homebrew/sbin")
    if ("/opt/homebrew/opt/openjdk/bin" | path exists) {
        $env.PATH = ($env.PATH | prepend "/opt/homebrew/opt/openjdk/bin")
    }
}

# --
# Environment variable conversions for PATH
# --
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# --
# Nushell-specific directories
# --
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# --
# FZF options
# --
$env.FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border"

# --
# SSH TTY fix (for nvim remote with Eternal Terminal)
# --
if ("ET_VERSION" in $env) and not ("SSH_TTY" in $env) {
    $env.SSH_TTY = (tty | str trim)
}

# --
# Source cargo environment if it exists
# Note: source is evaluated at parse time, so we can't conditionally source
# If you have ~/.cargo/env.nu, uncomment the line below:
# source ~/.cargo/env.nu

# EOF
