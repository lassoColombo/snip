const palette = [cyan green yellow magenta blue purple]

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

def snip-completer [] {
  def headline [content: any]: nothing -> string {
    if ($content | describe) != string {return ""}
    let first = ($content | lines | get 0? | default "")
    if ($first | str starts-with "#") {$first | str replace -r '^#+\s*' ''} else {""}
  }

  def styled [snip: record] {
    let custom = $env.snip_config?.style?
    if ($custom | is-not-empty) {return ($snip | do $custom)}
    let group = ($snip.name | path dirname)
    $palette | get (($group | hash md5 | str substring 0..2 | into int --radix 16) mod ($palette | length))
  }

  {
    completions: (snips | each {|snip| {
      value: $snip.name
      description: (headline $snip.content)
      style: (styled $snip)
    }})
    options: {
      completion_algorithm: "fuzzy"  # similar as `=~` in `choose`
      match_description: true
      sort: false
    }
  }
}

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

# Track the snip directory, but only if asked to.
def auto-track [] {
  if not ($env.snip_config?.auto_track? | default false) { return }
  track
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
  let all = snips
  let exact = ($all | where name == $snip)
  if ($exact | is-not-empty) {return $exact.0}
  let matches = ($all | where name =~ $snip)
  if ($matches | length) == 1 {return $matches.0}
  $matches | pick
}

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

# Record whatever changed in the snip directory with git.
export def track []: nothing -> nothing {
  let toplevel = ^git -C (snipdir) rev-parse --show-toplevel | complete
  if $toplevel.exit_code != 0 { error make --unspanned "not in a repository" }
  let root = $toplevel.stdout | str trim

  if (^git -C $root status --porcelain -- (snipdir) | is-empty) { return }
  let message = $env.snip_config?.commit_message? | default "update snippets"
  ^git -C $root add -- (snipdir)
  ^git -C $root commit --only --quiet --message $message -- (snipdir)
}

# Open a snippet in the configured editor, then track the change if auto tracking is enabled.
export def edit [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  editor (choose $snip).path
  auto-track
}

# Open the snip directory in the configured editor, then track the changes if auto tracking is enabled.
export def manage [] {
  editor (snipdir)
  auto-track
}

# List every snippet: what it is called, what is in it, and where it lives.
export def ls []: nothing -> table<name: string, content: string, path: string> { snips }
