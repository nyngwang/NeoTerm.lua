local M = {}


function M.create_autocmds()
  -- change bg-color on enter term-mode.
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if not vim.api.nvim_buf_get_option(0, 'buflisted') then return end
      vim.cmd('hi NEO_TERM_COOL_BLACK guibg=#101010')
      vim.cmd('set winhl=Normal:' .. require('neo-term').term_mode_hl)
    end
  })
  -- reset bg-color on leave term-mode.
  vim.api.nvim_create_autocmd({ 'TermLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if not vim.api.nvim_buf_get_option(0, 'buflisted') then return end
      vim.cmd('set winhl=')
    end
  })
  -- auto-insert on enter term-buf.
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term' then return end
      vim.cmd('startinsert')
    end
  })
end


return M
