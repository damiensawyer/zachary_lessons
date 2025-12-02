# Lua Syntax: Simple to Advanced

## 1. Basics

```lua
-- Comments: single line with --
--[[ Multi-line
     comments ]]

-- Variables: dynamically typed, global by default
x = 42
local y = "local scope"  -- Always use 'local'

-- Types: nil, boolean, number, string, function, table, thread, userdata
type(nil)      --> "nil"
type(true)     --> "boolean"
type(3.14)     --> "number"    -- All numbers are double
type("text")   --> "string"
type({})       --> "table"
type(print)    --> "function"

-- Nil: uninitialized variables are nil
local z; print(z)  --> nil

-- Booleans: nil and false are falsy; everything else is truthy (including 0!)
if 0 then print("0 is truthy") end

-- Strings: immutable, efficient
s1 = 'single quotes'
s2 = "double quotes"
s3 = [[multi
line]]
s4 = "concat " .. "with .."
s5 = string.format("formatted: %d", 42)
```

## 2. Control Structures

```lua
-- If/elseif/else
if x > 10 then
  print("big")
elseif x > 5 then
  print("medium")
else
  print("small")
end

-- While
local i = 1
while i <= 5 do
  print(i)
  i = i + 1
end

-- Repeat-until (like do-while)
repeat
  print(i)
  i = i - 1
until i == 0

-- For (numeric)
for i = 1, 10 do print(i) end          -- 1 to 10
for i = 10, 1, -1 do print(i) end      -- 10 to 1
for i = 0, 10, 2 do print(i) end       -- even numbers

-- For (generic iterator)
local t = {10, 20, 30}
for index, value in ipairs(t) do
  print(index, value)
end

local map = {a=1, b=2}
for key, value in pairs(map) do
  print(key, value)
end
```

## 3. Functions

```lua
-- Basic function
local function add(a, b)
  return a + b
end

-- Multiple returns (idiomatic error handling)
local function divide(a, b)
  if b == 0 then
    return nil, "division by zero"
  end
  return a / b
end

local result, err = divide(10, 0)
if not result then
  print("Error: " .. err)
end

-- Variadic functions
local function sum(...)
  local args = {...}  -- Pack varargs into table
  local total = 0
  for _, v in ipairs(args) do
    total = total + v
  end
  return total
end

print(sum(1, 2, 3, 4))  --> 10

-- First-class functions
local function apply(f, x)
  return f(x)
end

local double = function(n) return n * 2 end
print(apply(double, 5))  --> 10

-- Closures (captures upvalues)
local function counter()
  local count = 0
  return function()
    count = count + 1
    return count
  end
end

local c = counter()
print(c())  --> 1
print(c())  --> 2
```

## 4. Tables: The Universal Data Structure

```lua
-- Arrays (1-indexed!)
local arr = {10, 20, 30}
print(arr[1])  --> 10
arr[4] = 40
print(#arr)    --> 4 (length operator)

-- Hash maps
local person = {
  name = "Alice",
  age = 30,
  ["key with spaces"] = "value"
}

print(person.name)        --> "Alice"
print(person["age"])      --> 30

-- Mixed (avoid in practice)
local mixed = {10, 20, x=30}
print(mixed[1], mixed.x)  --> 10  30

-- Table functions
table.insert(arr, 50)           -- Append
table.insert(arr, 1, 5)         -- Insert at position
table.remove(arr, 2)            -- Remove at position
table.concat(arr, ", ")         -- Join to string
table.sort(arr)                 -- In-place sort

-- Iterating
for i, v in ipairs(arr) do      -- Array iteration (stops at first nil)
  print(i, v)
end

for k, v in pairs(person) do    -- All key-value pairs
  print(k, v)
end
```

## 5. Metatables: Operator Overloading & Prototypes

