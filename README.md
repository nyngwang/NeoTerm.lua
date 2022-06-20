NeoTerm.lua
-----

Just like the <code>`</code> of VSCode.

Still work in progress, see WARN.

## DEMO

https://user-images.githubusercontent.com/24765272/174507066-f2ff0821-ab75-4768-8734-0d0880deae0d.mov

## Feat.

- Lightweight (<100 lines)
- Visual candy:
  - term-bg-color == in term-mode
  - no term-bg-color == in normal-mode
  - Color is customizable

### WARN

- The current `toggle_keymap` will kill current session on close.
- Fix height instead of relative height


## Config

This plugin requires `NeoNoName.lua`.

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
      -- neo_no_name_keymap = '<M-w>'
      -- term_mode_hl = 'CoolBlack' -- this is #101010
    }
  end
}
```
