-- User service - business logic layer
-- Demonstrates: DI via closures, clean separation of concerns

local M = {}
M.__index = M

-- Constructor with dependency injection
function M.new(db_module, db_conn)
  local self = setmetatable({}, M)
  self.db = db_module
  self.conn = db_conn
  return self
end

-- Initialize schema
function M:init_schema()
  local sql = [[
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s', 'now'))
    )
  ]]

  return self.db.exec(self.conn, sql)
end

-- Create user
function M:create(name, email)
  if not name or name == "" then
    return nil, "name required"
  end

  if not email or email == "" then
    return nil, "email required"
  end

  local sql = "INSERT INTO users (name, email) VALUES (?, ?)"
  local id, err = self.db.insert(self.conn, sql, {name, email})

  if not id then
    return nil, err
  end

  return self:get(id)
end

-- Get user by ID
function M:get(id)
  local sql = "SELECT * FROM users WHERE id = ?"
  return self.db.query_one(self.conn, sql, {id})
end

-- Find user by email
function M:find_by_email(email)
  local sql = "SELECT * FROM users WHERE email = ?"
  return self.db.query_one(self.conn, sql, {email})
end

-- List all users
function M:list()
  local sql = "SELECT * FROM users ORDER BY created_at DESC"
  return self.db.query_all(self.conn, sql)
end

-- Update user
function M:update(id, name, email)
  if not name or name == "" then
    return nil, "name required"
  end

  if not email or email == "" then
    return nil, "email required"
  end

  local sql = "UPDATE users SET name = ?, email = ? WHERE id = ?"
  local ok, err = self.db.exec(self.conn, sql, {name, email, id})

  if not ok then
    return nil, err
  end

  return self:get(id)
end

-- Delete user
function M:delete(id)
  local sql = "DELETE FROM users WHERE id = ?"
  return self.db.exec(self.conn, sql, {id})
end

-- Count users
function M:count()
  local sql = "SELECT COUNT(*) as count FROM users"
  local row, err = self.db.query_one(self.conn, sql)

  if not row then
    return nil, err
  end

  return row.count
end

return M
