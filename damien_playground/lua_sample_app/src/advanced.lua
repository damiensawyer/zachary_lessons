--- Advanced Lua features - Pushing the language to its limits
-- @module advanced
--
-- This module demonstrates:
-- - All metamethods (__add, __sub, __mul, __div, __mod, __pow, __unm, __concat, __eq, __lt, __le, __call, __index, __newindex)
-- - Weak tables for caching
-- - Advanced coroutines (generators, producers/consumers, cooperative multitasking)
-- - Environment manipulation (_ENV, _G)
-- - Complex pattern matching
-- - Debug library features
-- - Tail call optimization
-- - Upvalue manipulation

local M = {}

-- ============================================================================
-- PART 1: ADVANCED METATABLES - Full Metamethod Suite
-- ============================================================================

--- Vector class demonstrating all arithmetic metamethods
-- @class Vector
local Vector = {}
Vector.__index = Vector

--- Create a new Vector
-- @param x number X component
-- @param y number Y component
-- @return Vector New vector instance
function Vector.new(x, y)
  return setmetatable({x = x or 0, y = y or 0}, Vector)
end

-- Arithmetic metamethods
function Vector.__add(a, b)
  return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__sub(a, b)
  return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
  -- Scalar multiplication or dot product
  if type(a) == "number" then
    return Vector.new(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x * b, a.y * b)
  else
    -- Dot product
    return a.x * b.x + a.y * b.y
  end
end

function Vector.__div(a, b)
  if type(b) == "number" then
    return Vector.new(a.x / b, a.y / b)
  else
    error("Can only divide vector by scalar")
  end
end

function Vector.__unm(v)
  return Vector.new(-v.x, -v.y)
end

function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
  -- Compare by magnitude
  return a:magnitude() < b:magnitude()
end

function Vector.__le(a, b)
  return a:magnitude() <= b:magnitude()
end

function Vector.__tostring(v)
  return string.format("Vector(%.2f, %.2f)", v.x, v.y)
end

function Vector.__concat(a, b)
  return tostring(a) .. " " .. tostring(b)
end

--- Calculate magnitude
function Vector:magnitude()
  return math.sqrt(self.x * self.x + self.y * self.y)
end

--- Normalize vector
function Vector:normalize()
  local mag = self:magnitude()
  if mag > 0 then
    return Vector.new(self.x / mag, self.y / mag)
  end
  return Vector.new(0, 0)
end

M.Vector = Vector

-- ============================================================================
-- PART 2: CALLABLE OBJECTS - __call Metamethod
-- ============================================================================

--- Counter class that can be called like a function
-- Demonstrates: __call metamethod, closures, state management
local Counter = {}
Counter.__index = Counter

function Counter.new(initial, step)
  local self = setmetatable({
    value = initial or 0,
    step = step or 1,
    history = {},
  }, Counter)
  return self
end

--- Make Counter callable - each call increments and returns value
function Counter:__call()
  self.value = self.value + self.step
  table.insert(self.history, self.value)
  return self.value
end

function Counter:reset()
  self.value = 0
  self.history = {}
end

function Counter:get_history()
  return self.history
end

M.Counter = Counter

-- ============================================================================
-- PART 3: WEAK TABLES - Memory Management and Caching
-- ============================================================================

--- Create a memoization cache using weak tables
-- Demonstrates: weak tables, garbage collection awareness
-- @param func function Function to memoize
-- @return function Memoized function
function M.memoize_weak(func)
  -- Weak-keyed cache - entries removed when keys are garbage collected
  local cache = setmetatable({}, {__mode = "k"})

  return function(arg)
    if cache[arg] == nil then
      cache[arg] = func(arg)
    end
    return cache[arg]
  end
end

--- Object pool using weak references
-- Demonstrates: weak values, resource pooling
local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new()
  return setmetatable({
    -- Weak-valued table - objects removed when no other references exist
    pool = setmetatable({}, {__mode = "v"}),
    created = 0,
    reused = 0,
  }, ObjectPool)
end

function ObjectPool:acquire(constructor)
  local obj = table.remove(self.pool)
  if obj then
    self.reused = self.reused + 1
    return obj
  else
    self.created = self.created + 1
    return constructor()
  end
end

function ObjectPool:release(obj)
  table.insert(self.pool, obj)
end

function ObjectPool:stats()
  return {
    created = self.created,
    reused = self.reused,
    pooled = #self.pool,
  }
end

M.ObjectPool = ObjectPool

-- ============================================================================
-- PART 4: ADVANCED COROUTINES - Generators and Async Patterns
-- ============================================================================

--- Fibonacci generator using coroutines
-- Demonstrates: coroutine-based generators, yield
-- @param max number Maximum value (optional)
-- @return function Iterator function
function M.fibonacci(max)
  return coroutine.wrap(function()
    local a, b = 0, 1
    while not max or a <= max do
      coroutine.yield(a)
      a, b = b, a + b
    end
  end)
end

