local M = {}


local function create_hotfix_autocmds()
  -- for the upstream issue: https://github.com/neovim/neovim/issues/5176.
  -- NOTE: this doesn't include the case of rpc, which is `WinClosed` on a normal buffer.
  vim.api.nvim_create_autocmd({ 'WinClosed' }, {
    group = 'neo-term.lua',
    callback = function (args)
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end

      if -- it's another buffer/win being closed.
        vim.api.nvim_get_current_buf() ~= args.buf
        or -- floating window
          vim.api.nvim_win_get_config(0).relative ~= ''
      then return end

      for o, t in pairs(require('neo-term').buf_open_to_term) do
        if vim.api.nvim_get_current_buf() == t
        then
          -- NOTE: the order matters: should split the window first BEFORE restoring its view.
          vim.cmd('vsplit')
          vim.api.nvim_set_current_buf(o)
          vim.fn.winrestview(require('neo-term').view_of_open_buf[o])
          return
        end
      end
    end,
  })
  -- see: https://github.com/nyngwang/NeoTerm.lua/issues/24.
  vim.api.nvim_create_autocmd({ 'TermClose' }, {
    group = 'neo-term.lua',
    callback = function (args)
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end

      if #vim.tbl_filter(
          function (w) return vim.api.nvim_win_get_config(w).relative == '' end,
          vim.api.nvim_tabpage_list_wins(0)
        ) == 1
      then
        vim.cmd('vsplit')
        vim.fn.feedkeys(' ', 'n')
      end
    end,
  })
end


local function create_features_autocmds()
  -- change bg-color on enter term-mode of NeoTerm.
  vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end
      vim.cmd('set winhl=Normal:' .. (require('neo-term').term_mode_hl or 'NEO_TERM_COOL_BLACK'))
    end
  })
  -- reset bg-color on leave term-mode of NeoTerm.
  vim.api.nvim_create_autocmd({ 'TermLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end
      vim.cmd('set winhl=')
    end
  })
  -- auto-insert on enter term-buf of NeoTerm.
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermOpen' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end
      vim.cmd('startinsert')
    end
  })
  -- cancel-insert on exit term-buf of NeoTerm.
  vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      if vim.bo.filetype ~= 'neo-term'
        or vim.bo.buftype ~= 'terminal'
      then return end
      vim.cmd('stopinsert')
    end
  })
end


function M.create_autocmds()
  create_features_autocmds()
  create_hotfix_autocmds()
end


return M
