# Nushell Prompt
# Ported from bash prompt.sh - Git/JJ-aware with host icons

# --
# Host icon based on hostname
# --
def get-host-icon [] {
    let hostname = (sys host | get hostname)
    if ($hostname =~ "bench") {
        "🧰 "
    } else if ($hostname =~ "(?i)(renade|osmos)") {
        "💻 "
    } else if ($hostname =~ "central") {
        "🏟️  "
    } else if ($hostname =~ "cerise") {
        "🍒 "
    } else if ($hostname =~ "X1T") {
        "📓 "
    } else if ($hostname =~ "AL-") {
        "🏦 "
    } else {
        ""
    }
}

# --
# Jujutsu (jj) information helpers
# --
def jj-info [] {
    # Check if we're in a jj repo
    let jj_check = (do { jj root } | complete)
    if $jj_check.exit_code != 0 {
        return null
    }
    
    # Get change ID (shortest unique prefix)
    let change_id = (do { jj log --no-pager -r @ --no-graph -T 'change_id.shortest()' } | complete).stdout | str trim
    
    # Get bookmarks
    let bookmarks = (do { jj log --no-pager -r @ --no-graph -T 'bookmarks.join(",")' } | complete).stdout | str trim
    
    # Check for conflicts
    let has_conflict = (do { jj log --no-pager -r @ --no-graph -T 'if(conflict, "!")' } | complete).stdout | str trim
    
    # Check if empty
    let is_empty = (do { jj log --no-pager -r @ --no-graph -T 'if(empty, "○", "●")' } | complete).stdout | str trim
    
    # Get modified files count from diff --stat
    let diff_stat = (do { jj diff --stat --no-pager } | complete).stdout
    let modified_count = if ($diff_stat | str trim | is-empty) {
        0
    } else {
        # Parse "X files changed" from last line
        let last_line = ($diff_stat | lines | last)
        let match = ($last_line | parse "{count} file" | get count?.0?)
        if ($match | is-empty) { 0 } else { $match | into int }
    }
    
    {
        change_id: $change_id
        bookmarks: $bookmarks
        has_conflict: ($has_conflict == "!")
        is_empty: ($is_empty == "○")
        empty_indicator: $is_empty
        modified: $modified_count
    }
}

# --
# Git information helpers
# --
def git-branch-info [] {
    # Check if we're in a git repo
    let git_check = (do { git rev-parse --is-inside-work-tree } | complete)
    if $git_check.exit_code != 0 {
        return null
    }
    
    # Get current branch
    let branch = (do { git branch --show-current } | complete)
    let current_branch = if $branch.exit_code == 0 {
        $branch.stdout | str trim
    } else {
        # Detached HEAD - get short SHA
        (do { git rev-parse --short HEAD } | complete).stdout | str trim
    }
    
    # Get branch count
    let branch_count = (do { git branch --no-color -l } | complete).stdout | lines | length
    
    # Get staged count
    let staged_count = (do { git diff --cached --numstat } | complete).stdout | lines | length
    
    # Get unstaged count
    let unstaged_count = (do { git diff --numstat } | complete).stdout | lines | length
    
    # Get revision count (can fail on new repos)
    let rev_result = (do { git rev-list --count HEAD } | complete)
    let rev_count = if $rev_result.exit_code == 0 {
        $rev_result.stdout | str trim
    } else {
        "0"
    }
    
    {
        branch: $current_branch
        branch_count: $branch_count
        staged: $staged_count
        unstaged: $unstaged_count
        rev_count: $rev_count
    }
}

# Detect SCM type (prefer jj over git)
def scm-type [] {
    let jj_check = (do { jj root } | complete)
    if $jj_check.exit_code == 0 {
        return "⌘"
    }
    
    let git_check = (do { git branch } | complete)
    if $git_check.exit_code == 0 {
        return "±"
    }
    
    let hg_check = (do { hg root } | complete)
    if $hg_check.exit_code == 0 {
        return "☿"
    }
    
    "○"
}

