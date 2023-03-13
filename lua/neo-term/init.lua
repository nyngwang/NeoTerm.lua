local A = require('neo-term.utils.autocmd')
local RG = require('neo-term.utils.rpc_git')
local M = {}
vim.api.nvim_create_augroup('neo-term.lua', { clear = true })
-------------------------------------------------------------------------------------------------------
local buf_open_to_term = {}
local view_of_open_buf = {}


local function remove_invalid_mappings()
  for o, t in pairs(buf_open_to_term) do
    if
      not vim.api.nvim_buf_is_valid(o)
      or (t and not vim.api.nvim_buf_is_valid(t))
    then
      buf_open_to_term[o] = nil
    end
  end
end
-------------------------------------------------------------------------------------------------------
function M.setup(opts)
  if not opts then opts = {} end

  M.term_mode_hl = opts.term_mode_hl or 'NEO_TERM_COOL_BLACK'
    if type(M.term_mode_hl) ~= 'string' then M.term_mode_hl = 'NEO_TERM_COOL_BLACK' end
  M.split_size = opts.split_size or 0.35
    if type(M.split_size) ~= 'number' then M.split_size = 0.35 end
  M.split_on_top = opts.split_on_top or false
    if type(M.split_on_top) ~= 'boolean' then M.split_on_top = true end
  M.exclude_filetypes = opts.exclude_filetypes or {}
    if type(M.exclude_filetypes) ~= 'table' then M.exclude_filetypes = {} end
  M.exclude_buftypes = opts.exclude_buftypes or {}
    if type(M.exclude_buftypes) ~= 'table' then M.exclude_buftypes = {} end

  A.create_autocmds()
  RG.guest_run()
end


function M.neo_term_toggle()
  -- Case1: already open.
  if vim.bo.filetype == 'neo-term' then
    local term_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_close(0, false)

    local close_buf = vim.api.nvim_get_current_buf()
    if buf_open_to_term[close_buf] == term_buf then
      vim.fn.winrestview(view_of_open_buf[close_buf])
    end
    remove_invalid_mappings()
    return
  end

  -- Case2: might open.

  if os.getenv('NVIM') then return end
  for _, v in pairs(M.exclude_filetypes) do if vim.bo.filetype == v then return end end
  for _, v in pairs(M.exclude_buftypes) do if vim.bo.buftype == v then return end end

  -- Case2.1: two-phrase open when a term-win exists.
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == buf_open_to_term[vim.api.nvim_get_current_buf()]
    then
      vim.api.nvim_set_current_win(w)
      return
    end
  end

  -- Case2.2: should open.
  local open_win = vim.api.nvim_get_current_win()
  local open_buf = vim.api.nvim_get_current_buf()
  view_of_open_buf[open_buf] = vim.fn.winsaveview()
  local open_win_height = vim.fn.getwininfo(open_win)[1].height
  local termbuf_size = open_win_height * M.split_size
  local openbuf_size = open_win_height - termbuf_size
  local backup_splitbelow = vim.opt.splitbelow

  vim.opt.splitbelow = not M.split_on_top and true or false
  vim.cmd('normal! ' .. (M.split_on_top and 'L' or 'H'))
  vim.cmd('split')
  vim.cmd('resize ' .. termbuf_size)
  vim.cmd('wincmd p')
  vim.cmd('resize ' .. openbuf_size)
  vim.cmd('wincmd p') -- cursor at termbuf split

  if buf_open_to_term[open_buf]
    and vim.api.nvim_buf_is_valid(buf_open_to_term[open_buf])
  then
    vim.api.nvim_set_current_buf(buf_open_to_term[open_buf])
  else
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'neo-term')
    vim.api.nvim_set_current_buf(buf)
    vim.fn.termopen(vim.opt.shell:get())
    vim.cmd('startinsert')
    buf_open_to_term[open_buf] = vim.api.nvim_get_current_buf()
  end

  vim.opt.splitbelow = backup_splitbelow
end


function M.neo_term_hijack_toggle()
  -- Case1: already open.
  if vim.bo.filetype == 'neo-term' then
    for o, t in pairs(buf_open_to_term) do
      if vim.api.nvim_get_current_buf() == t
      then
        vim.api.nvim_set_current_buf(o)
        vim.fn.winrestview(view_of_open_buf[vim.api.nvim_get_current_buf()])
        remove_invalid_mappings()
        return
      end
    end
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, false))
    return
  end

  -- Case2: might open.

  if os.getenv('NVIM') then return end
  for _, v in pairs(M.exclude_filetypes) do if vim.bo.filetype == v then return end end
  for _, v in pairs(M.exclude_buftypes) do if vim.bo.buftype == v then return end end

  -- Case2.1: two-phrase open when a term-win exists.
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == buf_open_to_term[vim.api.nvim_get_current_buf()]
    then
      vim.api.nvim_set_current_win(w)
      return
    end
  end

  -- Case2.2: should open.
  local open_buf = vim.api.nvim_get_current_buf()
  view_of_open_buf[open_buf] = vim.fn.winsaveview()

  if buf_open_to_term[open_buf]
    and vim.api.nvim_buf_is_valid(buf_open_to_term[open_buf])
  then
    vim.api.nvim_set_current_buf(buf_open_to_term[open_buf])
  else
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'neo-term')
    vim.api.nvim_set_current_buf(buf)
    vim.fn.termopen(vim.opt.shell:get())
    vim.cmd('startinsert')
    print(buf == vim.api.nvim_get_current_buf())
    buf_open_to_term[open_buf] = vim.api.nvim_get_current_buf()
  end
end


local function setup_vim_commands()
  vim.api.nvim_create_user_command('NeoTermToggle', M.neo_term_toggle, {})
  vim.api.nvim_create_user_command('NeoTermHijackToggle', M.neo_term_hijack_toggle, {})
  vim.api.nvim_create_user_command('NeoTermEnterNormal', function ()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), 't', true)
  end, {})
end
setup_vim_commands()


return M
