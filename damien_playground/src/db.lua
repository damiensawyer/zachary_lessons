-- SQLite database module
-- Demonstrates: module pattern, error handling, prepared statements

local sqlite3 = require("lsqlite3")

local M = {}

-- Open database connection
function M.open(path)
  path = path or ":memory:"
  local db, err_code, err_msg = sqlite3.open(path)

  if not db then
    return nil, string.format("Failed to open database: %s (code %d)", err_msg, err_code)
  end

  return db
end

-- Execute SQL with no results expected
function M.exec(db, sql, params)
  if not db then return nil, "nil database" end

  local stmt = db:prepare(sql)
  if not stmt then
    return nil, db:errmsg()
  end

  if params then
    stmt:bind_values(table.unpack(params))
  end

  local result = stmt:step()
  stmt:finalize()

  if result == sqlite3.DONE or result == sqlite3.OK then
    return true
  else
    return nil, db:errmsg()
  end
end

-- Query single row
function M.query_one(db, sql, params)
  if not db then return nil, "nil database" end

  local stmt = db:prepare(sql)
  if not stmt then
    return nil, db:errmsg()
  end

  if params then
    stmt:bind_values(table.unpack(params))
  end

  local result = stmt:step()

  if result == sqlite3.ROW then
    local row = stmt:get_named_values()
    stmt:finalize()
    return row
  elseif result == sqlite3.DONE then
    stmt:finalize()
    return nil  -- No error, just no row found
  else
    local err = db:errmsg()
    stmt:finalize()
    return nil, err
  end
end

-- Query multiple rows
function M.query_all(db, sql, params)
  if not db then return nil, "nil database" end

  local stmt = db:prepare(sql)
  if not stmt then
    return nil, db:errmsg()
  end

  if params then
    stmt:bind_values(table.unpack(params))
  end

  local rows = {}
  for row in stmt:nrows() do
    table.insert(rows, row)
  end

  stmt:finalize()
  return rows
end

-- Insert and return last inserted ID
function M.insert(db, sql, params)
  local ok, err = M.exec(db, sql, params)
  if not ok then
    return nil, err
  end

  return db:last_insert_rowid()
end

-- Transaction helper
function M.transaction(db, fn)
  local ok, err = M.exec(db, "BEGIN TRANSACTION")
  if not ok then return nil, err end

  local result, fn_err = fn()

  if not result then
    M.exec(db, "ROLLBACK")
    return nil, fn_err or "transaction failed"
  end

  ok, err = M.exec(db, "COMMIT")
  if not ok then
    M.exec(db, "ROLLBACK")
    return nil, err
  end

  return result
end

-- Close database
function M.close(db)
  if db then
    db:close()
  end
end

return M