# --
# Left prompt
# --
def create_left_prompt [] {
    let host_icon = (get-host-icon)
    
    # Get path as parent/current
    let current_dir = ($env.PWD | path basename)
    let parent_dir = ($env.PWD | path dirname | path basename)
    
    # Status color based on last exit code (use 256 color codes)
    let status_color = if ($env.LAST_EXIT_CODE == 0) {
        (ansi -e { fg: "#0087ff" })  # Blue (color 33)
    } else {
        (ansi -e { fg: "#af0000" })  # Red (color 124)
    }
    let reset = (ansi reset)
    let bold = (ansi -e { attr: b })
    let reverse = (ansi -e { attr: r })
    
    # Build prompt: hosticon ─░▒▓ path ▓▒░ ▷
    $"($host_icon)($status_color)─($reset)($status_color)░▒▓($reverse) ($parent_dir)/($bold)($current_dir) ($reset)($status_color)▓▒░ ▷($reset) "
}

# --
# Right prompt
# --
def create_right_prompt [] {
    let reset = (ansi reset)
    let purple_dk = (ansi -e { fg: "#5f00af" })   # color 55
    let purple = (ansi -e { fg: "#8700af" })       # color 92
    let purple_lt = (ansi -e { fg: "#d75faf" })    # color 163
    let gold = (ansi -e { fg: "#ffaf00" })         # color 214
    let gold_dk = (ansi -e { fg: "#ff8700" })      # color 208
    let red = (ansi -e { fg: "#af0000" })          # color 124
    let bold = (ansi -e { attr: b })
    
    mut parts = []
    
    # Appenv status (if APPENV_STATUS is set or .appenv exists)
    let has_appenv_file = (".appenv" | path exists)
    if ("APPENV_STATUS" in $env) or $has_appenv_file {
        let appenv_icon = if $has_appenv_file { "▶" } else { "▷" }
        let appenv_status = if ("APPENV_STATUS" in $env) { $env.APPENV_STATUS } else { "" }
        $parts = ($parts | append $" ($gold_dk)($appenv_icon)($gold)($appenv_status)($gold_dk) ")
    }
    
    # SCM information (prefer jj over git)
    let jj_info = (jj-info)
    if ($jj_info != null) {
        # Jujutsu repository
        let scm = (scm-type)
        let bookmark_display = if ($jj_info.bookmarks | is-empty) { "" } else { $" ($purple_lt)($jj_info.bookmarks)" }
        let conflict_display = if $jj_info.has_conflict { $" ($red)!" } else { "" }
        let jj_summary = $"($reset)($purple_dk)⟜($purple)($bold)($jj_info.change_id)($bookmark_display)($reset)($purple_dk) ($scm)($jj_info.empty_indicator)($purple_lt)($bold)+($jj_info.modified)($conflict_display)($reset)"
        $parts = ($parts | append $jj_summary)
    } else {
        # Try Git
        let git_info = (git-branch-info)
        if ($git_info != null) {
            let scm = (scm-type)
            let git_summary = $"($reset)($purple_dk)⟜($purple)($bold)($git_info.branch)($reset)($purple_dk)⋲ ($purple)($git_info.branch_count) ($scm)R($purple_lt)($git_info.rev_count)($bold)+($git_info.unstaged)($reset)($purple)+($git_info.staged)($purple_dk)($reset)"
            $parts = ($parts | append $git_summary)
        }
    }
    
    # Process count and time
    let process_count = (ps | length)
    let current_time = (date now | format date "%H:%M:%S")
    
    # SSH indicator
    let session_type = if ("SSH_CLIENT" in $env) or ("SSH_TTY" in $env) {
        let hostname = (sys host | get hostname)
        $"┈⦗ssh@($hostname)⦘"
    } else {
        ""
    }
    
    $parts = ($parts | append $"($purple_dk)⛬ ($process_count) ○($current_time)($purple)($session_type)($reset)")
    
    $parts | str join ""
}

# --
# Export prompt configuration
# --
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# Prompt indicators (matching bash style)
$env.PROMPT_INDICATOR = {|| "" }  # Already included in left prompt
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| " … " }

# Transient prompt (optional - makes history cleaner)
# Uncomment to use simpler prompt for history
# $env.TRANSIENT_PROMPT_COMMAND = {|| "▷ " }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# EOF
