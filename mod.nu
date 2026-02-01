###########
# helpers #
###########

def basedir [] {
  if ($env.SNIP_SNIPDIR? | is-not-empty) {
    $env.SNIP_SNIPDIR
  } else if ($env.XDG_CONFIG_HOME? | is-not-empty) {
    [$env.XDG_CONFIG_HOME snip] | path join
  } else {
    [$env.HOME .config snip] | path join
  }
}

def snipdir [] {
  [(basedir) snippets] | path join
}

def cfgfile [] {
  [(basedir) config.yaml] | path join
}

def bat-supported [] {
  bat -L | lines | each {$in |  split column ':' lang extensions} | flatten | get extensions | split row ,
}

def editor [] {
  $nu.editor? | default $env.EDITOR | default vim
}

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

def display [c, --raw(-r)] {
  let selected = $in
  if $raw or not $c.extensions?.display?.bat?.enabled? {
    return $selected.content
  }
  let extension = $selected.path | path parse | get extension
  let lang = if ($extension in (bat-supported)) {$extension} else {'txt'}
  $selected.content | bat --decorations=never --color=always --paging=never -l $lang
}

def fuzzyfind [c] {
  let l = $in
  if $c.extensions?.fuzzyfind?.skim?.enabled? {
    (
      $l
      | sk 
      --prompt 'choose a snippet: '
      --preview-window right:70% 
      --format { [$in.category $in.name] | path join }
      --preview { $in | display $c}
    )
  } else {
    $l 
    | input list --fuzzy --display path
  }
  | default {
    path: ""
    content: ""
  }
}

##########
# public #
##########

# returns current config
export def cfg [] { 
  if not ((cfgfile) | path exists) {
    {} | to yaml | save (cfgfile)
  }
  open (cfgfile)
}

# edits the config file
export def "cfg edit" [] { 
  nu -c $"(editor) (cfgfile)"
}

# put snippet to cmdline
export def main [] {
  let c = cfg
  commandline edit -r (snips | fuzzyfind $c | get content)
}

# return a snippet as text
export def text [--raw(-r)] {
  let c = cfg
  snips | fuzzyfind $c | display $c --raw=$raw
}

# edit snip
export def edit [] {
  let c = cfg
  nu -c $"(editor) ((snips | fuzzyfind $c).path)"
}

# manage snips
export def manage [] {
  nu -c $"(editor) (snipdir)"
}

# list snips
export def ls [] {
  snips
}
