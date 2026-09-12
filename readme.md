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
required. Set `$env.snip_config.picker` to swap the engine.

A picker is **a closure from snippets to one snippet**:

```
list<record<name: string, content: string, path: string>> -> record | null
```

That shape is the whole contract. Snip says nothing about rows, panes, keys or
colours, because everything a picker could want to show is already on the record
it was handed: `content` is the body, `name` is the relative path — which
doubles as the syntax hint for a highlighter — and `path` is the file itself.

`snip ls` returns exactly those records, so a picker is a command you can run by
hand against real data:

```nu
snip ls | do $env.snip_config.picker
```

Write it, run that, watch it work. There is no protocol to obey — if it takes
snippets and gives one back, it is a picker.

Here is one using [skim](https://github.com/lotabout/skim)'s Nushell plugin,
with the body highlighted by [bat](https://github.com/sharkdp/bat) and the syntax
guessed from the snippet's name:

```nu
$env.snip_config = {picker: {||
  let preview = {||
    let s = $in
    $s.content | ^bat --color=always --paging=never --style=plain --file-name $s.name
  }
  $in | sk --format {|| $in.name } --preview $preview --preview-window "down:75%:wrap" --prompt "snippet "
}}
```

Because a picker is just a function over snippets, it composes — and it does not
have to be interactive at all:

```nu
# narrow first, then choose
$env.snip_config = {picker: {|| $in | where name =~ '^git/' | my-picker }}

# never prompt: always the most recently edited snippet
$env.snip_config = {picker: {|| $in | sort-by {|s| ls $s.path | get 0.modified } | last }}
```

<!-- commands-section:start -->
## Commands

| Command                         | Signature           | Description                                              |
| ------------------------------- | ------------------- | -------------------------------------------------------- |
| [`snip edit`](#snip-edit)       | `any -> any`        | Open a snippet in $EDITOR.                               |
| [`snip execute`](#snip-execute) | `any -> any`        | Insert a snippet's content into the current commandline. |
| [`snip ls`](#snip-ls)           | `nothing -> table`  | List every snippet: name, content and path.              |
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

List every snippet: what it is called, what is in it, and where it lives.

**Signature:** `nothing -> table<name: string, content: string, path: string>`

No flags, and all three columns always — this is exactly what a picker is handed
(see [Picker](#picker)), so a picker can be built against `snip ls` at the
prompt. Select what you want when you want less.

**Search terms:** `snippet`, `list`, `ls`, `table`

**Examples**

```nu
# every snippet, in full
snip ls

# just the names
snip ls | get name

# filter by path fragment
snip ls | where name =~ aws

# run your configured picker by hand
snip ls | do $env.snip_config.picker
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
