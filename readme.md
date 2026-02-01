# Snip

A nushell-native snippet manager.

<video controls width="700">
  <source src="docs/demo.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Installation

1. **Clone the repository** (or copy the module files) into one of your `$env.NU_LIB_DIRS`:
   ```sh
   git clone <your-repo-url> ~/nu_libs/aiai
   ```

2. **Use the module** (e.g., in `~/.config/nushell/config.nu`):

   ```nu
   use snip
   ```

## Configuration

Snippets and config file live in the snip directory:
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

#### snip manage
opens the default editor in the snip directory

#### snip edit
opens the selected snippet in the default editor

#### snip text
returns the content of the selected snippet

#### snip ls
returns all the snippets in a nushell table

#### snip cfg
returns the config file

#### snip cfg edit
opens the config file in the default editor

## Integration

Snip is natively integrated with some popular external tools that enhance its functionalities. Those integrations can be enabled by editing the config file

### [Nu plugin skim](https://github.com/idanarye/nu_plugin_skim)

the nu plugin skim is used to provide a better fuzzyfinding experience by displaying the snippets in a preview.  
It can be enabled in the config file as follows:
```yaml
extensions:
  fuzzyfind:
    skim:
      enabled: true
```


### [bat](https://github.com/sharkdp/bat) is used to generate a preview of the snippet

bat is used to provide a syntax-highlighted preview of the snippets.  
It can be enabled in the config file as follows:

```yaml
extensions:
  display:
    bat:
      enabled: true
```
