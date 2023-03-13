<img src="https://neovim.io/logos/neovim-mark-flat.png" align="right" width="100" />

NeoTerm.lua
-----

Now you have two sides for each **buffer**:

1. The buffer itself
2. Its terminal buffer.

and you just use one single command `NeoTermToggle` to switch the side of each one :)


## DEMO

https://user-images.githubusercontent.com/24765272/224787066-a51f18d3-3da7-440d-ab77-349a59aac050.mov


## Feat.

- ~0ms load time (lines ~200)
- No dependency.
- Only add two commands in your pocket: easy to remember.
- Focus on DX:
  - simple `setup`, so always readable.
  - auto enter insert-mode on `BufEnter` the terminal.
  - customizable(`term_mode_hl`) background color on enter termbuf insert-mode. :art:


## Config

```lua
use {
  'nyngwang/NeoTerm.lua',
  config = function ()
    require('neo-term').setup {
      exclude_filetypes = { 'oil' },
      exclude_buftypes = { 'terminal' },
    }
    vim.keymap.set('n', '<M-Tab>', function () vim.cmd('NeoTermToggle') end)
    vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermEnterNormal') end)
  end
}
```
