-- User service tests
-- Demonstrates: mocking, fakes, dependency injection for testing

local UserService = require("user_service")

describe("UserService", function()
  local service, mock_db, mock_conn

  -- Create a fake database module for testing
  local function create_fake_db()
    local data = {}
    local next_id = 1

    return {
      exec = function(conn, sql, params)
        return true  -- Assume success for schema init
      end,

      insert = function(conn, sql, params)
        local id = next_id
        next_id = next_id + 1

        data[id] = {
          id = id,
          name = params[1],
          email = params[2],
          created_at = os.time()
        }

        return id
      end,

      query_one = function(conn, sql, params)
        if sql:match("WHERE id = %?") then
          return data[params[1]]
        elseif sql:match("WHERE email = %?") then
          for _, row in pairs(data) do
            if row.email == params[1] then
              return row
            end
          end
          return nil
        elseif sql:match("COUNT") then
          local count = 0
          for _ in pairs(data) do count = count + 1 end
          return {count = count}
        end
        return nil
      end,

      query_all = function(conn, sql, params)
        local results = {}
        for _, row in pairs(data) do
          table.insert(results, row)
        end
        return results
      end,

      -- Spy functions to track calls
      _get_data = function() return data end,
      _reset = function()
        data = {}
        next_id = 1
      end
    }
  end

  before_each(function()
    mock_db = create_fake_db()
    mock_conn = {}  -- Fake connection object
    service = UserService.new(mock_db, mock_conn)
  end)

  describe("init_schema", function()
    it("executes schema creation", function()
      local ok, err = service:init_schema()
      assert.is_true(ok)
      assert.is_nil(err)
    end)
  end)

  describe("create", function()
    it("creates user with valid data", function()
      local user, err = service:create("Alice", "alice@example.com")
      assert.is_table(user)
      assert.is_nil(err)
      assert.equals("Alice", user.name)
      assert.equals("alice@example.com", user.email)
      assert.is_number(user.id)
    end)

    it("returns error when name is empty", function()
      local user, err = service:create("", "alice@example.com")
      assert.is_nil(user)
      assert.equals("name required", err)
    end)

    it("returns error when name is nil", function()
      local user, err = service:create(nil, "alice@example.com")
      assert.is_nil(user)
      assert.equals("name required", err)
    end)

    it("returns error when email is empty", function()
      local user, err = service:create("Alice", "")
      assert.is_nil(user)
      assert.equals("email required", err)
    end)

    it("returns error when email is nil", function()
      local user, err = service:create("Alice", nil)
      assert.is_nil(user)
      assert.equals("email required", err)
    end)

    it("assigns unique IDs to users", function()
      local user1 = service:create("Alice", "alice@example.com")
      local user2 = service:create("Bob", "bob@example.com")
      assert.is_not_equals(user1.id, user2.id)
    end)
  end)

  describe("get", function()
    it("returns user by ID", function()
      local created = service:create("Alice", "alice@example.com")
      local user = service:get(created.id)
      assert.is_table(user)
      assert.equals(created.id, user.id)
      assert.equals("Alice", user.name)
    end)

    it("returns nil for nonexistent ID", function()
      local user = service:get(999)
      assert.is_nil(user)
    end)
  end)

  describe("find_by_email", function()
    it("finds user by email", function()
      service:create("Alice", "alice@example.com")
      local user = service:find_by_email("alice@example.com")
      assert.is_table(user)
      assert.equals("Alice", user.name)
      assert.equals("alice@example.com", user.email)
    end)

    it("returns nil for nonexistent email", function()
      local user = service:find_by_email("nobody@example.com")
      assert.is_nil(user)
    end)
  end)

  describe("list", function()
    it("returns empty list when no users", function()
      local users = service:list()
      assert.is_table(users)
      assert.equals(0, #users)
    end)

    it("returns all users", function()
      service:create("Alice", "alice@example.com")
      service:create("Bob", "bob@example.com")
      service:create("Charlie", "charlie@example.com")

      local users = service:list()
      assert.is_table(users)
      assert.equals(3, #users)
    end)
  end)

  describe("count", function()
    it("returns zero when no users", function()
      local count = service:count()
      assert.equals(0, count)
    end)

    it("returns correct count", function()
      service:create("Alice", "alice@example.com")
      service:create("Bob", "bob@example.com")

      local count = service:count()
      assert.equals(2, count)
    end)
  end)

  describe("update", function()
    it("updates user with valid data", function()
      local created = service:create("Alice", "alice@example.com")

      -- Mock the update behavior
      mock_db.exec = function(conn, sql, params)
        local id = params[3]
        local data = mock_db._get_data()
        if data[id] then
          data[id].name = params[1]
          data[id].email = params[2]
        end
        return true
      end

      local updated, err = service:update(created.id, "Alice Smith", "alice.smith@example.com")
      assert.is_table(updated)
      assert.is_nil(err)
      assert.equals("Alice Smith", updated.name)
      assert.equals("alice.smith@example.com", updated.email)
    end)

    it("returns error when name is empty", function()
      local created = service:create("Alice", "alice@example.com")
      local updated, err = service:update(created.id, "", "alice@example.com")
      assert.is_nil(updated)
      assert.equals("name required", err)
    end)

    it("returns error when email is empty", function()
      local created = service:create("Alice", "alice@example.com")
      local updated, err = service:update(created.id, "Alice", "")
      assert.is_nil(updated)
      assert.equals("email required", err)
    end)
  end)

  describe("delete", function()
    it("deletes existing user", function()
      local created = service:create("Alice", "alice@example.com")

      -- Mock the delete behavior
      mock_db.exec = function(conn, sql, params)
        local id = params[1]
        local data = mock_db._get_data()
        data[id] = nil
        return true
      end

      local ok, err = service:delete(created.id)
      assert.is_true(ok)
      assert.is_nil(err)
    end)
  end)

  -- Integration-style test using real db module (demonstrates both approaches)
  describe("integration with real database", function()
    local real_db = require("db")
    local real_conn, real_service

    before_each(function()
      real_conn = real_db.open(":memory:")
      real_service = UserService.new(real_db, real_conn)
      real_service:init_schema()
    end)

    after_each(function()
      if real_conn then
        real_db.close(real_conn)
      end
    end)

    it("performs full CRUD operations", function()
      -- Create
      local user = real_service:create("Alice", "alice@example.com")
      assert.is_table(user)
      assert.equals(1, user.id)

      -- Read
      local found = real_service:get(user.id)
      assert.equals("Alice", found.name)

      -- Update
      mock_db.exec = function(conn, sql, params)
        return real_db.exec(conn, sql, params)
      end
      local updated = real_service:update(user.id, "Alice Smith", "alice.smith@example.com")
      assert.equals("Alice Smith", updated.name)

      -- Delete
      local ok = real_service:delete(user.id)
      assert.is_true(ok)

      -- Verify deletion
      local deleted = real_service:get(user.id)
      assert.is_nil(deleted)
    end)
  end)
end)
