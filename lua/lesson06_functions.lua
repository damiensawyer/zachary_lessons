-- Lesson 6: Functions - Your Own Magic Spells!
-- Functions are like recipes or magic spells that do specific things

-- Creating our first function
function say_hello()
    print("Hello from my function!")
    print("Functions are awesome!")
end

-- Using (calling) our function
say_hello()
say_hello()  -- We can use it as many times as we want!

-- Functions with inputs (parameters)
function greet_person(name)
    print("Hello, " .. name .. "!")
    print("Welcome to Lua programming!")
end

greet_person("Zachary")
greet_person("Mom")
greet_person("Dad")

-- Functions that give back answers (return values)
function add_numbers(a, b)
    local result = a + b
    return result
end

my_sum = add_numbers(5, 3)
print("5 + 3 =", my_sum)

-- A function that calculates area of a rectangle
function rectangle_area(length, width)
    return length * width
end

room_area = rectangle_area(10, 12)
print("The room area is", room_area, "square feet")

-- Functions can make decisions too!
function describe_age(age)
    if age < 13 then
        return "kid"
    elseif age < 20 then
        return "teenager"
    else
        return "adult"
    end
end

print("A 9-year-old is a", describe_age(9))
print("A 15-year-old is a", describe_age(15))

-- Try it yourself:
-- 1. Make a function that says your favorite joke
-- 2. Create a function that multiplies two numbers
-- 3. Write a function that converts Celsius to Fahrenheit