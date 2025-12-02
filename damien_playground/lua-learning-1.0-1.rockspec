package = "lua-learning"
version = "1.0-1"

source = {
  url = "."
}

description = {
  summary = "Lua learning project with SQLite and tests",
  detailed = [[
    Comprehensive Lua learning project demonstrating:
    - Module system and package management
    - SQLite database integration
    - Unit testing with busted
    - Idiomatic Lua patterns
  ]],
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lsqlite3 >= 0.9",
  "busted >= 2.0"
}

build = {
  type = "builtin",
  modules = {
    db = "src/db.lua",
    user_service = "src/user_service.lua",
    app = "src/app.lua"
  }
}
