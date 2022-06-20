local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
-------------------------------------------------------------------------------------------------------
M = { }
local _parent_win_to_term_buf = { }

local function found_buf_in_tabpage(t, b)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    if vim.api.nvim_win_get_buf(w) == b then
      return w
    end
  end
  return -1
end

local function open_term()
  if vim.bo.buftype == 'terminal' then
    vim.cmd('normal! a')
    return
  end
  local parent_win = vim.api.nvim_get_current_win()
  local parent_win_height = vim.fn.getwininfo(parent_win)[1].height
  local bottom_split_size = parent_win_height * 0.3
  local top_split_size = parent_win_height - bottom_split_size

  if -- the terminal is already open
    _parent_win_to_term_buf[parent_win] ~= nil
    and found_buf_in_tabpage(0, _parent_win_to_term_buf[parent_win]) ~= -1
    then
    vim.api.nvim_set_current_win(found_buf_in_tabpage(0, _parent_win_to_term_buf[parent_win]))
    return
  end

  local _splitbelow = vim.opt.splitbelow

  vim.opt.splitbelow = true

  vim.cmd('normal! H')
  vim.cmd('split')
  vim.cmd('resize ' .. bottom_split_size)
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. top_split_size)
  vim.cmd('wincmd p') -- at bottom split

  if _parent_win_to_term_buf[parent_win] == nil
    or not vim.api.nvim_buf_is_valid(_parent_win_to_term_buf[parent_win])
    then
    vim.cmd('term')
    _parent_win_to_term_buf[parent_win] = vim.api.nvim_win_get_buf(0)
  else
    vim.api.nvim_set_current_buf(_parent_win_to_term_buf[parent_win])
  end

  vim.opt.splitbelow = _splitbelow
end

local function check_term_buf()
  for i, v in ipairs(_parent_win_to_term_buf) do
    if -- either parent_win or term_buf is invalid
      not vim.api.nvim_win_is_valid(i)
      or not vim.api.nvim_buf_is_valid(v) then
      table.remove(_parent_win_to_term_buf, i)
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
  vim.keymap.set('t', M.toggle_keymap, function ()
    if _parent_win_to_term_buf[vim.api.nvim_get_current_win()] ~= nil then
      return "<C-\\><C-n> | <cmd>enew | lua vim.cmd('NeoNoNameClean')<CR>"
    end
    return "<C-\\><C-n> | <cmd>lua vim.cmd('q')<CR>"
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
  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function () -- No more insert mode after leaving.
      check_term_buf()
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
