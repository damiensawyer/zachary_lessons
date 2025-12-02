-- Main application
-- Demonstrates: module composition, error handling, CLI interaction

local db = require("db")
local UserService = require("user_service")

local function main()
  -- Get database path from args or use default
  local db_path = arg[1] or "users.db"

  print(string.format("Opening database: %s", db_path))

  -- Open database connection
  local conn, err = db.open(db_path)
  if not conn then
    print("ERROR: " .. err)
    os.exit(1)
  end

  -- Create service with injected dependencies
  local service = UserService.new(db, conn)

  -- Initialize schema
  local ok, err = service:init_schema()
  if not ok then
    print("ERROR: Failed to initialize schema: " .. err)
    db.close(conn)
    os.exit(1)
  end

  print("Database initialized successfully")
  print()

  -- Create some users
  print("Creating users...")
  local alice, err = service:create("Alice Smith", "alice@example.com")
  if not alice then
    print("ERROR: " .. err)
  else
    print(string.format("Created user: %s (ID: %d)", alice.name, alice.id))
  end

  local bob, err = service:create("Bob Jones", "bob@example.com")
  if not bob then
    print("ERROR: " .. err)
  else
    print(string.format("Created user: %s (ID: %d)", bob.name, bob.id))
  end

  local charlie, err = service:create("Charlie Brown", "charlie@example.com")
  if not charlie then
    print("ERROR: " .. err)
  else
    print(string.format("Created user: %s (ID: %d)", charlie.name, charlie.id))
  end

  print()

  -- List all users
  print("All users:")
  local users, err = service:list()
  if not users then
    print("ERROR: " .. err)
  else
    for _, user in ipairs(users) do
      print(string.format("  [%d] %s <%s>", user.id, user.name, user.email))
    end
  end

  print()

  -- Find user by email
  print("Finding user by email: alice@example.com")
  local found, err = service:find_by_email("alice@example.com")
  if not found then
    print("  Not found" .. (err and (": " .. err) or ""))
  else
    print(string.format("  Found: %s (ID: %d)", found.name, found.id))
  end

  print()

  -- Update user
  if alice then
    print(string.format("Updating user %d...", alice.id))
    local updated, err = service:update(alice.id, "Alice Johnson", "alice.johnson@example.com")
    if not updated then
      print("ERROR: " .. err)
    else
      print(string.format("  Updated: %s <%s>", updated.name, updated.email))
    end
    print()
  end

  -- Count users
  local count, err = service:count()
  if not count then
    print("ERROR: " .. err)
  else
    print(string.format("Total users: %d", count))
  end

  print()

  -- Delete user
  if bob then
    print(string.format("Deleting user %d...", bob.id))
    local ok, err = service:delete(bob.id)
    if not ok then
      print("ERROR: " .. err)
    else
      print("  Deleted successfully")
    end
    print()
  end

  -- Final count
  count, err = service:count()
  if count then
    print(string.format("Remaining users: %d", count))
  end

  -- Cleanup
  db.close(conn)
  print()
  print("Done!")
end

-- Run with error handling
local ok, err = pcall(main)
if not ok then
  print("FATAL ERROR: " .. err)
  os.exit(1)
end
