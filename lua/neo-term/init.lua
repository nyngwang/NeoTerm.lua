local U = require('neo-term.utils')
local A = require('neo-term.utils.autocmd')
local RG = require('neo-term.utils.rpc_git')
local P = require('neo-term.presets')
local M = {}
vim.api.nvim_create_augroup('neo-term.lua', { clear = true })
-------------------------------------------------------------------------------------------------------
M.buf_open_to_term = {}
M.view_of_open_buf = {}


local function remove_invalid_mappings()
  for o, t in pairs(M.buf_open_to_term) do
    if
      not vim.api.nvim_buf_is_valid(o)
      or (t and not vim.api.nvim_buf_is_valid(t))
    then
      M.buf_open_to_term[o] = nil
    end
  end
end
-------------------------------------------------------------------------------------------------------
function M.setup(opts)
  if not opts then opts = {} end

  vim.api.nvim_set_hl(0, 'NEO_TERM_COOL_BLACK', { bg = '#101010' })

  M.term_mode_hl = opts.term_mode_hl or 'NEO_TERM_COOL_BLACK'
    if type(M.term_mode_hl) ~= 'string' then M.term_mode_hl = 'NEO_TERM_COOL_BLACK' end
  M.exclude_filetypes = U.table_add_values({ 'git.*' },
    type(opts.exclude_filetypes) == 'table' and opts.exclude_filetypes or {})
  M.exclude_buftypes = U.table_add_values({ 'terminal' },
    type(opts.exclude_buftypes) == 'table' and opts.exclude_buftypes or {})
  M.presets = opts.presets
    if type(M.presets) ~= 'table' then M.presets = { 'vim-test' } end

  A.create_autocmds()
  P.setup(M.presets)
  RG.guest_run()
end


function M.neo_term_toggle()
  -- Case1: already open.
  if vim.bo.filetype == 'neo-term' then
    -- Case1.1: it's a dead terminal.
    if vim.fn.jobwait({ vim.bo.channel }, 0)[1] == -3 then
      vim.bo.bufhidden = 'delete'
      local buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_set_current_buf(buf)
      M.neo_term_toggle()
      return
    end

    -- Case1.2: it's a live terminal.
    for o, t in pairs(M.buf_open_to_term) do
      if vim.api.nvim_get_current_buf() == t
      then
        vim.api.nvim_set_current_buf(o)
        vim.fn.winrestview(M.view_of_open_buf[vim.api.nvim_get_current_buf()])
        remove_invalid_mappings()
        return
      end
    end
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, false))
    return
  end

  -- Case2: might open.

  if os.getenv('NVIM') then return end

  if U.table_contains(M.exclude_filetypes, vim.bo.filetype)
    or U.table_contains(M.exclude_buftypes, vim.bo.buftype)
  then return end

  -- Case2.1: two-phrase open when a term-win exists.
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(w) == M.buf_open_to_term[vim.api.nvim_get_current_buf()]
    then
      vim.api.nvim_set_current_win(w)
      return
    end
  end

  -- Case2.2: should open.
  local open_buf = vim.api.nvim_get_current_buf()
  M.view_of_open_buf[open_buf] = vim.fn.winsaveview()

  if M.buf_open_to_term[open_buf]
    and vim.api.nvim_buf_is_valid(M.buf_open_to_term[open_buf])
  then
    vim.api.nvim_set_current_buf(M.buf_open_to_term[open_buf])
  else
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'neo-term'
    vim.api.nvim_set_current_buf(buf)
    vim.fn.termopen(vim.opt.shell:get())
    M.buf_open_to_term[open_buf] = vim.api.nvim_get_current_buf()
  end
end


local function setup_vim_commands()
  vim.api.nvim_create_user_command('NeoTermToggle', M.neo_term_toggle, {})
  vim.api.nvim_create_user_command('NeoTermEnterNormal', function ()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), 't', true)
  end, {})
end
setup_vim_commands()


return M