--- Prime number generator
-- Demonstrates: coroutines with complex logic
function M.primes(max)
  return coroutine.wrap(function()
    coroutine.yield(2)

    local function is_prime(n)
      if n < 2 then return false end
      if n == 2 then return true end
      if n % 2 == 0 then return false end

      for i = 3, math.sqrt(n), 2 do
        if n % i == 0 then return false end
      end
      return true
    end

    local n = 3
    while not max or n <= max do
      if is_prime(n) then
        coroutine.yield(n)
      end
      n = n + 2
    end
  end)
end

--- Producer-consumer pattern using coroutines
-- Demonstrates: cooperative multitasking, coroutine communication
function M.create_producer(items)
  return coroutine.create(function()
    for _, item in ipairs(items) do
      local status = coroutine.yield(item)
      if status == "stop" then
        break
      end
    end
  end)
end

function M.consume_from(producer, consumer_func)
  local results = {}

  while coroutine.status(producer) ~= "dead" do
    local ok, value = coroutine.resume(producer)

    if ok and value then
      local result = consumer_func(value)
      table.insert(results, result)
    end
  end

  return results
end

--- Async-like pattern using coroutines
-- Demonstrates: continuation-passing style, async simulation
function M.async(func)
  return function(...)
    local co = coroutine.create(func)
    local function step(...)
      local ok, result = coroutine.resume(co, ...)
      if not ok then
        error(result)
      end
      return result
    end
    return step(...)
  end
end

function M.await(value)
  return coroutine.yield(value)
end

-- ============================================================================
-- PART 5: ENVIRONMENT MANIPULATION - _ENV and Sandboxing
-- ============================================================================

--- Execute code in a sandboxed environment
-- Demonstrates: _ENV manipulation, security, metatable tricks
-- @param code string Lua code to execute
-- @param allowed_globals table Allowed global variables
-- @return any Result of code execution
function M.sandbox(code, allowed_globals)
  allowed_globals = allowed_globals or {}

  -- Create a safe environment with limited globals
  local safe_env = {
    -- Safe standard functions
    assert = assert,
    error = error,
    ipairs = ipairs,
    pairs = pairs,
    next = next,
    pcall = pcall,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack or table.unpack,

    -- Safe standard libraries
    math = math,
    string = string,
    table = table,

    -- Custom allowed globals
  }

  for k, v in pairs(allowed_globals) do
    safe_env[k] = v
  end

  -- Make environment read-only for security
  local protected_env = setmetatable({}, {
    __index = safe_env,
    __newindex = function(_, key, _)
      error("Attempt to modify sandbox environment: " .. tostring(key), 2)
    end,
  })

  local func, err = load(code, "sandbox", "t", protected_env)
  if not func then
    return nil, err
  end

  return pcall(func)
end

--- Create a module with private state using environments
-- Demonstrates: module pattern with true privacy
function M.create_private_module()
  local private_state = {
    secret = "This cannot be accessed from outside",
    counter = 0,
  }

  -- Public interface
  local public = {}

  function public.increment()
    private_state.counter = private_state.counter + 1
    return private_state.counter
  end

  function public.get_count()
    return private_state.counter
  end

  -- The secret is truly private - no way to access it from outside

  return public
end

-- ============================================================================
-- PART 6: ADVANCED PATTERN MATCHING AND STRING MANIPULATION
-- ============================================================================

--- Parse complex structured data using patterns
-- Demonstrates: advanced pattern matching, captures, balanced matching
M.patterns = {}

--- Parse email address into components
function M.patterns.parse_email(email)
  local pattern = "^([%w._-]+)@([%w.-]+)%.([%w]+)$"
  local user, domain, tld = email:match(pattern)

  if user then
    return {
      user = user,
      domain = domain,
      tld = tld,
      full = email,
    }
  end

  return nil
end

--- Parse URL into components
function M.patterns.parse_url(url)
  local pattern = "^(https?)://([^/]+)(.*)$"
  local protocol, host, path = url:match(pattern)

  if protocol then
    local port = host:match(":(%d+)$")
    if port then
      host = host:gsub(":%d+$", "")
    end

    return {
      protocol = protocol,
      host = host,
      port = port and tonumber(port),
      path = path ~= "" and path or "/",
    }
  end

  return nil
end

--- Extract balanced parentheses content
-- Demonstrates: %b pattern for balanced matching
function M.patterns.extract_balanced(str, open, close)
  open = open or "("
  close = close or ")"

  local results = {}
  local pattern = "%" .. open .. "[^" .. close .. "]*%" .. close

  for match in str:gmatch(pattern) do
    -- Remove outer brackets
    local content = match:sub(2, -2)
    table.insert(results, content)
  end

  return results
end

--- Perform multi-line pattern matching
function M.patterns.match_multiline(str, pattern)
  -- Temporarily replace newlines to match across lines
  local normalized = str:gsub("\n", "\001")
  local matches = {}

  for match in normalized:gmatch(pattern) do
    table.insert(matches, match:gsub("\001", "\n"))
  end

  return matches
end

-- ============================================================================
-- PART 7: METAPROGRAMMING - Debug Library and Reflection
-- ============================================================================

