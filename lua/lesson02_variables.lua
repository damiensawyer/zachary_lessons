-- Lesson 2: Variables - Storing Information
-- Variables are like boxes where we can store information!

-- Numbers
my_age = 9
favorite_number = 42
print("I am", my_age, "years old")
print("My favorite number is", favorite_number)

-- Words (we call these "strings")
my_name = "Zachary"
favorite_food = "pizza"
print("Hello, my name", my_name)
print("Hello, my name is", my_name)
print("I love", favorite_food)

print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 'Damien', 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)
print(1, 2, 3, 4, 5, 6, 7, 8, 9)


-- We can change what's in our variables!
my_age = 10 -- Happy birthday!
print("Next year I will be", my_age)

-- Math with variables
apples = 5
oranges = 3
total_fruit = apples + oranges
print("I have", total_fruit, "pieces of fruit")

-- Building sentences with variables (String Interpolation)
-- Sometimes you want to build sentences without worrying about spacing!
-- Here are three ways to do it:

-- Method 1: Using string.format() - This is like "super string interpolation"
local player_name = "Zachary"
local score = 100
local level = 5

-- %s for strings, %d for numbers
local sentence = string.format("Player %s has %d points and is on level %d", player_name, score, level)
print(sentence)

-- Method 2: Using .. to connect strings (concatenation)
local animal = "dragon"
local count = 3
local sentence2 = "I have " .. count .. " " .. animal .. "s as pets!"
print(sentence2)

-- Method 3: Using table.concat() for multiple pieces
local pieces = { "I", "like", "to", "eat", "", favorite_food }
local sentence3 = table.concat(pieces, " ")
print(sentence3)

-- Try it yourself:
-- 1. Create a variable for your favorite animal
-- 2. Create variables for how many pets you have
-- 3. Print a sentence using your variables

-- Try it yourself:
-- 1. Create a variable for your favorite animal
-- 2. Create variables for how many pets you have
-- 3. Print a sentence using your variables
-- 4. Try using string.format() to make a sentence with 3 or more variables!

