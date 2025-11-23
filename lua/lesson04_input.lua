-- Lesson 4: Getting Input from the User
-- Let's make our programs interactive!

-- io.read() lets us get input from the person using our program
print("What's your name?")
user_name = io.read()  -- This waits for the user to type something
print("Hello, " .. user_name .. "! Nice to meet you!")

-- Let's ask for their age
print("How old are you?")
age_text = io.read()
age = tonumber(age_text)  -- Convert text to a number
print("Wow, " .. age .. " is a great age!")

-- Calculate something fun
years_until_driving = 16 - age
if years_until_driving > 0 then
    print("Only", years_until_driving, "more years until you can drive!")
else
    print("You're old enough to drive!")
end

-- Let's make a simple calculator
print("\nLet's do some math!")
print("Give me a number:")
num1 = tonumber(io.read())

print("Give me another number:")
num2 = tonumber(io.read())

print("Here are the results:")
print(num1, "+", num2, "=", num1 + num2)
print(num1, "*", num2, "=", num1 * num2)

-- Try it yourself:
-- 1. Ask for the user's favorite color and respond
-- 2. Ask for two numbers and subtract them
-- 3. Create a program that asks for your pet's name and age