```lua
-- Metatables enable operator overloading and prototypal inheritance
local Vector = {}

function Vector.new(x, y)
  local v = {x = x, y = y}
  setmetatable(v, {__index = Vector})
  return v
end

function Vector:length()  -- Sugar for Vector.length(self)
  return math.sqrt(self.x^2 + self.y^2)
end

-- Operator overloading
function Vector.__add(a, b)
  return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__tostring(v)
  return string.format("(%d, %d)", v.x, v.y)
end

local v1 = Vector.new(3, 4)
local v2 = Vector.new(1, 2)
local v3 = v1 + v2
print(v3)           --> (4, 6)
print(v1:length())  --> 5.0

-- Common metamethods:
-- __index    : read access (inheritance, lazy init)
-- __newindex : write access
-- __add, __sub, __mul, __div, __mod, __pow
-- __eq, __lt, __le
-- __tostring : string conversion
-- __call     : make table callable
-- __len      : # operator
```

## 6. Modules

```lua
-- File: mymodule.lua
local M = {}  -- Module table

local function private_helper()
  return "private"
end

function M.public_function()
  return private_helper() .. " + public"
end

M.CONSTANT = 42

return M

-- Usage:
local mymodule = require("mymodule")
print(mymodule.public_function())
print(mymodule.CONSTANT)

-- Alternative pattern with metatables
local M = {}
M.__index = M

function M.new(x)
  local self = setmetatable({}, M)
  self.x = x
  return self
end

function M:method()
  return self.x * 2
end

return M
```

## 7. Error Handling

```lua
-- Pattern 1: Multiple returns (idiomatic)
local function safe_divide(a, b)
  if b == 0 then
    return nil, "division by zero"
  end
  return a / b
end

local result, err = safe_divide(10, 0)
if not result then
  print("Error: " .. err)
end

-- Pattern 2: pcall (protected call)
local function risky_operation()
  error("something broke")
end

local ok, result = pcall(risky_operation)
if not ok then
  print("Caught error: " .. result)
end

-- Pattern 3: xpcall (with error handler)
local function error_handler(err)
  return debug.traceback("ERROR: " .. err, 2)
end

local ok, result = xpcall(risky_operation, error_handler)

-- Pattern 4: assert (fail fast)
local function must_succeed(val)
  assert(val ~= nil, "val must not be nil")
  return val * 2
end
```

## 8. Iterators

```lua
-- Stateless iterator
local function range(n)
  local i = 0
  return function()
    i = i + 1
    if i <= n then return i end
  end
end

for num in range(5) do
  print(num)
end

-- Stateful iterator pattern
local function lines_from(file_name)
  local file = io.open(file_name, "r")
  if not file then return function() end end

  return function()
    local line = file:read()
    if not line then
      file:close()
      return nil
    end
    return line
  end
end

for line in lines_from("data.txt") do
  print(line)
end
```

## 9. Coroutines (Collaborative Multithreading)

```lua
-- Coroutines = resumable functions (not OS threads!)
local function producer()
  for i = 1, 5 do
    print("producing " .. i)
    coroutine.yield(i)
  end
end

local co = coroutine.create(producer)

while coroutine.status(co) ~= "dead" do
  local ok, value = coroutine.resume(co)
  if ok and value then
    print("consumed " .. value)
  end
end

-- Pipeline pattern
local function filter(pred, src)
  return coroutine.wrap(function()
    for v in src do
      if pred(v) then
        coroutine.yield(v)
      end
    end
  end)
end

local function values(t)
  return coroutine.wrap(function()
    for _, v in ipairs(t) do
      coroutine.yield(v)
    end
  end)
end

local evens = filter(function(x) return x % 2 == 0 end, values({1,2,3,4,5,6}))
for v in evens do print(v) end  --> 2, 4, 6
```

## 10. OOP Patterns (No Classes!)

