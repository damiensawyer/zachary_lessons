# Idiomatic Lua Patterns

## What Lua Doesn't Have (And What It Uses Instead)

### No Classes → Tables + Metatables

**Other languages:**
```java
class Person {
    private String name;
    public Person(String name) { this.name = name; }
    public String getName() { return this.name; }
}
```

**Lua (Closure Pattern):**
```lua
local function Person(name)
  local self = {}

  function self.get_name()
    return name  -- Closure over name
  end

  return self
end
```

**Lua (Metatable Pattern - Preferred):**
```lua
local Person = {}
Person.__index = Person

function Person.new(name)
  local self = setmetatable({}, Person)
  self.name = name
  return self
end

function Person:get_name()
  return self.name
end

-- Usage
local p = Person.new("Alice")
print(p:get_name())
```

### No Dependency Injection Framework → Function Injection

**Other languages (with framework):**
```typescript
@Injectable()
class UserService {
  constructor(@Inject(Database) private db: Database) {}
}
```

**Lua:**
```lua
-- Constructor injection via closure
local function UserService(db)
  local self = {}

  function self.create_user(name)
    return db.insert("users", {name = name})
  end

  return self
end

-- Usage
local service = UserService(real_db)        -- Production
local test_service = UserService(mock_db)   -- Testing
```

**See:** `src/user_service.lua` for full example

### No Monads → Multiple Returns

**Other languages (Maybe monad):**
```haskell
findUser :: Int -> Maybe User
result = case findUser 1 of
  Just user -> process user
  Nothing -> handleError
```

**Lua:**
```lua
local function find_user(id)
  local user = db:query("SELECT * FROM users WHERE id = ?", id)
  return user  -- Can be nil
end

local user = find_user(1)
if user then
  process(user)
else
  handle_error()
end
```

**Other languages (Either monad):**
```rust
fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err("division by zero")
    } else {
        Ok(a / b)
    }
}
```

**Lua:**
```lua
local function divide(a, b)
  if b == 0 then
    return nil, "division by zero"
  end
  return a / b
end

local result, err = divide(10, 0)
if not result then
  print("Error: " .. err)
else
  print("Result: " .. result)
end
```

### No Null Safety → Explicit nil Checks

**Other languages:**
```kotlin
val name: String? = user?.name
val length = name?.length ?: 0
```

**Lua:**
```lua
local name = user and user.name
local length = name and #name or 0

-- More explicit
if user and user.name then
  local length = #user.name
end
```

### No Async/Await → Coroutines

**Other languages:**
```javascript
async function fetchUser(id) {
  const response = await fetch(`/users/${id}`)
  return await response.json()
}
```

**Lua:**
```lua
local function fetch_user(id)
  coroutine.yield("http_request", "/users/" .. id)
  local response = coroutine.yield("read_response")
  return response
end

local co = coroutine.create(fetch_user)
local ok, action, url = coroutine.resume(co, 1)
-- Handle request...
coroutine.resume(co, response_data)
```

**Note:** Most Lua uses synchronous I/O. For async, see libraries like:
- `lua-nginx-module` (OpenResty)
- `luvit` (libuv bindings)

### No Generics → Duck Typing

**Other languages:**
```java
<T> T first(List<T> list) {
    return list.get(0);
}
```

**Lua:**
```lua
local function first(list)
  return list[1]  -- Works with any table
end

-- Or with type checking
local function first(list)
  assert(type(list) == "table", "expected table")
  return list[1]
end
```

### No Interfaces → Duck Typing + Conventions

**Other languages:**
```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

func process(r Reader) { ... }
```

**Lua:**
```lua
-- Just expect methods to exist
local function process(reader)
  local data = reader:read()  -- Runtime duck typing
  -- ...
end

-- Optional: explicit contract checking
local function process(reader)
  assert(type(reader.read) == "function", "reader must have read method")
  local data = reader:read()
end
```

## Idiomatic Lua Patterns

### 1. Multiple Return Values for Errors

