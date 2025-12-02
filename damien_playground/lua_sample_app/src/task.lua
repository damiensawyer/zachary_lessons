--- Task module - Demonstrates OOP with metatables, closures, and data validation
-- @module task

local Task = {}
Task.__index = Task

--- Creates a new Task instance
-- Demonstrates: metatables, closures, default parameters
-- @param title string The task title
-- @param description string Optional task description
-- @param priority number Priority level (1-5), defaults to 3
-- @return table A new Task object
function Task.new(title, description, priority)
  -- Input validation
  if not title or type(title) ~= "string" or #title == 0 then
    error("Task title must be a non-empty string", 2)
  end

  priority = priority or 3
  if type(priority) ~= "number" or priority < 1 or priority > 5 then
    error("Priority must be a number between 1 and 5", 2)
  end

  -- Private state using closures
  local created_at = os.time()
  local completed_at = nil

  local self = setmetatable({}, Task)
  self.title = title
  self.description = description or ""
  self.priority = priority
  self.completed = false
  self.tags = {}

  -- Getter for created_at (demonstrates closures)
  function self:get_created_at()
    return created_at
  end

  -- Getter for completed_at
  function self:get_completed_at()
    return completed_at
  end

  -- Setter for completed_at (called internally)
  function self:set_completed_at(timestamp)
    completed_at = timestamp
  end

  return self
end

--- Mark task as complete
-- Demonstrates: state management, time handling
function Task:complete()
  if self.completed then
    return false, "Task is already completed"
  end
  self.completed = true
  self:set_completed_at(os.time())
  return true
end

--- Mark task as incomplete
function Task:uncomplete()
  if not self.completed then
    return false, "Task is not completed"
  end
  self.completed = false
  self:set_completed_at(nil)
  return true
end

--- Add a tag to the task
-- Demonstrates: table manipulation, set operations
-- @param tag string The tag to add
function Task:add_tag(tag)
  if type(tag) ~= "string" or #tag == 0 then
    error("Tag must be a non-empty string", 2)
  end

  -- Check if tag already exists
  for _, existing_tag in ipairs(self.tags) do
    if existing_tag == tag then
      return false, "Tag already exists"
    end
  end

  table.insert(self.tags, tag)
  return true
end

--- Remove a tag from the task
-- @param tag string The tag to remove
function Task:remove_tag(tag)
  for i, existing_tag in ipairs(self.tags) do
    if existing_tag == tag then
      table.remove(self.tags, i)
      return true
    end
  end
  return false, "Tag not found"
end

--- Check if task has a specific tag
-- @param tag string The tag to check
-- @return boolean True if tag exists
function Task:has_tag(tag)
  for _, existing_tag in ipairs(self.tags) do
    if existing_tag == tag then
      return true
    end
  end
  return false
end

--- Get age of task in seconds
-- Demonstrates: time calculations
-- @return number Age in seconds
function Task:get_age()
  return os.difftime(os.time(), self:get_created_at())
end

--- Convert task to string representation
-- Demonstrates: string formatting, metamethod
-- @return string Formatted task information
function Task:__tostring()
  local status = self.completed and "✓" or "○"
  local tags_str = #self.tags > 0 and (" [" .. table.concat(self.tags, ", ") .. "]") or ""
  return string.format("%s [P%d] %s%s", status, self.priority, self.title, tags_str)
end

--- Serialize task to table
-- Demonstrates: serialization pattern
-- @return table Task data as plain table
function Task:to_table()
  return {
    title = self.title,
    description = self.description,
    priority = self.priority,
    completed = self.completed,
    tags = vim.deepcopy and vim.deepcopy(self.tags) or self:_copy_table(self.tags),
    created_at = self:get_created_at(),
    completed_at = self:get_completed_at(),
  }
end

--- Helper to copy a table (for non-neovim environments)
-- @param t table Table to copy
-- @return table Copied table
function Task:_copy_table(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

return Task
