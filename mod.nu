# Tiny snippet manager.
#
# A snippet is a file under the snip directory. The directory layout is
# free — files can sit at the root or nested at any depth. Each snippet is
# identified by its path relative to the snip directory.

# -----------
#  helpers
# -----------

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

def editor [] { $nu.editor? | default $env.EDITOR? | default vim }

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

def pick [opts: record] {
  let items = $in
  let custom = $env.snip_config?.picker?
  if ($custom != null) { return ($items | do $custom $opts) }
  $items | input list --fuzzy --display $opts.display $opts.prompt
}

def fuzzyfind [] {
  $in
  | pick {
      prompt: "snippet"
      display: {|| $in.name }
      preview: {|| $in.content }
    }
  | default { path: "" content: "" }
}


def choose [snip?] {
  if ($snip | is-empty) {return (snips | fuzzyfind)} 
  let matches = (snips | where name =~ $snip)
  if ($matches | length) == 1 {return $matches.0}
  $matches | fuzzyfind
}

def snip-completer [] { snips | get name }

# ----------
#  public
# ----------

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

# Open a snippet in $EDITOR.
export def edit [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  ^(editor) (choose $snip).path
}

# Open the snip directory in $EDITOR.
export def manage [] { ^(editor) (snipdir) }

# List every snippet.
export def ls [
  --content  # include each snippet's content in the output
]: nothing -> table {
  let selected = [
    name
    (if not $content {null} else {'content'})
  ] | compact

  snips | select ...$selected
}
