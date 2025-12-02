# Quickstart Guide

Get up and running with this Lua learning project in 5 minutes.

## 1. Install Dependencies (One-time)

```bash
# Install system packages
sudo pacman -S lua luarocks sqlite

# Install Lua packages
luarocks install --local busted
luarocks install --local lsqlite3
luarocks install --local luacov
```

## 2. Set Up Environment

Add to your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
# Lua environment
eval $(luarocks path --local)
```

Then reload:

```bash
source ~/.bashrc  # or ~/.zshrc
```

## 3. Try It Out

```bash
# From project root
cd /home/damien/code/zachary_lessons/damien_playground

# Run the sample app
./run.sh lua src/app.lua

# Run all tests
./run.sh busted

# You should see:
# - App creates users, queries database, updates/deletes
# - Tests: "38 successes / 0 failures"
```

## 4. Learn Lua

Read in this order:

1. **`docs/quick_reference.md`** - Quick syntax reference (5 min)
2. **`docs/lua_lessons.md`** - Complete tutorial, simple → advanced (30 min)
3. **`docs/idiomatic_patterns.md`** - Lua idioms & what replaces DI/FP/monads (20 min)
4. **`src/`** - Study working code
5. **`tests/`** - See testing patterns with mocks/fakes

## 5. LazyVim + Neotest (Optional)

For in-editor test running:

1. Read `docs/lazyvim_setup.md`
2. Install neotest plugins
3. Use `<leader>tt` to run tests in Neovim

## Common Commands

```bash
# Run tests
./run.sh busted
./run.sh busted tests/db_spec.lua

# Run app
./run.sh lua src/app.lua

# Coverage
./run.sh busted --coverage
luacov && cat luacov.report.out

# Direct (if environment configured)
busted
lua src/app.lua
```

## Project Layout

```
.
├── QUICKSTART.md              ← You are here
├── README.md                  ← Full documentation
├── run.sh                     ← Helper script (sets paths)
│
├── docs/
│   ├── quick_reference.md     ← Cheat sheet
│   ├── lua_lessons.md         ← Tutorial: simple → advanced
│   ├── idiomatic_patterns.md  ← Lua idioms vs other languages
│   └── lazyvim_setup.md       ← Neotest configuration
│
├── src/
│   ├── db.lua                 ← SQLite wrapper (read/write)
│   ├── user_service.lua       ← Business logic (DI example)
│   └── app.lua                ← Main application
│
└── tests/
    ├── db_spec.lua            ← Database tests
    └── user_service_spec.lua  ← Service tests (mocks/fakes)
```

## What You'll Learn

- **Lua Basics**: Tables, functions, metatables, modules
- **Advanced**: Closures, iterators, coroutines, OOP patterns
- **Idiomatic Lua**: No classes/DI/monads, what to use instead
- **Testing**: Busted framework, mocks, fakes, dependency injection
- **SQLite**: Database operations with prepared statements
- **LazyVim**: Running tests in Neovim with neotest

## Next Steps

1. Modify `src/app.lua` - add features
2. Write new tests in `tests/`
3. Create your own modules
4. Experiment with metatables, coroutines
5. Build something real!

## Troubleshooting

**"module not found" errors:**
```bash
eval $(luarocks path --local)
export LUA_PATH="./src/?.lua;$LUA_PATH"
# Or just use: ./run.sh
```

**Tests not running:**
```bash
# Check busted is installed
which busted
luarocks list | grep busted

# Try with helper script
./run.sh busted
```

**SQLite errors:**
```bash
# Check lsqlite3 is installed
luarocks list | grep lsqlite3

# Reinstall if needed
luarocks install --local lsqlite3
```

## Resources

- [Lua Manual](https://www.lua.org/manual/5.4/)
- [Busted Testing](https://lunarmodules.github.io/busted/)
- [LuaRocks](https://luarocks.org/)
- [LazyVim](https://www.lazyvim.org/)

## Feedback

This is a learning project. Experiment, break things, rebuild. That's how you learn Lua!
