-- Lesson 8: Tables - Organizing Lots of Information!
-- Tables are like containers that can hold many things at once

-- Creating a table with a list of things
favorite_colors = {"red", "blue", "green", "purple"}

-- Getting things from the table (starts counting at 1!)
print("My first favorite color is:", favorite_colors[1])
print("My second favorite color is:", favorite_colors[2])

-- Adding things to a table
table.insert(favorite_colors, "yellow")
print("I just added yellow! Now I have", #favorite_colors, "colors")

-- Going through all items in a table
print("\nAll my favorite colors:")
for i = 1, #favorite_colors do
    print(i .. ".", favorite_colors[i])
end

-- Another way to go through a table
print("\nUsing a different loop:")
for index, color in ipairs(favorite_colors) do
    print("Color " .. index .. " is " .. color)
end

-- Tables can store different types of information
my_pet = {
    name = "Fluffy",
    type = "cat",
    age = 3,
    is_friendly = true
}

print("\nMy pet's name is", my_pet.name)
print("My pet is a", my_pet.age, "year old", my_pet.type)

-- Table of numbers for math
test_scores = {95, 87, 92, 88, 96}
total = 0

for i = 1, #test_scores do
    total = total + test_scores[i]
end

average = total / #test_scores
print("\nMy average test score is:", average)

-- Table of tables (advanced!)
students = {
    {name = "Alice", grade = 95},
    {name = "Bob", grade = 87},
    {name = "Carol", grade = 92}
}

print("\nClass grades:")
for i = 1, #students do
    local student = students[i]
    print(student.name .. " got " .. student.grade)
end

-- Try it yourself:
-- 1. Make a table of your favorite foods
-- 2. Create a table with information about your family
-- 3. Make a table of numbers and find the biggest one