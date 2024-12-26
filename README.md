# Pix'em

Converts between **px** and **em**/**rem** units (for example in CSS files).

- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Mappings](#mappings)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim) drop the following into your config, or do the equivalent for your plugin manager of choice:

```lua
{
    "gadkadosh/pixem.nvim",
    config = function()
        require("pixem").setup()
    end
}
```

## Configuration

You can pass a custom config to `setup()`.

The default configuration is:

```lua
config = {
    ---Font size for calculating conversions
    root_font_size = 16,
    ---Convert px to rem. Set to false to convert px to em
    use_rem = true
}
```

## Usage 

Running the vim command `:Pixem` (or the lua function `require("pixem").run_line()`) will search for any valid values on the current line and convert them from px to em/rem or vice versa.

*Note: if mixed units are used conversion will abort.*

## Mappings

The plugin does not set a mapping for you. You can easily add a mapping to your configuration:

``` lua
vim.keymap.set("<leader>p", require("pixem").run_line())
```
