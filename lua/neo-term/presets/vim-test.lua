local M = {}


function M.setup()
  vim.g['test#strategy'] = 'nyngwang/NeoTerm.lua'
  -- vim.g['test#python#runner'] = 'pytest'
  vim.g['test#custom_strategies'] = {
    ['nyngwang/NeoTerm.lua'] = function (cmd)
      local term_cur_buf = require('neo-term').buf_open_to_term[vim.api.nvim_get_current_buf()]
      if not term_cur_buf then
        print("NeoTerm.lua: vim-test command cancelled. Create a termbuf for the current buffer first.")
        return
      end
      local channel_term = vim.api.nvim_buf_get_option(term_cur_buf, 'channel')
      vim.api.nvim_chan_send(channel_term, cmd .. '\n')
    end
  }
end


return M
