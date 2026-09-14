def basedir [] {
  if ($env.SNIP_SNIPDIR? | is-not-empty) {
    $env.SNIP_SNIPDIR
  } else if ($env.XDG_CONFIG_HOME? | is-not-empty) {
    [$env.XDG_CONFIG_HOME snip] | path join
  } else {
    [$env.HOME .config snip] | path join
  }
}

def snipdir [] { [(basedir) snippets] | path join }

# Open `target` with the configured editor.
def editor [target: string] {
  let configured = [
    $env.snip_config?.editor?
    $env.config?.buffer_editor?
    $env.EDITOR?
  ] | where {|it| $it | is-not-empty }
  if ($configured | is-empty) { error make --unspanned "no editor configured" }

  let argv = if ($configured | first | describe | str starts-with "list") {
    $configured | first 
  } else {
    [($configured | first)] 
  } | append $target

  ^($argv | first) ...($argv | skip 1)
}

def snips [] {
  let root = (snipdir)
  glob --no-dir $"($root)/**/*" | each {|file|
    {
      name: ($file | path relative-to $root)
      content: (open -r $file)
      path: $file
    }
  }
}

# A tracker is a closure that records the snip directory under `message`.
def trackers [] {
  {
    git: {|message|
      let toplevel = ^git -C (snipdir) rev-parse --show-toplevel | complete
      if $toplevel.exit_code != 0 { error make --unspanned "not in a repository" }
      let root = $toplevel.stdout | str trim

      if (^git -C $root status --porcelain -- (snipdir) | is-empty) { return }
      ^git -C $root add -- (snipdir)
      ^git -C $root commit --only --quiet --message $message -- (snipdir)
    }
    jj: {|message|
      cd (snipdir)
      if (^jj root | complete).exit_code != 0 { error make --unspanned "not in a repository" }

      if (^jj diff --summary . | is-empty) { return }
      ^jj commit --quiet --message $message .
    }
  }
}

# Track whatever changed in the snip directory, if asked to.
def track [] {
  if ($env.snip_config?.auto_track? | is-empty) { return }
  let trackers = (trackers)
  let tracker = $env.snip_config.auto_track.tracker? | default "git"
  if ($tracker not-in ($trackers | columns)) {
    error make --unspanned $"($tracker) is not a supported tracker"
  }
  do ($trackers | get $tracker) ($env.snip_config.auto_track.message? | default "update snippets")
}

def pick [] {
  let items = $in
  let custom = $env.snip_config?.picker?
  if ($custom | is-not-empty) { 
    $items | do $custom
  } else {
    $items | input list --fuzzy --display {|| $in.name } "snippet"
  }
  | default { path: "" content: "" } 
}

def choose [snip?] {
  if ($snip | is-empty) {return (snips | pick)} 
  let matches = (snips | where name =~ $snip)
  if ($matches | length) == 1 {return $matches.0}
  $matches | pick
}

def snip-completer [] { snips | get name }

# Insert a snippet's content into the current commandline.
export def execute [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  commandline edit -r (choose $snip).content
}

# Print a snippet's content to stdout.
export def text [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
]: nothing -> string {
  (choose $snip).content
}

# Open a snippet in the configured editor, then track the change if auto tracking is enabled.
export def edit [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  editor (choose $snip).path
  track
}

# Open the snip directory in the configured editor, then track the changes if auto tracking is enabled.
export def manage [] {
  editor (snipdir)
  track
}

# List every snippet: what it is called, what is in it, and where it lives.
export def ls []: nothing -> table<name: string, content: string, path: string> { snips }