```lua
-- Pattern 1: Closure-based (encapsulation)
local function Person(name, age)
  local self = {}

  -- Private state
  local _name = name
  local _age = age

  -- Public methods
  function self.get_name()
    return _name
  end

  function self.birthday()
    _age = _age + 1
  end

  function self.get_age()
    return _age
  end

  return self
end

local p = Person("Alice", 30)
print(p.get_name())  --> Alice
p.birthday()
print(p.get_age())   --> 31

-- Pattern 2: Metatable-based (inheritance, faster)
local Animal = {}
Animal.__index = Animal

function Animal.new(name)
  local self = setmetatable({}, Animal)
  self.name = name
  return self
end

function Animal:speak()
  return "Some sound"
end

local Dog = setmetatable({}, {__index = Animal})
Dog.__index = Dog

function Dog.new(name, breed)
  local self = setmetatable(Animal.new(name), Dog)
  self.breed = breed
  return self
end

function Dog:speak()
  return "Woof!"
end

local d = Dog.new("Rex", "Labrador")
print(d:speak())      --> Woof!
print(d.name)         --> Rex
```

## 11. Functional Programming Patterns

```lua
-- Map
local function map(f, t)
  local result = {}
  for i, v in ipairs(t) do
    result[i] = f(v)
  end
  return result
end

-- Filter
local function filter(pred, t)
  local result = {}
  for _, v in ipairs(t) do
    if pred(v) then
      table.insert(result, v)
    end
  end
  return result
end

-- Reduce/Fold
local function reduce(f, acc, t)
  for _, v in ipairs(t) do
    acc = f(acc, v)
  end
  return acc
end

local nums = {1, 2, 3, 4, 5}
local doubled = map(function(x) return x * 2 end, nums)
local evens = filter(function(x) return x % 2 == 0 end, nums)
local sum = reduce(function(a, b) return a + b end, 0, nums)

-- Partial application
local function partial(f, ...)
  local args = {...}
  return function(...)
    local all_args = {table.unpack(args)}
    for _, v in ipairs({...}) do
      table.insert(all_args, v)
    end
    return f(table.unpack(all_args))
  end
end

local add = function(a, b) return a + b end
local add5 = partial(add, 5)
print(add5(10))  --> 15

-- Composition
local function compose(...)
  local fns = {...}
  return function(x)
    local result = x
    for i = #fns, 1, -1 do
      result = fns[i](result)
    end
    return result
  end
end

local inc = function(x) return x + 1 end
local dbl = function(x) return x * 2 end
local f = compose(inc, dbl)  -- dbl then inc
print(f(5))  --> 11
```

## 12. Idiomatic Lua

### Dependency Injection: Function Injection

```lua
-- No DI framework needed - just pass functions
local function UserService(db)
  local self = {}

  function self.create_user(name)
    return db.insert("users", {name = name})
  end

  function self.get_user(id)
    return db.query("users", id)
  end

  return self
end

-- Inject different implementations
local service = UserService(real_db)
local test_service = UserService(mock_db)
```

### No Monads: Multiple Returns

```lua
-- Instead of Maybe monad
local function find_user(id)
  if id == 1 then
    return {id=1, name="Alice"}
  else
    return nil
  end
end

-- Instead of Either monad
local function parse_int(s)
  local n = tonumber(s)
  if n then
    return n, nil
  else
    return nil, "not a number"
  end
end

-- Chain operations
local function chain(val, err, f)
  if not val then return nil, err end
  return f(val)
end
```

### Common Patterns

```lua
-- Guard clauses (early return)
local function process(data)
  if not data then return nil, "no data" end
  if #data == 0 then return nil, "empty data" end

  -- Process...
  return result
end

-- Default values
local function greet(name)
  name = name or "stranger"
  print("Hello, " .. name)
end

-- Table as config object
local function create_server(opts)
  opts = opts or {}
  local host = opts.host or "localhost"
  local port = opts.port or 8080
  local timeout = opts.timeout or 30
  -- ...
end

create_server{port = 3000, timeout = 60}
```

## Key Takeaways

1. **Tables everywhere**: Arrays, maps, objects, modules - all tables
2. **1-indexed**: Arrays start at 1, not 0
3. **Local by default**: Always use `local` to avoid globals
4. **Multiple returns**: Idiomatic error handling
5. **No classes**: Use metatables for OOP
6. **No type system**: Duck typing, runtime checks
7. **Simple module system**: Return a table
8. **Closures for DI**: Pass functions, not frameworks
9. **Truthy/falsy**: Only `nil` and `false` are falsy
10. **Coroutines not threads**: Cooperative, not preemptive
