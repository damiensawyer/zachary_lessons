# LazyVim + Neotest Setup for Lua

## Prerequisites

```bash
# Ensure Neovim 0.9+ is installed
nvim --version

# Install LazyVim if not already installed
# https://www.lazyvim.org/installation
```

## Install Neotest for Lua/Busted

Add to your LazyVim config: `~/.config/nvim/lua/plugins/neotest.lua`

```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Busted adapter for Lua testing
      "nvim-neotest/neotest-plenary",
    },
    opts = {
      adapters = {
        ["neotest-plenary"] = {
          -- Use busted as the test command
          min_init = "./tests/minimal_init.lua",
        },
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
      quickfix = {
        open = function()
          vim.cmd("Trouble quickfix")
        end,
      },
    },
    config = function(_, opts)
      local neotest = require("neotest")
      neotest.setup(opts)
    end,
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file" },
      { "<leader>ta", function() require("neotest").run.run(vim.fn.getcwd()) end, desc = "Run all tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Show output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
      { "<leader>tw", function() require("neotest").watch.toggle() end, desc = "Toggle watch" },
    },
  },
}
```

## Alternative: Using Busted Directly

If `neotest-plenary` doesn't work, install `neotest-busted`:

```lua
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Direct busted adapter
    {
      "MisanthropicBit/neotest-busted",
      rocks = { "busted" },  -- Auto-install busted via luarocks
    },
  },
  opts = {
    adapters = {
      ["neotest-busted"] = {},
    },
  },
}
```

## Keybindings Reference

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test (cursor position) |
| `<leader>tf` | Run all tests in current file |
| `<leader>ta` | Run all tests in project |
| `<leader>ts` | Toggle test summary window |
| `<leader>to` | Open output of last test |
| `<leader>tO` | Toggle output panel |
| `<leader>tS` | Stop running tests |
| `<leader>tw` | Toggle watch mode (auto-run on save) |

## Usage Workflow

1. **Open a test file**: `nvim tests/db_spec.lua`

2. **Run single test**:
   - Place cursor inside a test
   - Press `<leader>tt`
   - See results inline with virtual text

3. **Run all tests in file**:
   - Press `<leader>tf`
   - View summary with `<leader>ts`

4. **Run all tests**:
   - Press `<leader>ta`
   - Check output panel with `<leader>tO`

5. **Watch mode** (auto-run on save):
   - Press `<leader>tw`
   - Edit and save file
   - Tests run automatically

## Debugging Failed Tests

```lua
-- Add debug keybinding to your config
{
  "<leader>td",
  function()
    require("neotest").run.run({ strategy = "dap" })
  end,
  desc = "Debug nearest test"
}
```

Requires `nvim-dap` for debugging support.

## Treesitter Setup

Ensure Lua parser is installed:

```vim
:TSInstall lua
```

Or add to config:

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "lua" },
  },
}
```

## Troubleshooting

### Tests not discovered

1. Check `.busted` config exists in project root
2. Verify test files match pattern `*_spec.lua`
3. Ensure busted is installed: `luarocks list | grep busted`

### "Adapter not found"

1. Restart Neovim after installing plugins
2. Run `:Lazy sync` to update plugins
3. Check adapter is in `opts.adapters` table

### Tests fail with "module not found"

1. Check `.busted` has correct `lpath`
2. Run tests from project root
3. Verify `package.path` includes `src/` directory

### Performance issues

1. Disable virtual text: `status = { virtual_text = false }`
2. Use file-level tests instead of running all
3. Disable watch mode when not needed

## Running Tests Outside Neovim

Always verify tests work on CLI first:

```bash
# From project root
busted

# Single file
busted tests/db_spec.lua

# With coverage
busted --coverage
```

## Advanced: Custom Test Commands

```lua
-- Add to your neotest config
opts = {
  adapters = {
    ["neotest-busted"] = {
      busted_command = "busted",
      busted_args = { "--verbose" },
      busted_paths = { "tests/" },
      busted_cpaths = { "/usr/local/lib/lua/5.4/?.so" },
    },
  },
}
```

## Integration with Other Tools

### With Coverage (luacov)

```bash
# Run with coverage
busted --coverage

# View in Neovim (requires coverage.nvim)
:Coverage
```

### With Linter (luacheck)

```lua
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      lua = { "luacheck" },
    },
  },
}
```

### With Formatter (stylua)

```lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
}
```

## Example Session

```vim
" 1. Open test file
:e tests/db_spec.lua

" 2. Run nearest test
<leader>tt

" 3. See results inline (green ✓ or red ✗)

" 4. View summary
<leader>ts

" 5. Check detailed output
<leader>to

" 6. Run all file tests
<leader>tf

" 7. Enable watch mode
<leader>tw

" 8. Edit code, save - tests auto-run
:e src/db.lua
<make changes>
:w
```

## Resources

- [Neotest docs](https://github.com/nvim-neotest/neotest)
- [Busted docs](https://lunarmodules.github.io/busted/)
- [LazyVim extras](https://www.lazyvim.org/extras)
