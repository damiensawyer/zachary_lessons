-- Lesson 7: Loops - Doing Things Over and Over!
-- Loops let us repeat things without writing the same code many times

-- While loop - keeps going while something is true
print("Counting to 5 with a while loop:")
count = 1
while count <= 5 do
    print("Count is:", count)
    count = count + 1  -- This is very important! Don't forget it!
end

-- For loop - great for counting
print("\nCounting to 10 with a for loop:")
for i = 1, 10 do
    print("Number:", i)
end

-- For loop with steps (counting by 2s)
print("\nCounting by 2s:")
for i = 2, 20, 2 do
    print(i)
end

-- Countdown!
print("\nRocket countdown:")
for i = 10, 1, -1 do
    print(i)
end
print("Blast off! 🚀")

-- Loops with functions
function print_stars(num)
    for i = 1, num do
        io.write("*")  -- io.write doesn't add a new line
    end
    print()  -- Add the new line at the end
end

print("\nMaking patterns:")
for size = 1, 5 do
    print_stars(size)
end

-- Asking until we get the right answer
print("\nGuess my favorite number (between 1 and 10):")
secret_number = 7
guess = 0

while guess ~= secret_number do
    guess = tonumber(io.read())
    if guess == secret_number then
        print("You got it! Great job!")
    else
        print("Nope! Try again:")
    end
end

-- Try it yourself:
-- 1. Make a loop that prints your name 8 times
-- 2. Count backwards from 100 to 90
-- 3. Create a multiplication table for the number 3