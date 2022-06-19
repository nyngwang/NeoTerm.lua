local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
-------------------------------------------------------------------------------------------------------
M = {}

local function neo_term()
  LAST_WIN = vim.api.nvim_get_current_win()
  vim.cmd('normal! H')
  vim.cmd('split')
  vim.cmd('resize 20')
  vim.cmd('term')
end

-------------------------------------------------------------------------------------------------------

function M.setup(opt)
  M.toggle_keymap = opt.toggle_keymap ~= nil and opt.toggle_keymap or '<M-Tab>'
  M.exit_term_mode_keymap = opt.exit_term_mode_keymap ~= nil and opt.exit_term_mode_keymap or '<M-w>'
  M.neo_no_name_keymap = opt.neo_no_name_keymap ~= nil and opt.neo_no_name_keymap or '<M-w>'
  M.term_mode_hl = opt.term_mode_hl ~= nil and opt.term_mode_hl or 'CoolBlack'
  if M.term_mode_hl == 'CoolBlack' then
    vim.cmd([[
      hi CoolBlack guibg=#101010
    ]])
  end

  local neo_no_name_keymap = M.neo_no_name_keymap

  vim.keymap.set('n', M.toggle_keymap, function () neo_term() end, NOREF_NOERR_TRUNC)
  vim.keymap.set('t', M.toggle_keymap, function ()
    return '<C-\\><C-n> | <cmd>normal '
      .. neo_no_name_keymap .. neo_no_name_keymap .. neo_no_name_keymap .. '<CR>'
      .. '<cmd>q<CR>'
  end, EXPR_NOREF_NOERR_TRUNC)
  vim.keymap.set('t', M.exit_term_mode_keymap, function () return '<C-\\><C-n>' end, EXPR_NOREF_NOERR_TRUNC)

  -- Setup pivots
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    command = 'set winhl=' -- Must start from no highlight.
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'TermOpen' }, {
    pattern = 'term://*',
    command = 'startinsert' -- Auto enter term-buf.
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    pattern = 'term://*',
    callback = function () -- No more insert mode after leaving.
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd('stopinsert')
      end
    end
  })

  -- Setup variations
  local term_mode_hl = M.term_mode_hl

  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermOpen' }, {
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        local cmd_str = [[
          augroup ResetWinhl
            autocmd!
            autocmd TermEnter * if &buflisted | set winhl=Normal:$term_mode_hl | endif
            autocmd TermLeave * set winhl=
          augroup END
        ]]
        vim.cmd(cmd_str:gsub('$(%S+)', {
          term_mode_hl = term_mode_hl
        }))
      end
    end
  })
end

function M.create_augroup_resetwinhl()
end

function M.remove_augroup_resetwinhl()
  vim.cmd('augroup ResetWinhl | autocmd! | augroup END')
end

return M
