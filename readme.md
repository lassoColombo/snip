# Snip

A snippet manager in a file.

## Installation

1. **Clone the repository** (or copy the module files) into one of your `$env.NU_LIB_DIRS`:
   ```sh
   git clone git@github.com:lassoColombo/snip.git ~/nu_libs/aiai
   ```

2. **Use the module** (e.g., in `~/.config/nushell/config.nu`):

   ```nu
   use snip
   ```

## Configuration

Snippets file live in the snip directory:
```nu
if ($env.SNIP_SNIPDIR? | is-not-empty) {
$env.SNIP_SNIPDIR
} else if ($env.XDG_CONFIG_HOME? | is-not-empty) {
[$env.XDG_CONFIG_HOME snip] | path join
} else {
[$env.HOME .config snip] | path join
}
```

### Picker

Choosing a snippet uses Nushell's built-in `input list` by default — no plugin
required. Set `$env.snip_config.picker` to a closure to swap the engine; it
receives the snippets as pipeline input and one options record
`{prompt, display, preview}`, where `display` and `preview` are closures
over a single snippet (`$in`, no parameter):

```nu
$env.snip_config = {
  picker: {|opts|
    $in | sk --format $opts.display --preview $opts.preview --prompt $opts.prompt
  }
}
```

A picker with a preview pane (like [skim](https://github.com/lotabout/skim) above,
via `nu_plugin_skim`) can then show a snippet's body before you pick it. The
built-in picker has no preview pane and simply ignores `preview`. Layout —
where the preview pane sits, how it wraps, what keys scroll it — is the
picker's business, not snip's, so it belongs in your closure.

Rows are clamped to their last 4 path components, so a deeply nested snippet
still fits a picker that only gets half the screen. Note that a picker matches
on the row, so a component dropped there is a component you can no longer type
at.

### Syntax highlighting

Snippet bodies are shown as plain text by default. Set `$env.snip_config.render`
to a closure to style them; it receives the text as pipeline input and a record
`{name}` — the snippet's path, for guessing the syntax:

```nu
$env.snip_config = {
  render: {|opts|
    $in | ^bat --color=always --paging=never --style=plain --file-name $opts.name
  }
}
```

Both hooks are independent: configure one, the other, or neither.

## Functions

##### snip
puts the content of the selected snippet in the commandline to be executed

##### snip manage
opens the default editor in the snip directory

##### snip edit
opens the selected snippet in the default editor

##### snip text
returns the content of the selected snippet

##### snip ls
returns all the snippets in a nushell table
