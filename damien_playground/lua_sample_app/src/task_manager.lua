--- TaskManager module - Demonstrates collections, iterators, and functional patterns
-- @module task_manager

local Task = require("src.task")

local TaskManager = {}
TaskManager.__index = TaskManager

--- Creates a new TaskManager instance
-- Demonstrates: constructor pattern
-- @return table A new TaskManager object
function TaskManager.new()
  local self = setmetatable({}, TaskManager)
  self.tasks = {}
  self.next_id = 1
  return self
end

--- Add a task to the manager
-- Demonstrates: auto-incrementing IDs, table insertion
-- @param task Task The task to add
-- @return number The assigned task ID
function TaskManager:add_task(task)
  if not task then
    error("Task cannot be nil", 2)
  end

  local id = self.next_id
  self.tasks[id] = task
  self.next_id = self.next_id + 1
  return id
end

--- Get a task by ID
-- @param id number The task ID
-- @return Task|nil The task or nil if not found
function TaskManager:get_task(id)
  return self.tasks[id]
end

--- Remove a task by ID
-- @param id number The task ID
-- @return boolean True if task was removed
function TaskManager:remove_task(id)
  if self.tasks[id] then
    self.tasks[id] = nil
    return true
  end
  return false
end

--- Get total number of tasks
-- @return number Count of tasks
function TaskManager:count()
  local count = 0
  for _ in pairs(self.tasks) do
    count = count + 1
  end
  return count
end

--- Get count of completed tasks
-- Demonstrates: filtering, counting
-- @return number Count of completed tasks
function TaskManager:count_completed()
  local count = 0
  for _, task in pairs(self.tasks) do
    if task.completed then
      count = count + 1
    end
  end
  return count
end

--- Filter tasks by predicate
-- Demonstrates: higher-order functions, functional programming
-- @param predicate function Function that takes a task and returns boolean
-- @return table Array of tasks that match predicate
function TaskManager:filter(predicate)
  local results = {}
  for id, task in pairs(self.tasks) do
    if predicate(task, id) then
      table.insert(results, {id = id, task = task})
    end
  end
  return results
end

--- Get tasks by tag
-- @param tag string The tag to filter by
-- @return table Array of tasks with the tag
function TaskManager:get_by_tag(tag)
  return self:filter(function(task)
    return task:has_tag(tag)
  end)
end

--- Get tasks by priority
-- @param priority number The priority level
-- @return table Array of tasks with the priority
function TaskManager:get_by_priority(priority)
  return self:filter(function(task)
    return task.priority == priority
  end)
end

--- Get completed tasks
-- @return table Array of completed tasks
function TaskManager:get_completed()
  return self:filter(function(task)
    return task.completed
  end)
end

--- Get incomplete tasks
-- @return table Array of incomplete tasks
function TaskManager:get_incomplete()
  return self:filter(function(task)
    return not task.completed
  end)
end

--- Sort tasks by comparator
-- Demonstrates: custom sorting, comparator functions
-- @param comparator function Function that compares two tasks
-- @return table Array of sorted task entries
function TaskManager:sort(comparator)
  local task_array = {}
  for id, task in pairs(self.tasks) do
    table.insert(task_array, {id = id, task = task})
  end

  table.sort(task_array, function(a, b)
    return comparator(a.task, b.task)
  end)

  return task_array
end

--- Sort tasks by priority (high to low)
-- @return table Array of tasks sorted by priority
function TaskManager:sort_by_priority()
  return self:sort(function(a, b)
    return a.priority > b.priority
  end)
end

--- Sort tasks by age (newest first)
-- @return table Array of tasks sorted by age
function TaskManager:sort_by_age()
  return self:sort(function(a, b)
    return a:get_created_at() > b:get_created_at()
  end)
end

--- Iterator over all tasks
-- Demonstrates: iterator pattern, stateless iterators
-- @return function Iterator function
function TaskManager:iter()
  return pairs(self.tasks)
end

--- Map function over all tasks
-- Demonstrates: map pattern, functional programming
-- @param mapper function Function that transforms each task
-- @return table Array of mapped results
function TaskManager:map(mapper)
  local results = {}
  for id, task in pairs(self.tasks) do
    table.insert(results, mapper(task, id))
  end
  return results
end

--- Reduce tasks to a single value
-- Demonstrates: reduce/fold pattern
-- @param reducer function Function(accumulator, task, id) -> new_accumulator
-- @param initial any Initial accumulator value
-- @return any Final accumulator value
function TaskManager:reduce(reducer, initial)
  local accumulator = initial
  for id, task in pairs(self.tasks) do
    accumulator = reducer(accumulator, task, id)
  end
  return accumulator
end

--- Calculate total priority score
-- Demonstrates: practical use of reduce
-- @return number Sum of all task priorities
function TaskManager:total_priority()
  return self:reduce(function(sum, task)
    return sum + task.priority
  end, 0)
end

--- Get statistics about tasks
-- Demonstrates: complex data aggregation
-- @return table Statistics object
function TaskManager:get_stats()
  local stats = {
    total = 0,
    completed = 0,
    incomplete = 0,
    by_priority = {0, 0, 0, 0, 0},
    tags = {},
  }

  for _, task in pairs(self.tasks) do
    stats.total = stats.total + 1

    if task.completed then
      stats.completed = stats.completed + 1
    else
      stats.incomplete = stats.incomplete + 1
    end

    stats.by_priority[task.priority] = stats.by_priority[task.priority] + 1

    for _, tag in ipairs(task.tags) do
      stats.tags[tag] = (stats.tags[tag] or 0) + 1
    end
  end

  return stats
end

--- Clear all tasks
function TaskManager:clear()
  self.tasks = {}
  self.next_id = 1
end

return TaskManager