```lua
-- GOOD: Idiomatic Lua
local function read_file(path)
  local file, err = io.open(path, "r")
  if not file then
    return nil, err
  end

  local content = file:read("*all")
  file:close()
  return content
end

local content, err = read_file("data.txt")
if not content then
  print("Error: " .. err)
  return
end

-- BAD: Throwing errors for expected failures
local function read_file(path)
  local file = assert(io.open(path, "r"))  -- Don't do this for expected errors
  return file:read("*all")
end
```

### 2. Tables as Configuration

```lua
-- GOOD: Named parameters via table
local function create_window(opts)
  opts = opts or {}
  local width = opts.width or 800
  local height = opts.height or 600
  local title = opts.title or "Untitled"
  local resizable = opts.resizable ~= false  -- Default true
  -- ...
end

create_window{
  title = "My App",
  width = 1024,
  height = 768
}

-- BAD: Too many positional parameters
local function create_window(width, height, title, resizable, fullscreen, vsync)
  -- Hard to remember order
end
```

### 3. Metatables for OOP

```lua
-- GOOD: Metatable-based objects
local Timer = {}
Timer.__index = Timer

function Timer.new(duration)
  local self = setmetatable({}, Timer)
  self.duration = duration
  self.elapsed = 0
  return self
end

function Timer:update(dt)
  self.elapsed = self.elapsed + dt
  return self.elapsed >= self.duration
end

-- GOOD: Inheritance
local Countdown = setmetatable({}, {__index = Timer})
Countdown.__index = Countdown

function Countdown.new(duration, callback)
  local self = setmetatable(Timer.new(duration), Countdown)
  self.callback = callback
  return self
end

function Countdown:update(dt)
  if Timer.update(self, dt) then  -- Call parent
    self.callback()
  end
end
```

### 4. Module Pattern

```lua
-- GOOD: Return table with public API
local M = {}

local function private_helper()
  return "private"
end

function M.public_function()
  return private_helper()
end

M.CONSTANT = 42

return M

-- BAD: Global namespace pollution
function public_function()  -- Global!
  return helper()
end

CONSTANT = 42  -- Global!
```

### 5. Guard Clauses (Early Return)

```lua
-- GOOD: Early returns reduce nesting
local function process_user(user)
  if not user then
    return nil, "user required"
  end

  if not user.id then
    return nil, "user.id required"
  end

  if user.banned then
    return nil, "user is banned"
  end

  -- Main logic here, not deeply nested
  return do_work(user)
end

-- BAD: Deep nesting
local function process_user(user)
  if user then
    if user.id then
      if not user.banned then
        return do_work(user)
      else
        return nil, "user is banned"
      end
    else
      return nil, "user.id required"
    end
  else
    return nil, "user required"
  end
end
```

### 6. Iterators for Lazy Evaluation

```lua
-- GOOD: Iterator (lazy, memory efficient)
local function lines_from(filename)
  local file = io.open(filename)
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

for line in lines_from("huge.txt") do
  if line:match("pattern") then
    print(line)
    break  -- Can stop early
  end
end

-- BAD: Load all into memory
local function read_all_lines(filename)
  local file = io.open(filename)
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  return lines
end
```

### 7. Functional Utilities

```lua
-- Common functional patterns
local function map(fn, list)
  local result = {}
  for i, v in ipairs(list) do
    result[i] = fn(v)
  end
  return result
end

local function filter(pred, list)
  local result = {}
  for _, v in ipairs(list) do
    if pred(v) then
      table.insert(result, v)
    end
  end
  return result
end

local function reduce(fn, acc, list)
  for _, v in ipairs(list) do
    acc = fn(acc, v)
  end
  return acc
end

-- Usage
local nums = {1, 2, 3, 4, 5}
local doubled = map(function(x) return x * 2 end, nums)
local evens = filter(function(x) return x % 2 == 0 end, nums)
local sum = reduce(function(a, b) return a + b end, 0, nums)
```

### 8. Memoization