--- Get detailed function information
-- Demonstrates: debug library, introspection
function M.inspect_function(func)
  local info = debug.getinfo(func)

  return {
    name = info.name,
    source = info.source,
    line_defined = info.linedefined,
    last_line_defined = info.lastlinedefined,
    num_params = info.nparams,
    is_vararg = info.isvararg,
    num_upvalues = info.nups,
  }
end

--- List all upvalues of a function
function M.list_upvalues(func)
  local upvalues = {}
  local i = 1

  while true do
    local name, value = debug.getupvalue(func, i)
    if not name then break end

    upvalues[i] = {
      name = name,
      value = value,
      type = type(value),
    }

    i = i + 1
  end

  return upvalues
end

--- Modify an upvalue (dangerous but powerful!)
-- Demonstrates: upvalue manipulation
function M.modify_upvalue(func, index, new_value)
  local name, old_value = debug.getupvalue(func, index)
  if name then
    debug.setupvalue(func, index, new_value)
    return old_value
  end
  return nil
end

--- Get call stack information
function M.get_call_stack()
  local stack = {}
  local level = 2  -- Skip this function and debug.getinfo

  while true do
    local info = debug.getinfo(level, "nSl")
    if not info then break end

    table.insert(stack, {
      name = info.name or "?",
      source = info.source,
      line = info.currentline,
      what = info.what,
    })

    level = level + 1
  end

  return stack
end

-- ============================================================================
-- PART 8: PERFORMANCE PATTERNS - Optimization Techniques
-- ============================================================================

--- Local caching of global functions for performance
-- Demonstrates: performance optimization pattern
M.performance = {}

do
  -- Cache frequently used global functions as locals
  local insert = table.insert
  local concat = table.concat
  local format = string.format

  --- Build a string efficiently using table concatenation
  -- Much faster than repeated string concatenation
  function M.performance.build_string(parts)
    local buffer = {}
    for _, part in ipairs(parts) do
      insert(buffer, tostring(part))
    end
    return concat(buffer)
  end

  --- Batch process items with batching
  function M.performance.batch_process(items, batch_size, processor)
    batch_size = batch_size or 100
    local results = {}

    for i = 1, #items, batch_size do
      local batch = {}
      for j = i, math.min(i + batch_size - 1, #items) do
        insert(batch, items[j])
      end

      local batch_results = processor(batch)
      for _, result in ipairs(batch_results) do
        insert(results, result)
      end
    end

    return results
  end
end

--- Demonstrate tail call optimization
-- Lua optimizes tail calls to prevent stack overflow
function M.tail_call_factorial(n, accumulator)
  accumulator = accumulator or 1

  if n <= 1 then
    return accumulator
  end

  -- This is a tail call - no operations after the recursive call
  return M.tail_call_factorial(n - 1, n * accumulator)
end

--- Non-tail-recursive version for comparison
function M.regular_factorial(n)
  if n <= 1 then
    return 1
  end

  -- NOT a tail call - multiplication happens after the recursive call
  return n * M.regular_factorial(n - 1)
end

-- ============================================================================
-- PART 9: FUNCTIONAL PROGRAMMING PATTERNS
-- ============================================================================

M.functional = {}

--- Compose functions
-- Demonstrates: function composition, higher-order functions
function M.functional.compose(...)
  local funcs = {...}

  return function(...)
    local result = funcs[#funcs](...)

    for i = #funcs - 1, 1, -1 do
      result = funcs[i](result)
    end

    return result
  end
end

--- Pipe functions (left to right composition)
function M.functional.pipe(...)
  local funcs = {...}

  return function(...)
    local result = funcs[1](...)

    for i = 2, #funcs do
      result = funcs[i](result)
    end

    return result
  end
end

--- Partial application
function M.functional.partial(func, ...)
  local bound_args = {...}

  return function(...)
    local args = {}
    for _, v in ipairs(bound_args) do
      table.insert(args, v)
    end
    for _, v in ipairs({...}) do
      table.insert(args, v)
    end

    return func(unpack(args))
  end
end

--- Curry a function
function M.functional.curry(func, num_args)
  num_args = num_args or 2

  local function curry_helper(args_so_far)
    return function(arg)
      local new_args = {}
      for _, v in ipairs(args_so_far) do
        table.insert(new_args, v)
      end
      table.insert(new_args, arg)

      if #new_args >= num_args then
        return func(unpack(new_args))
      else
        return curry_helper(new_args)
      end
    end
  end

  return curry_helper({})
end

--- Flip function arguments
function M.functional.flip(func)
  return function(a, b)
    return func(b, a)
  end
end

-- ============================================================================
-- PART 10: CLASS SYSTEM WITH INHERITANCE
-- ============================================================================

--- Simple class system with inheritance
-- Demonstrates: OOP patterns, inheritance, polymorphism
function M.class(base)
  local cls = {}
  cls.__index = cls

  if base then
    setmetatable(cls, {__index = base})
  end

  function cls:new(...)
    local instance = setmetatable({}, cls)
    if instance.init then
      instance:init(...)
    end
    return instance
  end

  function cls:is_instance_of(class)
    local mt = getmetatable(self)
    while mt do
      if mt == class then
        return true
      end
      mt = getmetatable(mt)
    end
    return false
  end

  return cls
end

return M
