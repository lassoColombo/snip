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

def display [] {
  $in.content
}

def fuzzyfind [] {
  let l = $in
  (
    $in
    | sk 
    --prompt 'choose a snippet: '
    --preview-window right:70% 
    --format { [$in.category $in.name] | path join }
    --preview { $in | display }
  )
}

##########
# public #
##########

# put snippet to cmdline
export def main [] { commandline edit -r (snips | fuzzyfind | get content) }

# bat snip
export def show [] { snips | fuzzyfind | display }

# copy snip to clipboard
export def cp [] { snips | fuzzyfind | get content | pbcopy }

# edit snip
export def edit [] { nu -c $"(editor) ((snips | fuzzyfind).path)" }

# manage snips
export def manage [] { nu -c $"(editor) (snipdir)" }

# list snips
export def ls [] { snips }
