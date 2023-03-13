local M = {}


function M.table_contains(table, value)
  for _, pattern_v in pairs(table) do
    if value == pattern_v
      or string.match(value, pattern_v)
    then
      return true
    end
  end
  return false
end


function M.table_add_values(table, values)
  for _, v in pairs(values) do
    table[#table + 1] = v
  end

  return table
end


return M
