# Lua Quick Reference

## Essential Commands

```bash
# Install dependencies
luarocks install --local busted lsqlite3 luacov

# Run application
lua src/app.lua

# Run tests
./run.sh busted                        # All tests
./run.sh busted tests/db_spec.lua      # Single file

# Generate and view coverage report
./run.sh busted --coverage             # 1. Generate stats file
./run.sh luacov                        # 2. Generate HTML report
# 3. Open luacov.report.html in your browser
```

## Core Syntax

```lua
-- Variables
local x = 42                  -- Local (always prefer)
y = "global"                  -- Global (avoid)

-- Types
type(nil)      --> "nil"
type(true)     --> "boolean"
type(42)       --> "number"
type("text")   --> "string"
type({})       --> "table"
type(print)    --> "function"

-- Truthy/Falsy (only nil and false are falsy!)
if 0 then print("0 is truthy") end
if "" then print("empty string is truthy") end

-- Tables (1-indexed!)
local arr = {10, 20, 30}
print(arr[1])  --> 10
local map = {x=1, y=2}
print(map.x)   --> 1

-- Functions
local function add(a, b) return a + b end
local sub = function(a, b) return a - b end

-- Multiple returns
local function div(a, b)
  if b == 0 then return nil, "division by zero" end
  return a / b
end
local result, err = div(10, 0)

-- Varargs
local function sum(...)
  local total = 0
  for _, v in ipairs({...}) do total = total + v end
  return total
end
```

## Iteration

```lua
-- Numeric for
for i = 1, 10 do print(i) end
for i = 10, 1, -1 do print(i) end

-- Array iteration (ipairs)
for i, v in ipairs({10, 20, 30}) do
  print(i, v)
end

-- All pairs (pairs)
for k, v in pairs({a=1, b=2}) do
  print(k, v)
end

-- While/repeat
while condition do end
repeat until condition
```

## OOP Pattern

```lua
local Class = {}
Class.__index = Class

function Class.new(x)
  local self = setmetatable({}, Class)
  self.x = x
  return self
end

function Class:method()  -- Colon = implicit self
  return self.x * 2
end

local obj = Class.new(5)
print(obj:method())  --> 10
```

## Module Pattern

```lua
-- mymodule.lua
local M = {}

local function private() end

function M.public() return private() end

return M

-- Usage
local mymodule = require("mymodule")
mymodule.public()
```

## Error Handling

```lua
-- Pattern 1: Multiple returns (idiomatic)
local result, err = operation()
if not result then
  print("Error: " .. err)
end

-- Pattern 2: pcall (protected call)
local ok, result = pcall(risky_function)
if not ok then
  print("Caught: " .. result)
end

-- Pattern 3: assert (fail fast)
local value = assert(operation(), "must succeed")
```

## String Operations

```lua
s = "hello"
#s                        --> 5 (length)
s:upper()                 --> "HELLO"
s:sub(1, 2)              --> "he"
s:find("ll")             --> 3, 4
s:gsub("l", "L")         --> "heLLo"
"a" .. "b"               --> "ab" (concat)
string.format("%d", 42)  --> "42"
```

## Table Operations

```lua
t = {10, 20, 30}
table.insert(t, 40)         -- Append
table.insert(t, 1, 5)       -- Insert at pos
table.remove(t, 2)          -- Remove at pos
table.concat(t, ", ")       -- Join
table.sort(t)               -- In-place sort
#t                          --> length
```

## Common Idioms

```lua
-- Default values
x = x or 10
name = opts.name or "default"

-- Ternary (kind of)
result = condition and true_val or false_val

-- Safe navigation
value = obj and obj.field and obj.field.nested

-- Table as set
set = {foo=true, bar=true}
if set[key] then ... end

-- Swap
a, b = b, a

-- Unpack (spread)
print(table.unpack({1, 2, 3}))  --> 1  2  3
```

## Metatable Magic

```lua
mt = {
  __index = {...},         -- Read access / inheritance
  __newindex = {...},      -- Write access
  __call = {...},          -- Make callable
  __tostring = {...},      -- String conversion
  __add = {...},           -- + operator
  __eq = {...},            -- == operator
  __len = {...},           -- # operator
}
setmetatable(obj, mt)
```

## Testing (Busted)

```lua
describe("module", function()
  local obj

  before_each(function()
    obj = create_object()
  end)

  after_each(function()
    cleanup()
  end)

  it("does something", function()
    assert.equals(expected, obj:method())
  end)

  it("handles errors", function()
    assert.has_error(function()
      obj:bad_method()
    end)
  end)
end)
```

## LuaRocks (Package Manager)

```bash
# Search packages
luarocks search sqlite

# Install package
luarocks install lsqlite3

# Install locally (no sudo)
luarocks install --local package_name

# List installed
luarocks list

# Show package info
luarocks show lsqlite3

# Remove package
luarocks remove lsqlite3
```

## Performance

```lua
-- Localize globals (faster)
local insert = table.insert
local sin = math.sin

-- Reuse tables
local temp = {}
for i = 1, n do
  temp[1] = value
  process(temp)
end

-- Cache length
local n = #t
for i = 1, n do
  process(t[i])
end
```

## Debugging

```lua
-- Print debugging
print("value =", value)
print(string.format("x=%d y=%d", x, y))

-- Inspect tables
for k, v in pairs(t) do print(k, v) end

-- Type checking
assert(type(x) == "number")

-- Stack trace
print(debug.traceback())

-- Get info
info = debug.getinfo(func)
```

## Gotchas

1. **Tables are 1-indexed**: `arr[1]` not `arr[0]`
2. **Only nil and false are falsy**: `0` and `""` are truthy
3. **# operator unreliable**: For non-sequential tables
4. **No continue keyword**: Use goto or restructure
5. **Local by default**: Always use `local`
6. **String immutable**: Concatenation creates new string
7. **Table assignment is reference**: `b = a` doesn't copy

## LazyVim Test Keys

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file |
| `<leader>ta` | Run all |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Show output |

## Project Structure

```
.
├── src/               # Source code
├── tests/             # Tests (*_spec.lua)
├── docs/              # Documentation
├── .busted            # Test config
├── README.md          # Getting started
└── *.rockspec         # Package definition
```

## Learn More

- Lessons: `docs/lua_lessons.md`
- Patterns: `docs/idiomatic_patterns.md`
- LazyVim: `docs/lazyvim_setup.md`
- Code: `src/*.lua`
- Tests: `tests/*_spec.lua`
