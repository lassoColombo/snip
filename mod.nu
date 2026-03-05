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

def snipdir [] { [(basedir) snippets] | path join }

def editor [] { $nu.editor? | default $env.EDITOR | default vim }

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
  | input list --fuzzy --display path
  | default {
    path: ""
    content: ""
  }
}

##########
# public #
##########

# put snippet to cmdline
export def main [] { commandline edit -r (snips | fuzzyfind | get content) }
# return a snippet as text
export def text [] { (snips | fuzzyfind).content }
# edit snip
export def edit [] { ^(editor) (snips | fuzzyfind).path }
# manage snips
export def manage [] { ^(editor) (snipdir) }
# list snips
export def ls [] { snips }
