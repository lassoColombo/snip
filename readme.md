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

A picker is **a closure from a list of snippets to one snippet**:

```
list<record<name: string, content: string, path: string>> -> record | null
```

`content` is the body of the snippet, `name` is the relative path to the snip directory and `path` is the absolute path.

`snip ls` returns exactly those records, so a picker is a command you can run by hand against real data:

```nu
def my-picker [] {}
snip ls | my-picker
```

Write it, run that, watch it work. If it takes snippets and gives one back, it is a picker.
Here is one example using [skim](https://github.com/lotabout/skim)'s Nushell plugin.

```nu
$env.snip_config = {picker: {||
  (
    $in | sk 
        --format { $in.name } 
        --preview { $in.content } 
        --preview-window "down:75%:wrap" 
        --prompt "snippet "
  )
}}
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
