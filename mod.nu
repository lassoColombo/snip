# Tiny snippet manager.
#
# A snippet is just a file under the snip directory. The directory layout is
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

def fuzzyfind [] {
  $in
  | input list --fuzzy --display {|r| $r.name}
  | default {
    path: ""
    content: ""
  }
}


def choose [snip?] {
  if ($snip | is-empty) {snips | fuzzyfind} else {
    (snips | where path =~ $snip).0
  }
}

def snip-completer [] { snips | get name }

# ----------
#  public
# ----------

# Insert a snippet's content into the current commandline.
#
# With no argument, opens the fuzzy picker. With an argument, matches it as a
# regex against snippet paths and uses the first hit.
@search-terms snippet paste commandline fuzzy
@example "fuzzy-pick a snippet and paste it" { snip }
@example "match by path fragment" { snip aws/s3-list }
@example "match anywhere in the relative path" { snip jwt }
export def main [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  commandline edit -r (choose $snip).content
}

# Print a snippet's content to stdout.
@search-terms snippet print show cat
@example "print to stdout" { snip text decode-jwt }
@example "fuzzy-pick, then print" { snip text }
@example "pipe into another command" { snip text aws/s3-list | clip copy }
export def text [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
]: nothing -> string {
  (choose $snip).content
}

# Open a snippet in $EDITOR.
@search-terms snippet edit open
@example "edit a specific snippet" { snip edit aws/s3-list }
@example "fuzzy-pick, then edit" { snip edit }
export def edit [
  snip?: string@snip-completer  # snippet name (regex against the relative path)
] {
  ^(editor) (choose $snip).path
}

# Open the snip directory in $EDITOR, for bulk management
# (creating, renaming, deleting snippets).
@search-terms snippet directory manage browse
@example "open the snip dir for bulk edits" { snip manage }
export def manage [] { ^(editor) (snipdir) }

# List every snippet.
#
# By default returns a table of `{name}`. With `--content`, includes the file
# contents alongside the name.
@search-terms snippet list ls table
@example "list all snippets" { snip ls }
@example "list with contents inline" { snip ls --content }
@example "filter by path fragment" { snip ls | where name =~ aws }
export def ls [
  --content  # include each snippet's content in the output
]: nothing -> table {
  let selected = [
    name
    (if not $content {null} else {content})
  ] | compact

  snips | select ...$selected
}
