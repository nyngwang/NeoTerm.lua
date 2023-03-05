local M = {}


function M.create_autocmds()
  -- change bg-color on enter term-mode of NeoTerm.
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term' then return end
      vim.cmd('hi NEO_TERM_COOL_BLACK guibg=#101010')
      vim.cmd('set winhl=Normal:' .. require('neo-term').term_mode_hl)
    end
  })
  -- reset bg-color on leave term-mode of NeoTerm.
  vim.api.nvim_create_autocmd({ 'TermLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term' then return end
      vim.cmd('set winhl=')
    end
  })
  -- auto-insert on enter term-buf of NeoTerm.
  vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term' then return end
      vim.cmd('startinsert')
    end
  })
  -- cancel-insert on exit term-buf of NeoTerm.
  vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term' then return end
      vim.cmd('stopinsert')
    end
  })
end


return M
