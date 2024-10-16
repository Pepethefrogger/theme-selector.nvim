# theme-selector.nvim

A small Neovim plugin that lets you select and preview colorschemes via a floating window.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use 'Pepethefrogger/theme-selector.nvim'
```

## Configuration

The configuration is very simple:
```lua
local theme_selector = require('theme-selector')
theme_selector.setup(false) -- Default is true, displays changes as you move in the menu

vim.keymap.set('n', '<leader>TT', theme_selector.init_window)
```
This simple config will find all of the colorschemes available and list them in a menu.
If you want to go back to using a script for defining the colors, you can use the first option on the list.
