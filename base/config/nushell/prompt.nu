# Nushell Prompt
# Keeps prompt rendering cheap by avoiding repeated external probes.

def get-host-icon [hostname: string] {
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

if not ("NU_PROMPT_HOSTNAME" in $env) {
    $env.NU_PROMPT_HOSTNAME = (sys host | get hostname)
}

if not ("NU_PROMPT_HOST_ICON" in $env) {
    $env.NU_PROMPT_HOST_ICON = (get-host-icon $env.NU_PROMPT_HOSTNAME)
}

if not ("NU_PROMPT_SHELL_ICON" in $env) {
    $env.NU_PROMPT_SHELL_ICON = "🌊 "
}

if not ("NU_PROMPT_SCM_CACHE_TTL_MS" in $env) {
    $env.NU_PROMPT_SCM_CACHE_TTL_MS = 1500
}

def jj-info [] {
    let root = (do { jj root } | complete)
    if $root.exit_code != 0 {
        return null
    }

    let jj_root = ($root.stdout | str trim)
    if (($jj_root | is-empty) or not (($jj_root | path join ".jj") | path exists)) {
        return null
    }

    let template = 'change_id.shortest() ++ "|" ++ bookmarks.join(",") ++ "|" ++ description.first_line() ++ "|" ++ if(conflict, "!", "") ++ "|" ++ if(empty, "○", "●")'
    let info = (do {
        jj log --no-pager -r @ --no-graph -T $template
    } | complete)

    if $info.exit_code != 0 {
        return null
    }

    let fields = ($info.stdout | str trim | split row "|")
    if (($fields | length) < 5) {
        return null
    }

    let diff_stat = (do { jj diff --stat --no-pager } | complete)
    let modified_count = if $diff_stat.exit_code != 0 {
        0
    } else {
        let line_count = ($diff_stat.stdout | lines | length)
        if $line_count > 1 { $line_count - 1 } else { 0 }
    }

    let current_bookmark = (
        ($fields | get 1)
        | split row ","
        | where {|bookmark| $bookmark | is-not-empty }
        | each {|bookmark| $bookmark | str replace -r '\*$' '' }
        | append ""
        | first
    )
    let ancestor_bookmark = if ($current_bookmark | is-empty) {
        let ancestor = (do {
            jj log --no-pager -r 'heads(::@ & bookmarks())' --no-graph -T 'bookmarks.join(",")'
        } | complete)

        if $ancestor.exit_code == 0 {
            (
                $ancestor.stdout
                | str trim
                | split row ","
                | where {|bookmark| $bookmark | is-not-empty }
                | each {|bookmark| $bookmark | str replace -r '\*$' '' }
                | append ""
                | first
            )
        } else {
            ""
        }
    } else {
        ""
    }

    {
        change_id: ($fields | get 0)
        bookmark: (if ($current_bookmark | is-not-empty) { $current_bookmark } else { $ancestor_bookmark })
        has_description: ((($fields | get 2) | str trim | is-not-empty))
        has_conflict: (($fields | get 3) == "!")
        empty_indicator: ($fields | get 4)
        modified: $modified_count
    }
}

def git-info [] {
    let jj_root = (do { jj root } | complete)
    if $jj_root.exit_code == 0 {
        let root = ($jj_root.stdout | str trim)
        if (($root | is-not-empty) and (($root | path join ".jj") | path exists)) {
            return null
        }
    }

    let status = (do {
        git status --porcelain=v2 --branch
    } | complete)

    if $status.exit_code != 0 {
        return null
    }

    let lines = ($status.stdout | lines)
    let branch_line = ($lines | where {|line| $line | str starts-with "# branch.head " } | first)
    let branch_name = (
        $branch_line
        | str replace "# branch.head " ""
        | str replace "(detached)" "HEAD"
        | str trim
    )

    let entries = ($lines | where {|line| not ($line | str starts-with "#") })
    let staged = (
        $entries
        | where {|line|
            let x = ($line | str substring 2..3)
            $x != "."
        }
        | length
    )
    let unstaged = (
        $entries
        | where {|line|
            let y = ($line | str substring 3..4)
            $y != "."
        }
        | length
    )

    {
        branch: $branch_name
        staged: $staged
        unstaged: $unstaged
    }
}

def build-scm-prompt [
    reset: string
    purple_dk: string
    purple: string
    purple_lt: string
    red: string
    bold: string
] {
    let jj = (jj-info)
    if ($jj != null) {
        let jj_ref = if ($jj.bookmark | is-empty) {
            $jj.change_id
        } else {
            $"($jj.change_id):($jj.bookmark)"
        }
        let missing_description = if $jj.has_description { "" } else { "?" }
        let modified_marker = if $jj.modified > 0 { "+" } else { "" }
        let conflict_display = if $jj.has_conflict { $" ($red)!" } else { "" }
        return $"($reset)($purple_dk)[jj ($purple)($bold)($jj_ref)($missing_description)($modified_marker)($purple_dk)]($reset)($conflict_display)"
    }

    let git = (git-info)
    if ($git != null) {
        let modified_marker = if (($git.staged + $git.unstaged) > 0) { "+" } else { "" }
        return $"($reset)($purple_dk)[git ($purple)($bold)($git.branch)($modified_marker)($purple_dk)]($reset)"
    }

    ""
}

def get-scm-prompt [
    reset: string
    purple_dk: string
    purple: string
    purple_lt: string
    red: string
    bold: string
] {
    let now_ms = (date now | format date "%s%3f" | into int)
    let cached_pwd = ($env | get -i NU_PROMPT_SCM_CACHE_PWD)
    let cached_at = ($env | get -i NU_PROMPT_SCM_CACHE_AT)
    let cached_value = ($env | get -i NU_PROMPT_SCM_CACHE_VALUE)

    if (
        ($cached_pwd | is-not-empty)
        and ($cached_at | is-not-empty)
        and ($cached_value | is-not-empty)
        and ($cached_pwd == $env.PWD)
        and (($now_ms - $cached_at) < $env.NU_PROMPT_SCM_CACHE_TTL_MS)
    ) {
        return $cached_value
    }

    let scm_prompt = (build-scm-prompt $reset $purple_dk $purple $purple_lt $red $bold)
    $env.NU_PROMPT_SCM_CACHE_PWD = $env.PWD
    $env.NU_PROMPT_SCM_CACHE_AT = $now_ms
    $env.NU_PROMPT_SCM_CACHE_VALUE = $scm_prompt
    $scm_prompt
}

def create_left_prompt [] {
    let current_dir = ($env.PWD | path basename)
    let parent_dir = ($env.PWD | path dirname | path basename)

    let status_color = if ($env.LAST_EXIT_CODE == 0) {
        (ansi -e { fg: "#0087ff" })
    } else {
        (ansi -e { fg: "#af0000" })
    }
    let reset = (ansi reset)
    let bold = (ansi -e { attr: b })
    let reverse = (ansi -e { attr: r })

    $"($env.NU_PROMPT_HOST_ICON)($status_color)─($reset)($status_color)░▒▓($reverse) ($parent_dir)/($bold)($current_dir) ($reset)($status_color)▓▒░ ▷($reset) "
}

def create_right_prompt [] {
    let reset = (ansi reset)
    let purple_dk = (ansi -e { fg: "#5f00af" })
    let purple = (ansi -e { fg: "#8700af" })
    let purple_lt = (ansi -e { fg: "#d75faf" })
    let gold = (ansi -e { fg: "#ffaf00" })
    let gold_dk = (ansi -e { fg: "#ff8700" })
    let red = (ansi -e { fg: "#af0000" })
    let bold = (ansi -e { attr: b })

    mut parts = []

    let has_appenv_file = (".appenv" | path exists)
    if ("APPENV_STATUS" in $env) or $has_appenv_file {
        let appenv_icon = if $has_appenv_file { "▶" } else { "▷" }
        let appenv_status = if ("APPENV_STATUS" in $env) { $env.APPENV_STATUS } else { "" }
        $parts = ($parts | append $" ($gold_dk)($appenv_icon)($gold)($appenv_status)($gold_dk) ")
    }

    let scm_prompt = (get-scm-prompt $reset $purple_dk $purple $purple_lt $red $bold)
    if ($scm_prompt | is-not-empty) {
        $parts = ($parts | append $scm_prompt)
    }

    let current_time = (date now | format date "%H:%M:%S")
    let session_type = if ("SSH_CLIENT" in $env) or ("SSH_TTY" in $env) {
        $"($purple)┈⦗ssh@($env.NU_PROMPT_HOSTNAME)⦘"
    } else {
        ""
    }
    let tmux_type = if ("TMUX" in $env) {
        $"($purple) ◫"
    } else {
        ""
    }

    $parts = ($parts | append $"($purple_dk)○($current_time)($purple)($session_type)($tmux_type)($env.NU_PROMPT_SHELL_ICON)($reset)")
    $parts | str join ""
}

$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| " ... " }
