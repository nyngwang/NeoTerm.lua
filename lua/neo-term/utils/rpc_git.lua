local M = {}


function M.host_run(arg, socket_guest)
  local buf_term_host = vim.api.nvim_get_current_buf()
  if #vim.tbl_filter(
      function (w) return vim.api.nvim_win_get_config(w).relative == '' end,
      vim.api.nvim_tabpage_list_wins(0)
    ) == 1
  then vim.cmd('vsplit') end

  vim.cmd('e ' .. arg)
  vim.cmd('stopinsert')
  local buf_commit = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf_commit, 'bh', 'delete')

  vim.api.nvim_create_autocmd('WinClosed', {
    buffer = buf_commit,
    once = true,
    callback = function ()
      local rpc_guest = vim.fn.sockconnect('pipe', socket_guest, { rpc = true })
      vim.rpcnotify(rpc_guest, 'nvim_exec_lua', [[vim.cmd('qa!')]], {})
      vim.fn.chanclose(rpc_guest)
      local sb = vim.opt.splitbelow
      vim.opt.splitbelow = false
      vim.cmd('split')
      vim.opt.splitbelow = sb
      vim.api.nvim_set_current_buf(buf_term_host)
      vim.cmd('startinsert')
    end
  })
end


function M.guest_run()
  -- get `vim.v.servername` of the host.
  local pipe_host = os.getenv('NVIM')
  if not pipe_host then return end

  -- is guest process.

  -- only avoid nested instance for git series.
  if vim.fn.argc() ~= 1
    or not vim.fn.argv(0):match('/.git/.*')
  then return end

  local rpc_host = vim.fn.sockconnect('pipe', pipe_host, { rpc = true })
  if rpc_host == 0 then return end

  vim.rpcrequest(rpc_host, 'nvim_exec_lua', string.format([[
    return require('neo-term.utils.rpc_git').host_run(
      '%s', -- arg.
      '%s' -- guest socket.
    )]],
    vim.fn.argv(0),
    vim.v.servername
    ), {})
  vim.fn.chanclose(rpc_host)

  -- wait for termination by host.
  while true do vim.cmd('sleep 1') end
end


return M
