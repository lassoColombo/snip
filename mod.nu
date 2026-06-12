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
  glob --no-dir $"(snipdir)/**/*" | each {|file|
    let info = $file | path split | last 2
    {
      category: ($info | first)
      name: ($info | last)
      content: (open -r $file)
      path: $file
    }
  }
}

def fuzzyfind [] {
  $in
  | input list --fuzzy --display {|r| $r.path | path split | last 2 | path join}
  | default {
    path: ""
    content: ""
  }
}

def snip-completer [] {
  snips | each {|s|
    [$s.category $s.name] | path join
  }
}

# ----------
#  public   
# ----------
# put snippet to cmdline
export def main [
  snip?: string@snip-completer
] { 
  let chosen = if ($snip | is-not-empty) {
    snips | where path =~ $snip | first
  } else {
    snips | fuzzyfind
  }
  commandline edit -r $chosen.content
}
# return a snippet as text
export def text [
  snip?: string@snip-completer
] {
  let chosen = if ($snip | is-not-empty) {
    snips | where path =~ $snip | first
  } else {
    snips | fuzzyfind 
  }
  $chosen.content
}
# edit snip
export def edit [
  snip?: string@snip-completer
] {
  let chosen = if ($snip | is-not-empty) {
    snips | where path =~ $snip | first
  } else {
    snips | fuzzyfind
  }
  ^(editor) $chosen.path 
}
# manage snips
export def manage [] { ^(editor) (snipdir) }
# list snips
export def ls [--categorized, --content] { 
  let selected = [
    name
    (if not $content {null} else {content})
  ] | compact

  if not $categorized {return (snips | select category ...$selected)}
  snips
  | group-by category --to-table
  | reduce -f {} {|group, acc|
    $acc | merge { $group.category: ($group.items | select ...$selected) }
  }
}
