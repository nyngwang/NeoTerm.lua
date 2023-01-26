vim.api.nvim_create_augroup('neo-term.lua', { clear = true })
-------------------------------------------------------------------------------------------------------
local M = { }
local buf_open_to_term = { }
local win_open_to_term = { }
local view_of_open_buf = { }


local function remove_invalid_mappings()
  for o, t in pairs(buf_open_to_term) do
    if
      not vim.api.nvim_buf_is_valid(o)
      or (t and not vim.api.nvim_buf_is_valid(t))
    then
      buf_open_to_term[o] = nil
    end
  end
  for o, t in pairs(win_open_to_term) do
    if
      t and not vim.api.nvim_win_is_valid(t)
    then
      win_open_to_term[o] = nil
    end
  end
end


local function add_cool_black()
  vim.api.nvim_create_autocmd({ 'VimEnter', 'ColorScheme' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function () vim.cmd('hi NEO_TERM_COOL_BLACK guibg=#101010') end
  })
end


-------------------------------------------------------------------------------------------------------
function M.setup(opt)
  if not opt then opt = {} end

  M.term_mode_hl = opt.term_mode_hl and opt.term_mode_hl or 'NEO_TERM_COOL_BLACK'
  M.split_size = opt.split_size and opt.split_size or 0.35
  M.split_on_top = opt.split_on_top and opt.split_on_top or false
  M.exclude_filetypes = opt.exclude_filetypes and opt.exclude_filetypes or {}
  M.exclude_buftypes = opt.exclude_buftypes and opt.exclude_buftypes or {}

  -- TODO: simplify these shits
  -- Setup pivots
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermLeave' }, {
    group = 'neo-term.lua',
    pattern = '*',
    callback = function ()
      remove_invalid_mappings()
      -- TODO: can I remove this?
      vim.cmd('set winhl=') -- Start from no highlight.
    end
  })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'TermOpen' }, {
    group = 'neo-term.lua',
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd('startinsert') -- Auto-`a` on enter termbuf.
        vim.api.nvim_create_augroup('neo-term.lua/ResetWinhl', { clear = true })
        vim.api.nvim_create_autocmd('TermEnter', {
          -- Enable au-`ResetWinhl` on enter termbuf.
          group = 'neo-term.lua/ResetWinhl',
          pattern = '*',
          command = string.gsub(
            [[ if &buflisted | set winhl=Normal:$term_mode_hl | endif ]],
            '$(%S+)',
            { term_mode_hl = M.term_mode_hl }
          )
        })
      end
    end
  })
  -- TODO: can I remove this?
  vim.api.nvim_create_autocmd('BufLeave', {
    group = 'neo-term.lua',
    -- TODO: can I remove this?
    pattern = 'term://*',
    callback = function ()
      if vim.api.nvim_buf_get_option(0, 'buflisted') then
        vim.cmd('stopinsert') -- Disable auto-`a` on exit termbuf.
      end
    end
  })
  add_cool_black()
end


function M.open_termbuf()
  for _, v in pairs(M.exclude_filetypes) do if vim.bo.filetype == v then return end end
  for _, v in pairs(M.exclude_buftypes) do if vim.bo.buftype == v then return end end

  local open_win = vim.api.nvim_get_current_win()
  if -- a term-win is there then just use it.
    win_open_to_term[open_win]
    and vim.api.nvim_win_is_valid(win_open_to_term[open_win])
  then
    vim.api.nvim_set_current_win(win_open_to_term[open_win])
    return
  end

  local open_buf = vim.api.nvim_get_current_buf()
  view_of_open_buf[open_buf] = vim.fn.winsaveview()
  local open_win_height = vim.fn.getwininfo(open_win)[1].height
  local termbuf_size = open_win_height * M.split_size
  local openbuf_size = open_win_height - termbuf_size
  local backup_splitbelow = vim.opt.splitbelow
  if M.split_on_top
  then vim.opt.splitbelow = false
  else vim.opt.splitbelow = true end

  if M.split_on_top then
    vim.cmd('normal! L')
  else
    vim.cmd('normal! H')
  end
  vim.cmd('split')
  vim.cmd('resize ' .. termbuf_size)
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. openbuf_size)
  vim.cmd('wincmd p') -- cursor at termbuf split
  local term_win = vim.api.nvim_get_current_win()
  win_open_to_term[open_win] = term_win

  if
    buf_open_to_term[open_buf]
    and vim.api.nvim_buf_is_valid(buf_open_to_term[open_buf])
  then
    vim.api.nvim_set_current_buf(buf_open_to_term[open_buf])
  else
    vim.cmd('term')
    buf_open_to_term[open_buf] = vim.api.nvim_win_get_buf(0)
  end

  vim.opt.splitbelow = backup_splitbelow
end


function M.close_termbuf()
  -- double check for users.
  if not vim.bo.buftype == 'terminal' then return end

  -- close the term-split.
  vim.cmd('NeoTermEnterNormal')
  local term_buf = vim.api.nvim_get_current_buf()
  vim.cmd('q')

  local close_buf = vim.api.nvim_get_current_buf()
  if buf_open_to_term[close_buf] == term_buf then
    vim.fn.winrestview(view_of_open_buf[close_buf])
  end
end


function M.remove_augroup_resetwinhl()
  vim.api.nvim_create_augroup('neo-term.lua/ResetWinhl', { clear = true })
end


local function setup_vim_commands()
  vim.cmd [[
    command! NeoTermOpen lua require'neo-term'.open_termbuf()
    command! NeoTermClose lua require'neo-term'.close_termbuf()
    command! NeoTermEnterNormal lua vim.api.nvim_feedkeys('', 't', true)
  ]]
end
setup_vim_commands()


return M
