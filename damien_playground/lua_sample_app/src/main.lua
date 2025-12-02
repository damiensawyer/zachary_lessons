#!/usr/bin/env lua

--- Main application - Task Manager CLI
-- Demonstrates: application structure, I/O, control flow
-- @script main

local Task = require("src.task")
local TaskManager = require("src.task_manager")
local utils = require("src.utils")

-- ANSI color codes for terminal output
local colors = {
  reset = "\27[0m",
  red = "\27[31m",
  green = "\27[32m",
  yellow = "\27[33m",
  blue = "\27[34m",
  magenta = "\27[35m",
  cyan = "\27[36m",
  white = "\27[37m",
}

--- Print colored output
-- @param color string Color name
-- @param text string Text to print
local function print_colored(color, text)
  print(colors[color] .. text .. colors.reset)
end

--- Display a task with formatting
-- @param id number Task ID
-- @param task Task Task object
local function display_task(id, task)
  local priority_colors = {
    [1] = "blue",
    [2] = "cyan",
    [3] = "white",
    [4] = "yellow",
    [5] = "red",
  }

  local status_icon = task.completed and "✓" or "○"
  local color = priority_colors[task.priority]

  local tags_str = ""
  if #task.tags > 0 then
    tags_str = " [" .. table.concat(task.tags, ", ") .. "]"
  end

  print_colored(color, string.format("  %d. %s [P%d] %s%s",
    id, status_icon, task.priority, task.title, tags_str))

  if task.description and #task.description > 0 then
    print("      " .. task.description)
  end
end

--- Display help menu
local function show_help()
  print_colored("cyan", "\n=== Task Manager - Command Reference ===\n")
  print("  help          - Show this help menu")
  print("  add           - Add a new task")
  print("  list          - List all tasks")
  print("  complete <id> - Mark task as complete")
  print("  remove <id>   - Remove a task")
  print("  tag <id> <tag>- Add a tag to a task")
  print("  filter <tag>  - Filter tasks by tag")
  print("  stats         - Show task statistics")
  print("  demo          - Run a demonstration")
  print("  exit          - Exit the application")
  print()
end

--- Run interactive demo
-- Demonstrates: comprehensive feature showcase
-- @param manager TaskManager Task manager instance
local function run_demo(manager)
  print_colored("magenta", "\n=== Running Demo ===\n")

  -- Clear existing tasks
  manager:clear()

  -- Create sample tasks
  print("Creating sample tasks...")

  local task1 = Task.new("Learn Lua basics", "Study tables, functions, and metatables", 5)
  task1:add_tag("learning")
  task1:add_tag("lua")
  local id1 = manager:add_task(task1)

  local task2 = Task.new("Setup LazyVim", "Install and configure LazyVim with neotest", 4)
  task2:add_tag("vim")
  task2:add_tag("setup")
  local id2 = manager:add_task(task2)

  local task3 = Task.new("Write unit tests", "Create comprehensive tests with busted", 5)
  task3:add_tag("testing")
  task3:add_tag("lua")
  local id3 = manager:add_task(task3)

  local task4 = Task.new("Read documentation", "Study Lua 5.4 reference manual", 2)
  task4:add_tag("learning")
  manager:add_task(task4)

  local task5 = Task.new("Practice coroutines", "Implement generators and async patterns", 3)
  task5:add_tag("learning")
  task5:add_tag("lua")
  task5:add_tag("advanced")
  manager:add_task(task5)

  print_colored("green", string.format("Created %d tasks\n", manager:count()))

  -- Complete some tasks
  print("Completing some tasks...")
  manager:get_task(id1):complete()
  manager:get_task(id3):complete()
  print_colored("green", string.format("Completed %d tasks\n", manager:count_completed()))

  -- Demonstrate filtering
  print_colored("yellow", "Tasks tagged with 'lua':")
  local lua_tasks = manager:get_by_tag("lua")
  for _, entry in ipairs(lua_tasks) do
    display_task(entry.id, entry.task)
  end
  print()

  -- Demonstrate sorting
  print_colored("yellow", "Tasks sorted by priority:")
  local sorted = manager:sort_by_priority()
  for _, entry in ipairs(sorted) do
    display_task(entry.id, entry.task)
  end
  print()

  -- Demonstrate utility functions
  print_colored("yellow", "Demonstrating utility functions:\n")

  print("Range iterator (1 to 5):")
  local range_result = {}
  for i in utils.range(1, 5) do
    table.insert(range_result, i)
  end
  print("  " .. table.concat(range_result, ", "))

  print("\nChunking array [1,2,3,4,5,6,7] into chunks of 3:")
  local chunks = utils.chunk({1, 2, 3, 4, 5, 6, 7}, 3)
  for i, chunk in ipairs(chunks) do
    print(string.format("  Chunk %d: [%s]", i, table.concat(chunk, ", ")))
  end

  print("\nZipping arrays [1,2,3] and ['a','b','c']:")
  local zipped = utils.zip({1, 2, 3}, {"a", "b", "c"})
  for _, tuple in ipairs(zipped) do
    print(string.format("  (%s, %s)", tuple[1], tuple[2]))
  end

  print()