```lua
-- GOOD: Cache expensive computations
local function memoize(fn)
  local cache = {}
  return function(...)
    local key = table.concat({...}, ",")
    if cache[key] == nil then
      cache[key] = fn(...)
    end
    return cache[key]
  end
end

local fib = memoize(function(n)
  if n <= 1 then return n end
  return fib(n - 1) + fib(n - 2)
end)

print(fib(100))  -- Fast!
```

### 9. Object Pools (Memory Management)

```lua
-- Reuse objects to reduce GC pressure
local Pool = {}
Pool.__index = Pool

function Pool.new(create_fn)
  local self = setmetatable({}, Pool)
  self.available = {}
  self.create_fn = create_fn
  return self
end

function Pool:acquire()
  local obj = table.remove(self.available)
  if not obj then
    obj = self.create_fn()
  end
  return obj
end

function Pool:release(obj)
  table.insert(self.available, obj)
end

-- Usage
local bullet_pool = Pool.new(function()
  return {x = 0, y = 0, active = false}
end)

local bullet = bullet_pool:acquire()
bullet.active = true
-- ... use bullet ...
bullet_pool:release(bullet)
```

### 10. Signal/Event System

```lua
-- Lightweight event system
local Signal = {}
Signal.__index = Signal

function Signal.new()
  local self = setmetatable({}, Signal)
  self.listeners = {}
  return self
end

function Signal:connect(fn)
  table.insert(self.listeners, fn)
  return fn  -- Return for disconnection
end

function Signal:disconnect(fn)
  for i, listener in ipairs(self.listeners) do
    if listener == fn then
      table.remove(self.listeners, i)
      break
    end
  end
end

function Signal:fire(...)
  for _, listener in ipairs(self.listeners) do
    listener(...)
  end
end

-- Usage
local on_player_died = Signal.new()

on_player_died:connect(function(player)
  print(player.name .. " died!")
end)

on_player_died:fire(player)
```

## Anti-Patterns to Avoid

### 1. Global Variables

```lua
-- BAD
total = 0  -- Pollutes global namespace

-- GOOD
local total = 0
```

### 2. String Concatenation in Loops

```lua
-- BAD
local result = ""
for i = 1, 10000 do
  result = result .. tostring(i)  -- Creates new string each iteration
end

-- GOOD
local parts = {}
for i = 1, 10000 do
  table.insert(parts, tostring(i))
end
local result = table.concat(parts)
```

### 3. Modifying Table During Iteration

```lua
-- BAD
for i, v in ipairs(list) do
  if v % 2 == 0 then
    table.remove(list, i)  -- Changes indices during iteration
  end
end

-- GOOD: Iterate backwards
for i = #list, 1, -1 do
  if list[i] % 2 == 0 then
    table.remove(list, i)
  end
end

-- BETTER: Build new table
local filtered = {}
for _, v in ipairs(list) do
  if v % 2 ~= 0 then
    table.insert(filtered, v)
  end
end
```

### 4. Using # with Non-Sequential Tables

```lua
local t = {10, 20, nil, 40}
print(#t)  -- Might be 2 or 4, undefined!

-- GOOD: Use explicit counter
local function count_items(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end
```

## Performance Tips

1. **Localize globals**: `local insert = table.insert` (faster access)
2. **Reuse tables**: Don't create new tables in tight loops
3. **Use `ipairs` for arrays**: Faster than `pairs`
4. **Cache table length**: `local n = #t` outside loop
5. **Prefer table pool**: Reduce garbage collection
6. **Use LuaJIT**: 10-100x faster for numeric code

## When Lua Shines

- **Embedded scripting**: Game engines, apps (WoW, Roblox, Neovim)
- **Configuration**: Human-readable config files
- **Rapid prototyping**: Simple syntax, no compilation
- **Data description**: Tables are powerful and flexible
- **Small binaries**: Tiny runtime (~200KB)

## When to Consider Alternatives

- **Large codebases**: No static typing, IDE support limited
- **Concurrency**: No native threading (use C extensions)
- **Heavy computation**: Use LuaJIT or call C libraries
- **Type safety**: Consider TypeScript or similar
