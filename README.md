# theme-selector.nvim

A Neovim plugin that lets you select and preview colorschemes via a floating window, like Mason does for LSPs.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use 'Pepethefrogger/theme-selector.nvim'
```

## Configuration

Setup lines
```lua
local theme_selector = require('theme-selector')
theme_selector.setup{
    test_on_the_fly = false, -- Default is true, changes configuration temporarily on change
    default_theme = "tokyonight" -- Sets a default colorscheme to load
}

vim.keymap.set('n', '<leader>TT', theme_selector.init_window)
```
