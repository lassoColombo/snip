# Snip

A snippet manager in a file.

# Table of contents
- [Snip](#snip)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [Picker](#picker)
  - [Commands](#commands)
    - [`snip edit`](#`snip-edit`)
    - [`snip execute`](#`snip-execute`)
    - [`snip ls`](#`snip-ls`)
    - [`snip manage`](#`snip-manage`)
    - [`snip text`](#`snip-text`)

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

Snippets live by default under `~/.config/snip`. You can override the locatioin by setting either the `SNIP_SNIPDIR` or the `XDG_CONFIG_HOME` env variable.

Aside from the default location of the snippets, the picker is the one thing snip lets you swap.

### Picker

Choosing a snippet uses Nushell's built-in `input list` by default — no plugin
required. Set `$env.snip_config.picker` to a closure to swap the engine; it
receives the snippets as pipeline input and one options record
`{prompt, display, preview}`, where `display` and `preview` are closures over a
single snippet (`$in`, no parameter):

```nu
$env.snip_config = {
  picker: {|opts|
    $in | sk --format $opts.display --preview $opts.preview --prompt $opts.prompt
  }
}
```

A picker with a preview pane can then show a snippet's body before you pick it;
the built-in picker has no preview pane and simply ignores `preview`. Layout —
where the pane sits, how it wraps, what keys scroll it — is the picker's
business, not snip's.

So is **styling**: `preview` yields the snippet's text plain, and snip says
nothing more about it. Some engines highlight on their own, some need a wrapper,
some have no preview pane at all — that is a decision only your closure can
make. To pipe the body through something like [bat](https://github.com/sharkdp/bat),
replace `preview` with your own, using the snippet's `name` as the syntax hint:

```nu
$env.snip_config = {
  picker: {|opts|
    let preview = {||
      let snip = $in
      $snip | do $opts.preview | ^bat --color=always --paging=never --style=plain --file-name $snip.name
    }
    $in | sk --format $opts.display --preview $preview --prompt $opts.prompt
  }
}
```

<!-- commands-section:start -->
## Commands

| Command                         | Signature           | Description                                              |
| ------------------------------- | ------------------- | -------------------------------------------------------- |
| [`snip edit`](#snip-edit)       | `any -> any`        | Open a snippet in $EDITOR.                               |
| [`snip execute`](#snip-execute) | `any -> any`        | Insert a snippet's content into the current commandline. |
| [`snip ls`](#snip-ls)           | `nothing -> table`  | List every snippet.                                      |
| [`snip manage`](#snip-manage)   | `any -> any`        | Open the snip directory in $EDITOR.                      |
| [`snip text`](#snip-text)       | `nothing -> string` | Print a snippet's content to stdout.                     |

### `snip edit`

Open a snippet in $EDITOR.

**Signature:** `any -> any`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |

**Search terms:** `snippet`, `edit`, `open`

**Examples**

```nu
# edit a specific snippet
snip edit aws/s3-list

# fuzzy-pick, then edit
snip edit
```

### `snip execute`

Insert a snippet's content into the current commandline.

**Signature:** `any -> any`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |

**Search terms:** `snippet`, `paste`, `commandline`, `fuzzy`

**Examples**

```nu
# fuzzy-pick a snippet and paste it
snip

# match by path fragment
snip aws/s3-list

# match anywhere in the relative path
snip jwt
```

### `snip ls`

List every snippet.

**Signature:** `nothing -> table`

**Flags**

| Flag        | Type     | Description                                  |
| ----------- | -------- | -------------------------------------------- |
| `--content` | `switch` | include each snippet's content in the output |

**Search terms:** `snippet`, `list`, `ls`, `table`

**Examples**

```nu
# list all snippets
snip ls

# list with contents inline
snip ls --content

# filter by path fragment
snip ls | where name =~ aws
```

### `snip manage`

Open the snip directory in $EDITOR.

**Signature:** `any -> any`

**Search terms:** `snippet`, `directory`, `manage`, `browse`

**Examples**

```nu
# open the snip dir for bulk edits
snip manage
```

### `snip text`

Print a snippet's content to stdout.

**Signature:** `nothing -> string`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |

**Search terms:** `snippet`, `print`, `show`, `cat`

**Examples**

```nu
# print to stdout
snip text decode-jwt

# fuzzy-pick, then print
snip text

# pipe into another command
snip text aws/s3-list | clip copy
```
<!-- commands-section:end -->
