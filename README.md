NeoTerm.lua
-----

Attach a term-buffer for each window.

## DEMO

https://user-images.githubusercontent.com/24765272/174594232-d00d7584-07a3-434c-9e4d-c0bbeb5dbf56.mov

## Feat.

- ~0ms load time (=150 lines)
- Built from the best layout-preserving buffer deletion plugin [`nyngwang/NeoNoName.lua`](https://github.com/nyngwang/NeoNoName.lua)
- The logic is fucking hard
  - so you probably don't want to do it yourself (again)
- Focus on UX:
  - Easy to config (you won't forget how to update the config 10 years later)
  - Copy-paste-and-lets-go config below
  - Auto enter insert-mode on `BufEnter` termbuf (Wow)
  - Customizable(`term_mode_hl`) background color on enter termbuf insert-mode (Wow!)
  - Stabilized layout on toggle (`row`,`col`,`topline` are all kept)
- Compatibility with other plugins
  - [`akinsho/bufferline.nvim`](https://github.com/akinsho/bufferline.nvim):
    - Feat. support: Call `BufferLineCycleNext/Prev` from termbuf insert-mode (Wow)
    - Example provided below (Go copy-paste it!)


## Config

```lua
use {
  'nyngwang/NeoTerm.lua',
  requires = { 'nyngwang/NeoNoName.lua' },
  config = function ()
    require('neo-term').setup {
      -- term_mode_hl = 'CoolBlack' -- this is #101010
    }
    vim.keymap.set('n', '<M-Tab>', function ()
      if vim.bo.buftype == 'terminal' then vim.cmd('normal! a')
      else vim.cmd('NeoTermOpen') end
    end, NOREF_NOERR_TRUNC)
    vim.keymap.set('t', '<M-Tab>', function () vim.cmd('NeoTermClose') end, NOREF_NOERR_TRUNC)
    vim.keymap.set('t', '<C-w>', function () vim.cmd('NeoTermEnterNormal') end, NOREF_NOERR_TRUNC)
  end
}
```
