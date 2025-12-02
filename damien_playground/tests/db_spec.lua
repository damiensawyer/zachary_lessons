-- Database module tests
-- Demonstrates: testing with real SQLite (small), mocking for complex scenarios

local db = require("db")

describe("db module", function()
  local conn

  -- Setup: create in-memory database before each test
  before_each(function()
    conn = db.open(":memory:")
    assert.is_not_nil(conn)
  end)

  -- Teardown: close connection after each test
  after_each(function()
    if conn then
      db.close(conn)
    end
  end)

  describe("open", function()
    it("opens in-memory database", function()
      local test_conn = db.open(":memory:")
      assert.is_not_nil(test_conn)
      db.close(test_conn)
    end)

    it("opens file database", function()
      local test_conn = db.open("/tmp/test_db.sqlite")
      assert.is_not_nil(test_conn)
      db.close(test_conn)
      os.remove("/tmp/test_db.sqlite")
    end)

    it("returns error for invalid path", function()
      local test_conn, err = db.open("/invalid/path/db.sqlite")
      assert.is_nil(test_conn)
      assert.is_not_nil(err)
      assert.matches("Failed to open database", err)
    end)
  end)

  describe("exec", function()
    it("executes CREATE TABLE statement", function()
      local sql = "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)"
      local ok, err = db.exec(conn, sql)
      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("executes INSERT with parameters", function()
      db.exec(conn, "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      local ok, err = db.exec(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
      assert.is_true(ok)
      assert.is_nil(err)
    end)

    it("returns error for invalid SQL", function()
      local ok, err = db.exec(conn, "INVALID SQL")
      assert.is_nil(ok)
      assert.is_not_nil(err)
    end)

    it("returns error for nil database", function()
      local ok, err = db.exec(nil, "SELECT 1")
      assert.is_nil(ok)
      assert.equals("nil database", err)
    end)
  end)

  describe("query_one", function()
    before_each(function()
      db.exec(conn, "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      db.exec(conn, "INSERT INTO test (name) VALUES ('Alice')")
      db.exec(conn, "INSERT INTO test (name) VALUES ('Bob')")
    end)

    it("returns single row", function()
      local row, err = db.query_one(conn, "SELECT * FROM test WHERE name = ?", {"Alice"})
      assert.is_not_nil(row)
      assert.is_nil(err)
      assert.equals("Alice", row.name)
      assert.equals(1, row.id)
    end)

    it("returns nil when no row found", function()
      local row, err = db.query_one(conn, "SELECT * FROM test WHERE name = ?", {"Charlie"})
      assert.is_nil(row)
      assert.is_nil(err)  -- No error, just no result
    end)

    it("returns error for invalid SQL", function()
      local row, err = db.query_one(conn, "SELECT * FROM nonexistent")
      assert.is_nil(row)
      assert.is_not_nil(err)
    end)
  end)

  describe("query_all", function()
    before_each(function()
      db.exec(conn, "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
      db.exec(conn, "INSERT INTO test (name) VALUES ('Alice')")
      db.exec(conn, "INSERT INTO test (name) VALUES ('Bob')")
      db.exec(conn, "INSERT INTO test (name) VALUES ('Charlie')")
    end)

    it("returns all rows", function()
      local rows, err = db.query_all(conn, "SELECT * FROM test")
      assert.is_table(rows)
      assert.is_nil(err)
      assert.equals(3, #rows)
    end)

    it("returns filtered rows", function()
      local rows, err = db.query_all(conn, "SELECT * FROM test WHERE id > ?", {1})
      assert.is_table(rows)
      assert.equals(2, #rows)
    end)

    it("returns empty table when no rows", function()
      local rows, err = db.query_all(conn, "SELECT * FROM test WHERE id > 100")
      assert.is_table(rows)
      assert.is_nil(err)
      assert.equals(0, #rows)
    end)
  end)

  describe("insert", function()
    before_each(function()
      db.exec(conn, "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
    end)

    it("inserts row and returns ID", function()
      local id, err = db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
      assert.is_number(id)
      assert.is_nil(err)
      assert.equals(1, id)
    end)

    it("returns incremented IDs", function()
      local id1 = db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
      local id2 = db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Bob"})
      assert.equals(1, id1)
      assert.equals(2, id2)
    end)

    it("returns error for constraint violation", function()
      db.exec(conn, "CREATE UNIQUE INDEX idx_name ON test(name)")
      db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
      local id, err = db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
      assert.is_nil(id)
      assert.is_not_nil(err)
    end)
  end)

  describe("transaction", function()
    before_each(function()
      db.exec(conn, "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
    end)

    it("commits successful transaction", function()
      local result, err = db.transaction(conn, function()
        db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
        db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Bob"})
        return true
      end)

      assert.is_true(result)
      assert.is_nil(err)

      local rows = db.query_all(conn, "SELECT * FROM test")
      assert.equals(2, #rows)
    end)

    it("rolls back failed transaction", function()
      local result, err = db.transaction(conn, function()
        db.insert(conn, "INSERT INTO test (name) VALUES (?)", {"Alice"})
        return nil, "intentional error"
      end)

      assert.is_nil(result)
      assert.equals("intentional error", err)

      local rows = db.query_all(conn, "SELECT * FROM test")
      assert.equals(0, #rows)  -- Should be rolled back
    end)
  end)
end)
