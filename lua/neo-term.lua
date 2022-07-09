local NOREF_NOERR_TRUNC = { noremap = true, silent = true, nowait = true }
local NOREF_NOERR = { noremap = true, silent = true }
local EXPR_NOREF_NOERR_TRUNC = { expr = true, noremap = true, silent = true, nowait = true }
-------------------------------------------------------------------------------------------------------
local M = { }
local _parent_win_to_term_buf = { }

local function found_buf_in_tabpage(t, b)
  if b == nil then return -1 end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(t)) do
    if vim.api.nvim_win_get_buf(w) == b then
      return w
    end
  end
  return -1
end

local function remove_invalid_mappings()
  local to_remove = {}
  for i, v in ipairs(_parent_win_to_term_buf) do
    if -- either parent_win or term_buf is invalid
      not vim.api.nvim_win_is_valid(i)
      or not vim.api.nvim_buf_is_valid(v) then
      to_remove[#to_remove+1] = i
    end
  end
  for _, v in ipairs(to_remove) do
    table.remove(_parent_win_to_term_buf, v)
  end
end

-------------------------------------------------------------------------------------------------------

function M.setup(opt)
  M.term_mode_hl = opt.term_mode_hl ~= nil and opt.term_mode_hl or 'CoolBlack'
  M.split_size = opt.split_size ~= nil and opt.split_size or 0.35
  M.split_on_top = opt.split_on_top ~= nil and opt.split_on_top or false
  if M.term_mode_hl == 'CoolBlack' then
    vim.cmd([[
      hi CoolBlack guibg=#101010
    ]])
  end

  -- Setup pivots
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermLeave' }, {
    pattern = '*',
    callback = function ()
      remove_invalid_mappings()
      vim.cmd('set winhl=') -- Start from no highlight.
    end
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermOpen' }, {
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd('startinsert') -- Auto-`a` on enter term-buf.
        vim.cmd(string.gsub( -- Enable au-`ResetWinhl` on enter term-buf.
          [[
            augroup ResetWinhl
              autocmd!
              autocmd TermEnter * if &buflisted | set winhl=Normal:$term_mode_hl | endif
            augroup END
          ]],
          '$(%S+)',
          { term_mode_hl = M.term_mode_hl }
        ))
      end
    end
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd('stopinsert') -- Disable auto-`a` on exit term-buf.
      end
    end
  })
end

function M.open_win_termbuf()
  local parent_win = vim.api.nvim_get_current_win()
  local parent_win_height = vim.fn.getwininfo(parent_win)[1].height
  local termbuf_size = parent_win_height * M.split_size
  local parent_size = parent_win_height - termbuf_size

  if found_buf_in_tabpage(0, _parent_win_to_term_buf[parent_win]) ~= -1 then
    vim.api.nvim_set_current_win(found_buf_in_tabpage(0, _parent_win_to_term_buf[parent_win]))
    return
  end

  -- this makes things easier
  local _splitbelow = vim.opt.splitbelow
  if M.split_on_top then
    vim.opt.splitbelow = false
  else
    vim.opt.splitbelow = true
  end

  if M.split_on_top then
    vim.cmd('normal! L')
  else
    vim.cmd('normal! H')
  end
  vim.cmd('split')
  vim.cmd('resize ' .. termbuf_size)
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. parent_size)
  vim.cmd('wincmd p') -- at bottom split

  if -- termbuf for this win exists
    _parent_win_to_term_buf[parent_win] ~= nil
    and vim.api.nvim_buf_is_valid(_parent_win_to_term_buf[parent_win]) then
    vim.api.nvim_set_current_buf(_parent_win_to_term_buf[parent_win])
  else
    vim.cmd('term')
    _parent_win_to_term_buf[parent_win] = vim.api.nvim_win_get_buf(0)
  end

  vim.opt.splitbelow = _splitbelow
end

function M.close_win_termbuf()
  -- exit term-mode first
  vim.cmd('NeoTermEnterNormal')
  if _parent_win_to_term_buf[vim.api.nvim_get_current_win()] ~= nil then
    vim.cmd('enew')
    vim.cmd('NeoNoNameClean')
  else
    vim.cmd('q')
  end
end

function M.remove_augroup_resetwinhl()
  vim.cmd('augroup ResetWinhl | autocmd! | augroup END')
end

local function setup_vim_commands()
  vim.cmd [[
    command! NeoTermOpen lua require'neo-term'.open_win_termbuf()
    command! NeoTermClose lua require'neo-term'.close_win_termbuf()
    command! NeoTermEnterNormal lua vim.api.nvim_feedkeys('', 't', true)
  ]]
end

setup_vim_commands()

return M
