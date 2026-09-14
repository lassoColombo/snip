# Snip

Snip is a little and powerful snippet manager in less than 100 lines of nu.

- Manage your snippets with your preferred editor  
- Select them with your picker of choice  
- Track them with git or jj as part of your configuration  

---
  - [What snip is](#what-snip-is)
    - [Manage your snippets in your preferred editor](#manage-your-snippets-in-your-preferred-editor)
      - [Configure the editor](#configure-the-editor)
    - [Access your snippets with an ergonomic cli](#access-your-snippets-with-an-ergonomic-cli)
      - [Configure the picker](#configure-the-picker)
    - [Track your snippets with git or jj](#track-your-snippets-with-git-or-jj)
      - [Configure the message](#configure-the-message)
  - [Installation](#installation)
  - [Commands](#commands)
    - [`snip edit`](#`snip-edit`)
    - [`snip execute`](#`snip-execute`)
    - [`snip ls`](#`snip-ls`)
    - [`snip manage`](#`snip-manage`)
    - [`snip text`](#`snip-text`)



## What snip is

Snip is a little but powerful snippet manager.  

Snip stores your snippets as regular files.  
It lets you easily track them with git and manage them with your editor of choice.

Snip let you access your snippets with an ergonomic cli.  
You can run your snippets with autocompletion or by selecting them in your favourite picker.

### Manage your snippets in your preferred editor
Snip stores your snippets as regular files on disk, and lets you manage them with your default editor - or any editor of your choice.  
Snippets live by default under `~/.config/snip`. Everything under that directory is a snippet.  
The organization of the snip directory is free: you can group and organize your snippets as you please.

```nu
snip manage # open the snip directory in your configured editor
snip edit <snippet> # open a snippet in your configured editor
snip ls # list your snippets
```

The snip directory follows the xdg directory specification: you can override it by either setting `XDG_CONFIG_HOME` or `SNIP_SNIPDIR`.  

#### Configure the editor

Snip uses by default the editor you configured in `$env.config.buffer_editor` or `$env.EDITOR`.  
If you'd rather use another editor to manage your snippets you can set `$env.snip_config.editor` as follows:
```nu
$env.snip_config = { editor: nvim }
$env.snip_config = { editor: ["emacsclient", "-s", "light", "-t"] } # the snippet (or the snip directory) is appended last.
```

---

### Access your snippets with an ergonomic cli
Snip exposes an ergonomic cli that lets you quickly find a snippet.
The cli is based on the following principles:
- all arguments must provide autocompletion
- if a mandatory argument is not passed the user is required to select its value in the picker

So
```nu
# You can run commands providing all the necessary arguments, and have autocompletion
snip execute nu/ls.nu 

# You can run commands providing no argument. You will be prompted to select one in the picker
snip execute

# You can even run commands providing ambiguous arguments. 
# If your search matches more than a snippet, you will be prompted to select one in the picker
snip execute ls
```

#### Configure the picker

Choosing a snippet uses Nushell's built-in `input list` by default.  
Set `$env.snip_config.picker` to swap the engine.

A picker is **a closure from a list of snippets to one snippet**:

```
list<record<name: string, content: string, path: string>> -> record | null
```

`content` is the body of the snippet, `name` is the relative path to the snip directory and `path` is the absolute path.

`snip ls` returns exactly those records, so a picker is a command you can run by hand against real data:

```nu
def my-picker [] {$in | first} # a picker that simply returns the first item
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

---

### Track your snippets with git or jj

Editing a snippet is a change worth keeping.
Snip keeps it for you: when your editor exits, `snip edit` and `snip manage` commit whatever changed - one commit per invocation.

Nothing happens until you name a tracker:

```nu
$env.snip_config = { auto_track: { tracker: git } }
$env.snip_config = { auto_track: { tracker: jj } }
```

Snip finds the repository by walking up from the snip directory, so snippets kept inside your dotfiles need no setup at all.

It commits the snip directory and nothing else.
With `git` it stages and commits those paths alone, with `jj` it commits the changes to those paths and leaves the rest in your working copy.
Whatever else you had in flight stays where you left it.

It stays quiet when there is nothing to do: no change, no commit.
It speaks up when it cannot do its job: if the snip directory is not in a repository you hear about it, because you asked for tracking.

One requirement: your editor must block until you are done, exactly as `git commit` requires of `$env.EDITOR`.
An editor that returns immediately is committed before you have typed anything - `code --wait`, not `code`.

#### Configure the message

Commits are called `update snippets`. Set `$env.snip_config.auto_track.message` to call them something else:

```nu
$env.snip_config = { auto_track: { tracker: jj, message: "chore(snippets): update" } }
```

## Installation

```nu
# clone into one of your NU_LIB_DIRS
let dest = [($env.NU_LIB_DIRS | first) semver] | path join
git clone git@github.com:lassoColombo/snip.git $dest

# use the module
use snip
snip ls
snip manage
```

<!-- commands-section:start -->
## Commands

| Command                         | Signature                                                       | Description                                                                                           |
| ------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [`snip edit`](#snip-edit)       | `any -> any`                                                    | Open a snippet in the configured editor, then track the change if auto tracking is enabled.           |
| [`snip execute`](#snip-execute) | `any -> any`                                                    | Insert a snippet's content into the current commandline.                                              |
| [`snip ls`](#snip-ls)           | `nothing -> table<name: string, content: string, path: string>` | List every snippet: what it is called, what is in it, and where it lives.                             |
| [`snip manage`](#snip-manage)   | `any -> any`                                                    | Open the snip directory in the configured editor, then track the changes if auto tracking is enabled. |
| [`snip text`](#snip-text)       | `nothing -> string`                                             | Print a snippet's content to stdout.                                                                  |

### `snip edit`

Open a snippet in the configured editor, then track the change if auto tracking is enabled.

**Signature:** `any -> any`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |

### `snip execute`

Insert a snippet's content into the current commandline.

**Signature:** `any -> any`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |

### `snip ls`

List every snippet: what it is called, what is in it, and where it lives.

**Signature:** `nothing -> table<name: string, content: string, path: string>`

### `snip manage`

Open the snip directory in the configured editor, then track the changes if auto tracking is enabled.

**Signature:** `any -> any`

### `snip text`

Print a snippet's content to stdout.

**Signature:** `nothing -> string`

**Parameters**

| Parameter | Type     | Description                                    |
| --------- | -------- | ---------------------------------------------- |
| `snip?`   | `string` | snippet name (regex against the relative path) |
<!-- commands-section:end -->
