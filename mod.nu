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

def pick []: list<any> -> any {
  let items = $in
  let custom = $env.snip_config?.picker?
  if ($custom != null) { return ($items | do $custom) }
  $items | input list --fuzzy --display {|| $in.name } "snippet"
}

def fuzzyfind [] { $in | pick | default { path: "" content: "" } }


def choose [snip?] {
  if ($snip | is-empty) {return (snips | fuzzyfind)} 
  let matches = (snips | where name =~ $snip)
  if ($matches | length) == 1 {return $matches.0}
  $matches | fuzzyfind
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

# Open a snippet in the configured editor.
export def edit [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  editor (choose $snip).path
}

# Open the snip directory in the configured editor.
export def manage [] { editor (snipdir) }

# List every snippet: what it is called, what is in it, and where it lives.
export def ls []: nothing -> table<name: string, content: string, path: string> { snips }
