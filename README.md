NeoTerm.lua
-----

Just like the <code>`</code> of VSCode.

## DEMO



## Config

This plugin requires `NeoNoName.lua`.

```lua
use {
  'nyngwang/NeoTerm.lua',
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
