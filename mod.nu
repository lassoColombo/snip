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

def pick [opts: record] {
  let items = $in
  let custom = $env.snip_config?.picker?
  if ($custom != null) { return ($items | do $custom $opts) }
  # `default` would EVALUATE a closure handed to it, so spell the fallback out.
  let display = if ($opts.display? == null) { {|| $in | to text } } else { $opts.display }
  $items | input list --fuzzy --display $display ($opts.prompt? | default "")
}

def render [text: string, name: string] {
  let custom = $env.snip_config?.render?
  if ($custom == null) { return $text }
  $text | do $custom {name: $name}
}

# A snippet's name, clamped to its last few components. Once the preview sits
# BESIDE the list, the list is the narrower half, and a path is worth more from
# its tail than its head: `aws/s3-list-in-bucket.nu` says what
# `work/scratch/aws/s3-list-in-bucket.nu` says. A shorter name passes through
# untouched, so snippets one directory deep — which is all of them, so far —
# read exactly as they did.
#
# This is the row, and skim matches on the row: a component dropped here is a
# component you can no longer type at. Four is chosen to be more depth than the
# tree is ever likely to have, so that stays theoretical.
const NAME_PARTS = 4

def label [name: string]: nothing -> string {
  $name | path split | last $NAME_PARTS | path join
}

# Where the preview pane goes. A snippet is CODE — many short lines — so ROWS are
# what it runs out of. Beside the list it gets the FULL height of the terminal
# where underneath it got three fifths of it, and half of a wide terminal is
# still wider than nine snippet lines in ten. A narrow terminal puts it back
# under the list, where the columns are.
#
# `:wrap` on both, because bat is asked NOT to wrap (see the readme) precisely so
# that the pane can, on word boundaries rather than mid-word.
#
# Under MIN_ROWS there is no room for both, so the preview goes and the list
# takes the whole pane: skim reads a zero-height pane as "no preview at all".
const MIN_ROWS = 16
const WIDE_COLS = 120
const SIDE = 60   # % of a wide terminal the preview takes on the right
const UNDER = 60  # % of a narrow one it takes underneath

def preview-window [] {
  let t = (term size)
  if $t.rows < $MIN_ROWS { "down:0" } else if $t.columns >= $WIDE_COLS {
    $"right:($SIDE)%:wrap"
  } else {
    $"down:($UNDER)%:wrap"
  }
}

def fuzzyfind [] {
  $in
  | pick {
      prompt: "snippet"
      display: {|| label $in.name }
      preview: {|| let s = $in; render $s.content $s.name }
      window: (preview-window)
    }
  | default {
    path: ""
    content: ""
  }
}


def choose [snip?] {
  if ($snip | is-empty) {return (snips | fuzzyfind)} 
  let matches = (snips | where path =~ $snip)
  if ($matches | length) == 1 {return $matches.0}
  $matches | fuzzyfind
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
export def execute [
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
    (if not $content {null} else {'content'})
  ] | compact

  snips | select ...$selected
}
