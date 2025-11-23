-- Lesson 5: Making Decisions with If Statements
-- Sometimes our programs need to make choices!

-- Basic if statement
weather = "sunny"
if weather == "sunny" then
    print("Let's go to the park!")
end

-- if-else statement
temperature = 75
if temperature > 70 then
    print("It's warm! Perfect for shorts.")
else
    print("It's cool! Better wear a jacket.")
end

-- Multiple conditions with elseif
grade = 95
if grade >= 90 then
    print("Amazing! You got an A!")
elseif grade >= 80 then
    print("Great job! You got a B!")
elseif grade >= 70 then
    print("Good work! You got a C!")
else
    print("Keep studying! You can do better!")
end

-- Comparing things
print("What's your favorite number?")
favorite = tonumber(io.read())

if favorite == 7 then
    print("7 is my lucky number too!")
elseif favorite > 10 then
    print("That's a big number!")
elseif favorite < 0 then
    print("Negative numbers are interesting!")
else
    print("Cool choice!")
end

-- Fun with comparisons
age = 9
if age >= 13 then
    print("You're a teenager!")
elseif age >= 10 then
    print("Almost a teenager!")
else
    print("You're still a kid - enjoy it!")
end

-- Try it yourself:
-- 1. Ask for a number and tell if it's even or odd (hint: use %)
-- 2. Make a simple password checker
-- 3. Create a "guess my number" game