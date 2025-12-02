--- Utility functions module - Demonstrates functional programming and coroutines
-- @module utils

local M = {}

--- Deep copy a table
-- Demonstrates: recursion, table traversal, metatables
-- @param original table The table to copy
-- @return table A deep copy of the table
function M.deep_copy(original)
  local original_type = type(original)
  local copy

  if original_type == "table" then
    copy = {}
    -- Handle metatables
    for original_key, original_value in next, original, nil do
      copy[M.deep_copy(original_key)] = M.deep_copy(original_value)
    end
    setmetatable(copy, M.deep_copy(getmetatable(original)))
  else
    copy = original
  end

  return copy
end

--- Check if a table contains a value
-- Demonstrates: iteration, early return
-- @param tbl table The table to search
-- @param value any The value to find
-- @return boolean True if value is found
function M.contains(tbl, value)
  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

--- Map function over array
-- Demonstrates: functional programming, generics
-- @param tbl table Input array
-- @param func function Mapping function
-- @return table New array with mapped values
function M.map(tbl, func)
  local result = {}
  for i, v in ipairs(tbl) do
    result[i] = func(v, i)
  end
  return result
end

--- Filter array by predicate
-- @param tbl table Input array
-- @param predicate function Filter function
-- @return table New array with filtered values
function M.filter(tbl, predicate)
  local result = {}
  for _, v in ipairs(tbl) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

--- Reduce array to single value
-- @param tbl table Input array
-- @param func function Reducer function
-- @param initial any Initial accumulator value
-- @return any Final reduced value
function M.reduce(tbl, func, initial)
  local acc = initial
  for _, v in ipairs(tbl) do
    acc = func(acc, v)
  end
  return acc
end

--- Partition array into two arrays based on predicate
-- Demonstrates: multiple return values
-- @param tbl table Input array
-- @param predicate function Partition function
-- @return table, table Two arrays: passing and failing predicate
function M.partition(tbl, predicate)
  local pass, fail = {}, {}
  for _, v in ipairs(tbl) do
    if predicate(v) then
      table.insert(pass, v)
    else
      table.insert(fail, v)
    end
  end
  return pass, fail
end

--- Chunk array into smaller arrays of specified size
-- Demonstrates: array manipulation, math operations
-- @param tbl table Input array
-- @param size number Size of each chunk
-- @return table Array of chunks
function M.chunk(tbl, size)
  if size <= 0 then
    error("Chunk size must be positive", 2)
  end

  local chunks = {}
  local current_chunk = {}

  for i, v in ipairs(tbl) do
    table.insert(current_chunk, v)
    if #current_chunk == size then
      table.insert(chunks, current_chunk)
      current_chunk = {}
    end
  end

  if #current_chunk > 0 then
    table.insert(chunks, current_chunk)
  end

  return chunks
end

--- Create a range iterator
-- Demonstrates: coroutines, generators, iterator pattern
-- @param start number Starting value
-- @param stop number Ending value
-- @param step number Step size (default: 1)
-- @return function Iterator function
function M.range(start, stop, step)
  step = step or 1

  if step == 0 then
    error("Step cannot be zero", 2)
  end

  return coroutine.wrap(function()
    local current = start
    if step > 0 then
      while current <= stop do
        coroutine.yield(current)
        current = current + step
      end
    else
      while current >= stop do
        coroutine.yield(current)
        current = current + step
      end
    end
  end)
end

--- Zip multiple arrays together
-- Demonstrates: multiple parameters, variadic functions
-- @param ... table Arrays to zip
-- @return table Array of tuples
function M.zip(...)
  local arrays = {...}
  if #arrays == 0 then
    return {}
  end

  local min_length = math.huge
  for _, arr in ipairs(arrays) do
    min_length = math.min(min_length, #arr)
  end

  local result = {}
  for i = 1, min_length do
    local tuple = {}
    for _, arr in ipairs(arrays) do
      table.insert(tuple, arr[i])
    end
    table.insert(result, tuple)
  end

  return result
end

--- Flatten nested array one level
-- @param tbl table Nested array
-- @return table Flattened array
function M.flatten(tbl)
  local result = {}
  for _, v in ipairs(tbl) do
    if type(v) == "table" then
      for _, inner_v in ipairs(v) do
        table.insert(result, inner_v)
      end
    else
      table.insert(result, v)
    end
  end
  return result
end

--- Create a memoization wrapper
-- Demonstrates: closures, caching, higher-order functions
-- @param func function Function to memoize
-- @return function Memoized version of the function
function M.memoize(func)
  local cache = {}

  return function(...)
    local key = table.concat({...}, ",")

    if cache[key] == nil then
      cache[key] = func(...)
    end

    return cache[key]
  end
end

--- Debounce a function
-- Demonstrates: time-based logic, closures, state management
-- @param func function Function to debounce
-- @param delay number Delay in seconds
-- @return function Debounced function
function M.debounce(func, delay)
  local timer = nil
  local last_call = 0

  return function(...)
    local args = {...}
    local now = os.time()

    if now - last_call >= delay then
      last_call = now
      return func(unpack(args))
    end

    return nil
  end
end

--- String utilities
M.string = {}

--- Split string by delimiter
-- Demonstrates: string manipulation, pattern matching
-- @param str string Input string
-- @param delimiter string Delimiter pattern
-- @return table Array of substrings
function M.string.split(str, delimiter)
  delimiter = delimiter or "%s"
  local result = {}

  for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end

  return result
end

--- Trim whitespace from string
-- @param str string Input string
-- @return string Trimmed string
function M.string.trim(str)
  return str:match("^%s*(.-)%s*$")
end

--- Check if string starts with prefix
-- @param str string Input string
-- @param prefix string Prefix to check
-- @return boolean True if string starts with prefix
function M.string.starts_with(str, prefix)
  return str:sub(1, #prefix) == prefix
end

--- Check if string ends with suffix
-- @param str string Input string
-- @param suffix string Suffix to check
-- @return boolean True if string ends with suffix
function M.string.ends_with(str, suffix)
  return str:sub(-#suffix) == suffix
end

return M
