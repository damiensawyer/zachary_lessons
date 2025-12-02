# Lua Learning Project

A comprehensive Lua learning project with SQLite integration, unit tests, and LazyVim/neotest support.

## Setup

```bash
# 1. Install Lua 5.4 and LuaRocks (package manager)
sudo pacman -S lua luarocks sqlite

# 2. Install required Lua packages
luarocks install --local busted        # Test framework
luarocks install --local lsqlite3      # SQLite bindings
luarocks install --local luacov        # Code coverage

# 3. Configure environment (add to ~/.bashrc or ~/.zshrc)
eval $(luarocks path --local)
export LUA_PATH="./src/?.lua;$LUA_PATH"

# Or source it per session
source <(echo 'eval $(luarocks path --local); export LUA_PATH="./src/?.lua;$LUA_PATH"')
```

## Project Structure

```
.
├── src/
│   ├── db.lua              # SQLite database module
│   ├── user_service.lua    # Business logic layer
│   └── app.lua             # Main application
├── tests/
│   ├── db_spec.lua         # Database tests with mocks
│   └── user_service_spec.lua
├── docs/
│   └── lua_lessons.md      # Comprehensive Lua tutorial
├── .busted                 # Test configuration
└── lua-learning-1.0-1.rockspec
```

## Running Tests

### Outside LazyVim (CLI)

```bash
# Run all tests (after environment setup)
busted

# Run specific test file
busted tests/db_spec.lua

# Run with coverage and view HTML report
./run.sh busted --coverage    # 1. Generate stats file
./run.sh luacov               # 2. Generate HTML report
# 3. Open luacov.report.html in your browser

# Alternative: Use helper script (sets paths automatically)
./run.sh busted
```

### Inside LazyVim with Neotest

1. Install neotest-busted plugin (see docs/lazyvim_setup.md)
2. Open any test file (`tests/*_spec.lua`)
3. Use keybindings:
   - `<leader>tt` - Run nearest test
   - `<leader>tf` - Run current file
   - `<leader>ta` - Run all tests
   - `<leader>ts` - Toggle test summary
   - `<leader>to` - Show test output

## Running the Application

```bash
# Run main app (after environment setup)
lua src/app.lua

# With custom database
lua src/app.lua users.db

# Alternative: Use helper script (sets paths automatically)
./run.sh lua src/app.lua
./run.sh lua src/app.lua users.db
```

## Learning Path

1. Read `docs/lua_lessons.md` - Covers syntax from basics to advanced
2. Explore `src/` files - See idiomatic Lua patterns
3. Study `tests/` files - Learn testing with mocks/fakes
4. Experiment and modify

## Key Lua Idioms

- **No classes**: Uses tables + metatables for OOP
- **No DI framework**: Uses closures and function injection
- **No monads**: Direct error handling with multiple returns
- **Modules**: Simple table-based module system
- **Metatables**: Lua's answer to operator overloading and prototypes
