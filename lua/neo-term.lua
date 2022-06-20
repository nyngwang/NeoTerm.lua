local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
-------------------------------------------------------------------------------------------------------
M = { }
local _parent_win_to_term_buf = { }

local function found_key(t, k)
  for i, _ in pairs(t) do
    if i == k then
      return true
    end
  end
  return false
end

local function open_term()
  if vim.bo.buftype == 'terminal' then
    vim.cmd('normal! a')
    return
  end
  local cur_win = vim.api.nvim_get_current_win()
  local cur_win_height = vim.fn.getwininfo(cur_win)[1].height
  local cur_win_cursor = vim.api.nvim_win_get_cursor(cur_win)
  local bottom_size = cur_win_height * 0.3
  local top_size = cur_win_height - bottom_size
  vim.cmd('normal! H')
  vim.cmd('split')
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. top_size)
  vim.api.nvim_win_set_cursor(cur_win, cur_win_cursor)
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. bottom_size)
  if found_key(_parent_win_to_term_buf, cur_win) then
    vim.api.nvim_set_current_buf(_parent_win_to_term_buf[cur_win])
  else
    vim.cmd('term')
    _parent_win_to_term_buf[cur_win] = vim.api.nvim_win_get_buf(cur_win)
  end
end

local function on_delete()
  for i, v in ipairs(_parent_win_to_term_buf) do
    if not (
        vim.api.nvim_buf_is_valid(v)
        and vim.api.nvim_buf_get_option(v, 'buflisted')
      ) then
      _parent_win_to_term_buf[i] = nil
    end
  end
end

-------------------------------------------------------------------------------------------------------

function M.setup(opt)
  M.toggle_keymap = opt.toggle_keymap ~= nil and opt.toggle_keymap or '<M-Tab>'
  M.exit_term_mode_keymap = opt.exit_term_mode_keymap ~= nil and opt.exit_term_mode_keymap or '<M-w>'
  M.term_mode_hl = opt.term_mode_hl ~= nil and opt.term_mode_hl or 'CoolBlack'
  if M.term_mode_hl == 'CoolBlack' then
    vim.cmd([[
      hi CoolBlack guibg=#101010
    ]])
  end

  vim.keymap.set('n', M.toggle_keymap, function () open_term() end, NOREF_NOERR_TRUNC)
  vim.keymap.set('t', M.toggle_keymap, function () return "<C-\\><C-n> | <cmd>lua vim.cmd('q')<CR>" end, EXPR_NOREF_NOERR_TRUNC)
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
  vim.api.nvim_create_autocmd('BufWipeout', {
    pattern = 'term://*',
    callback = function () -- No more insert mode after leaving.
      on_delete()
    end
  })

  -- Setup variations
  local term_mode_hl = M.term_mode_hl
  local cmd_str = [[
    augroup ResetWinhl
      autocmd!
      autocmd TermEnter * if &buflisted | set winhl=Normal:$term_mode_hl | endif
      autocmd TermLeave * set winhl=
    augroup END
  ]]

  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermOpen' }, {
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd(cmd_str:gsub('$(%S+)', {
          term_mode_hl = term_mode_hl
        }))
      end
    end
  })
end

function M.remove_augroup_resetwinhl()
  vim.cmd('augroup ResetWinhl | autocmd! | augroup END')
end


return M
