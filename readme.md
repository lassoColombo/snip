# Snip

A nushell-native snippet manager.

## Installation

1. **Clone the repository** (or copy the module files) into one of your `$env.NU_LIB_DIRS`:
   ```sh
   git clone <your-repo-url> ~/nu_libs/aiai
   ```

2. **Use the module** (e.g., in `~/.config/nushell/config.nu`):

   ```nu
   use snip
   ```

## Dependencies

- [nu plugin skim](https://github.com/idanarye/nu_plugin_skim) is used to fuzzyfind snippets
- [bat](https://github.com/sharkdp/bat) is used to generate a preview of the snippet

## Configuration

Snippets live in the snip directory:
```nu
if ($env.SNIP_SNIPDIR? | is-not-empty) {
$env.SNIP_SNIPDIR
} else if ($env.XDG_CONFIG_HOME? | is-not-empty) {
[$env.XDG_CONFIG_HOME snip] | path join
} else {
[$env.HOME .config snip] | path join
}
```

## Functions

#### snip
puts the content of the selected snippet in the commandline to be executed

#### snip show
returns the content of the selected snippet

#### snip cp
copies a snippet to the clipboard

#### snip edit
opens the selected snippet in the default editor

#### snip manage
opens the default editor in the snip directory

#### snip ls
returns all the snippets in a nushell table

