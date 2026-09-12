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

def editor [] { $env.config?.buffer_editor? | default $env.EDITOR? | default vim }

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

# A picker is a closure from snippets to one snippet: the records `snips` builds
# in, one of them out, or null when nothing was chosen. That shape IS the whole
# contract. snip says nothing about rows, panes, keys or colours — everything a
# picker could want to show is already on the record it was handed, and `snip ls`
# hands you the same records to build one against.
#
# With nothing configured this is Nushell's built-in `input list`, which is why
# snip needs no plugin.
def pick []: list<any> -> any {
  let items = $in
  let custom = $env.snip_config?.picker?
  if ($custom != null) { return ($items | do $custom) }
  $items | input list --fuzzy --display {|| $in.name } "snippet"
}

def fuzzyfind [] {
  $in | pick | default { path: "" content: "" }
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

# List every snippet: what it is called, what is in it, and where it lives.
export def ls []: nothing -> table<name: string, content: string, path: string> { snips }
