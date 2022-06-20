NeoTerm.lua
-----

Attach a term-buffer for each window.

## DEMO

https://user-images.githubusercontent.com/24765272/174594232-d00d7584-07a3-434c-9e4d-c0bbeb5dbf56.mov

## Feat.

- Lightweight but powerful (<150 lines)
- The logic is tricky, so let me do it for you
- Zero-config is possible (See **Config** below)
- Put emphasis on UX:
  - See `winhl` == in term-mode, vise versa.
  - Color is customizable (`term_mode_hl`)
  - Auto enter term-mode on `BufEnter`
  - Can switch from normal-mode to term-mode without exit if `NeoNoName.lua` is used
- Layout preserviing (`row`,`col`,`topline` are all kept)


## Config

```lua
use {
  'nyngwang/NeoTerm.lua',
  requires = {
    'nyngwang/NeoNoName.lua'
  },
  config = function ()
    require('neo-term').setup {
      -- toggle_keymap = '<M-Tab>'
      -- exit_term_mode_keymap = '<M-w>'
      -- term_mode_hl = 'CoolBlack' -- this is #101010
    }
  end
}
```
