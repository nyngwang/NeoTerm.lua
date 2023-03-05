NeoTerm.lua
-----

Attach a terminal for each **buffer**, now with stable toggle and astonishing cursor restoring :)

## DEMO

https://user-images.githubusercontent.com/24765272/174679989-55301311-632a-4abe-9521-1df890f47f54.mov


## Feat.

- ~0ms load time (lines < 160)
- No dependency
- Only contains three commands: Simpel adn Powerful
- Focus on UX:
  - Easy to config (config still readable 100 years later)
    - Copy-paste-and-lets-go config below
  - Stabilized toggle (`row`,`col`,`topline` are all kept)
    - And you can toggle on top to protect your neck (Wow)
  - Auto enter insert-mode on `BufEnter` the terminal (Wow)
  - Customizable(`term_mode_hl`) background color on enter termbuf insert-mode (Wow)


## Config

```lua
local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }

use {
  'nyngwang/NeoTerm.lua',
  config = function ()
    require('neo-term').setup {
      split_on_top = true,
      split_size = 0.45,
      exclude_filetypes = { 'oil' },
      exclude_buftypes = { 'terminal' },
    }
    vim.keymap.set('n', '<M-Tab>', function () vim.cmd('NeoTermHijackToggle') end, G.NOREF_NOERR_TRUNC)
    vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermEnterNormal') end, G.NOREF_NOERR_TRUNC)
  end
}
```
