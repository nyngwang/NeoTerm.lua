local M = {}


function M.setup(presets)
  if #presets == 0 then return end
  for _, preset in ipairs(presets) do
    local ok, handle = pcall(require, 'neo-term.presets.' .. preset)
    if ok then handle.setup() end
  end
end


return M
