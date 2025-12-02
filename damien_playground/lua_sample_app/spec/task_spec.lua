--- Unit tests for Task module
-- Demonstrates: busted test syntax, assertions, error handling tests

local Task = require("src.task")

describe("Task", function()
  describe("constructor", function()
    it("should create a new task with required parameters", function()
      local task = Task.new("Test Task")

      assert.equals("Test Task", task.title)
      assert.equals("", task.description)
      assert.equals(3, task.priority)
      assert.is_false(task.completed)
      assert.same({}, task.tags)
    end)

    it("should create a task with all parameters", function()
      local task = Task.new("Test Task", "Test Description", 5)

      assert.equals("Test Task", task.title)
      assert.equals("Test Description", task.description)
      assert.equals(5, task.priority)
    end)

    it("should reject empty title", function()
      assert.has_error(function()
        Task.new("")
      end, "Task title must be a non-empty string")
    end)

    it("should reject nil title", function()
      assert.has_error(function()
        Task.new(nil)
      end, "Task title must be a non-empty string")
    end)

    it("should reject invalid priority", function()
      assert.has_error(function()
        Task.new("Test", "Description", 6)
      end, "Priority must be a number between 1 and 5")
    end)

    it("should reject priority less than 1", function()
      assert.has_error(function()
        Task.new("Test", "Description", 0)
      end, "Priority must be a number between 1 and 5")
    end)

    it("should store creation timestamp", function()
      local before = os.time()
      local task = Task.new("Test")
      local after = os.time()

      local created_at = task:get_created_at()
      assert.is_true(created_at >= before and created_at <= after)
    end)
  end)

  describe("completion", function()
    local task

    before_each(function()
      task = Task.new("Test Task")
    end)

    it("should mark task as complete", function()
      assert.is_true(task:complete())
      assert.is_true(task.completed)
      assert.is_not_nil(task:get_completed_at())
    end)

    it("should not complete an already completed task", function()
      task:complete()
      local success, err = task:complete()

      assert.is_false(success)
      assert.equals("Task is already completed", err)
    end)

    it("should mark task as incomplete", function()
      task:complete()
      assert.is_true(task:uncomplete())
      assert.is_false(task.completed)
      assert.is_nil(task:get_completed_at())
    end)

    it("should not uncomplete an incomplete task", function()
      local success, err = task:uncomplete()

      assert.is_false(success)
      assert.equals("Task is not completed", err)
    end)

    it("should record completion timestamp", function()
      local before = os.time()
      task:complete()
      local after = os.time()

      local completed_at = task:get_completed_at()
      assert.is_true(completed_at >= before and completed_at <= after)
    end)
  end)

  describe("tags", function()
    local task

    before_each(function()
      task = Task.new("Test Task")
    end)

    it("should add a tag", function()
      assert.is_true(task:add_tag("urgent"))
      assert.same({"urgent"}, task.tags)
    end)

    it("should add multiple tags", function()
      task:add_tag("urgent")
      task:add_tag("work")
      task:add_tag("important")

      assert.same({"urgent", "work", "important"}, task.tags)
    end)

    it("should not add duplicate tags", function()
      task:add_tag("urgent")
      local success, err = task:add_tag("urgent")

      assert.is_false(success)
      assert.equals("Tag already exists", err)
      assert.same({"urgent"}, task.tags)
    end)

    it("should reject empty tag", function()
      assert.has_error(function()
        task:add_tag("")
      end, "Tag must be a non-empty string")
    end)

    it("should check if tag exists", function()
      task:add_tag("urgent")

      assert.is_true(task:has_tag("urgent"))
      assert.is_false(task:has_tag("work"))
    end)

    it("should remove a tag", function()
      task:add_tag("urgent")
      task:add_tag("work")

      assert.is_true(task:remove_tag("urgent"))
      assert.same({"work"}, task.tags)
    end)

    it("should return false when removing non-existent tag", function()
      local success, err = task:remove_tag("nonexistent")

      assert.is_false(success)
      assert.equals("Tag not found", err)
    end)
  end)

  describe("age calculation", function()
    it("should calculate task age", function()
      local task = Task.new("Test")
      -- Age should be very small (just created)
      assert.is_true(task:get_age() < 2)
    end)

    it("should increase age over time", function()
      local task = Task.new("Test")
      local initial_age = task:get_age()

      -- Wait a moment (this is not ideal in tests but demonstrates the concept)
      os.execute("sleep 1")

      local new_age = task:get_age()
      assert.is_true(new_age >= initial_age + 1)
    end)
  end)

  describe("serialization", function()
    it("should convert to table", function()
      local task = Task.new("Test Task", "Description", 4)
      task:add_tag("work")
      task:complete()

      local data = task:to_table()

      assert.equals("Test Task", data.title)
      assert.equals("Description", data.description)
      assert.equals(4, data.priority)
      assert.is_true(data.completed)
      assert.same({"work"}, data.tags)
      assert.is_not_nil(data.created_at)
      assert.is_not_nil(data.completed_at)
    end)

    it("should create independent copy of tags", function()
      local task = Task.new("Test")
      task:add_tag("work")

      local data = task:to_table()
      table.insert(data.tags, "extra")

      -- Original task tags should be unchanged
      assert.same({"work"}, task.tags)
    end)
  end)

  describe("string representation", function()
    it("should format incomplete task", function()
      local task = Task.new("Test Task")
      local str = tostring(task)

      assert.is_true(str:match("○"))  -- incomplete icon
      assert.is_true(str:match("P3"))  -- priority
      assert.is_true(str:match("Test Task"))
    end)

    it("should format completed task", function()
      local task = Task.new("Test Task")
      task:complete()
      local str = tostring(task)

      assert.is_true(str:match("✓"))  -- complete icon
    end)

    it("should include tags in string", function()
      local task = Task.new("Test Task")
      task:add_tag("urgent")
      task:add_tag("work")
      local str = tostring(task)

      assert.is_true(str:match("urgent"))
      assert.is_true(str:match("work"))
    end)
  end)

  describe("closures and private state", function()
    it("should protect created_at from direct modification", function()
      local task = Task.new("Test")

      -- Should not be able to set created_at directly
      assert.is_nil(task.created_at)
      assert.is_nil(task.set_created_at)

      -- But should be able to get it
      assert.is_not_nil(task:get_created_at())
    end)

    it("should protect completed_at from external modification", function()
      local task = Task.new("Test")
      task:complete()

      -- Should not expose completed_at directly
      assert.is_nil(task.completed_at)

      -- But getter should work
      assert.is_not_nil(task:get_completed_at())
    end)
  end)
end)
