if vim.fn.has("nvim-0.5") == 0 then
  return
end

if vim.g.loaded_neo_term ~= nil then
  return
end

require('neo-term')


vim.g.loaded_neo_term = 1