end

--- Display task statistics
-- @param manager TaskManager Task manager instance
local function show_stats(manager)
  local stats = manager:get_stats()

  print_colored("cyan", "\n=== Task Statistics ===\n")
  print(string.format("  Total tasks: %d", stats.total))
  print(string.format("  Completed: %d", stats.completed))
  print(string.format("  Incomplete: %d", stats.incomplete))

  if stats.total > 0 then
    local completion_rate = (stats.completed / stats.total) * 100
    print(string.format("  Completion rate: %.1f%%", completion_rate))
  end

  print("\n  Priority distribution:")
  for priority = 5, 1, -1 do
    local count = stats.by_priority[priority]
    if count > 0 then
      print(string.format("    P%d: %d", priority, count))
    end
  end

  if next(stats.tags) then
    print("\n  Tag usage:")
    local sorted_tags = {}
    for tag, count in pairs(stats.tags) do
      table.insert(sorted_tags, {tag = tag, count = count})
    end
    table.sort(sorted_tags, function(a, b) return a.count > b.count end)

    for _, entry in ipairs(sorted_tags) do
      print(string.format("    %s: %d", entry.tag, entry.count))
    end
  end

  print()
end

--- Main application loop
local function main()
  local manager = TaskManager.new()

  print_colored("green", [[
╔════════════════════════════════════════╗
║    Lua Task Manager Demo Application  ║
║   Showcasing Lua Language Features    ║
╚════════════════════════════════════════╝
]])

  print("Type 'help' for available commands or 'demo' to run a demonstration\n")

  -- Main loop
  while true do
    io.write(colors.green .. "task> " .. colors.reset)
    local input = io.read()

    if not input then
      break
    end

    local parts = utils.string.split(utils.string.trim(input), "%s+")
    local command = parts[1]

    if command == "exit" or command == "quit" then
      print_colored("yellow", "Goodbye!")
      break
    elseif command == "help" then
      show_help()
    elseif command == "demo" then
      run_demo(manager)
    elseif command == "list" then
      if manager:count() == 0 then
        print_colored("yellow", "No tasks found. Use 'add' to create a task or 'demo' to run demonstration.")
      else
        print_colored("cyan", "\n=== All Tasks ===\n")
        for id, task in manager:iter() do
          display_task(id, task)
        end
        print()
      end
    elseif command == "stats" then
      show_stats(manager)
    elseif command == "add" then
      io.write("Task title: ")
      local title = io.read()
      io.write("Description (optional): ")
      local description = io.read()
      io.write("Priority (1-5, default 3): ")
      local priority_str = io.read()
      local priority = tonumber(priority_str) or 3

      local ok, task_or_err = pcall(Task.new, title, description, priority)
      if ok then
        local id = manager:add_task(task_or_err)
        print_colored("green", string.format("Task #%d created successfully!", id))
      else
        print_colored("red", "Error: " .. tostring(task_or_err))
      end
    elseif command == "complete" then
      local id = tonumber(parts[2])
      if not id then
        print_colored("red", "Usage: complete <task_id>")
      else
        local task = manager:get_task(id)
        if task then
          task:complete()
          print_colored("green", "Task marked as complete!")
        else
          print_colored("red", "Task not found")
        end
      end
    elseif command == "remove" then
      local id = tonumber(parts[2])
      if not id then
        print_colored("red", "Usage: remove <task_id>")
      else
        if manager:remove_task(id) then
          print_colored("green", "Task removed!")
        else
          print_colored("red", "Task not found")
        end
      end
    elseif command == "tag" then
      local id = tonumber(parts[2])
      local tag = parts[3]
      if not id or not tag then
        print_colored("red", "Usage: tag <task_id> <tag_name>")
      else
        local task = manager:get_task(id)
        if task then
          task:add_tag(tag)
          print_colored("green", "Tag added!")
        else
          print_colored("red", "Task not found")
        end
      end
    elseif command == "filter" then
      local tag = parts[2]
      if not tag then
        print_colored("red", "Usage: filter <tag_name>")
      else
        local filtered = manager:get_by_tag(tag)
        if #filtered == 0 then
          print_colored("yellow", string.format("No tasks found with tag '%s'", tag))
        else
          print_colored("cyan", string.format("\n=== Tasks tagged with '%s' ===\n", tag))
          for _, entry in ipairs(filtered) do
            display_task(entry.id, entry.task)
          end
          print()
        end
      end
    elseif command and #command > 0 then
      print_colored("red", string.format("Unknown command: %s (type 'help' for available commands)", command))
    end
  end
end

-- Run main if executed directly
if not pcall(debug.getlocal, 4, 1) then
  main()
end

return {
  main = main,
  run_demo = run_demo,
  show_stats = show_stats,
}
