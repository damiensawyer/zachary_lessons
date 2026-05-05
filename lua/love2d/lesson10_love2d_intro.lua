-- Lesson 10: Introduction to Love2D - Making Real Games!
-- Love2D is a framework that lets us make actual games with graphics!

-- This file needs to be named main.lua when you run it in Love2D
-- To run: Put this code in a file called main.lua and drag the folder onto Love2D

-- Game variables
player_x = 400  -- Player's x position
player_y = 300  -- Player's y position
player_speed = 200  -- How fast the player moves

-- This function runs once when the game starts
function love.load()
    -- Set up the game
    love.window.setTitle("My First Love2D Game!")
    print("Welcome to Love2D!")
    print("Use arrow keys to move the green square!")
end

-- This function runs every frame (many times per second)
function love.update(dt)
    -- dt is "delta time" - how much time has passed since last frame
    
    -- Check if arrow keys are pressed and move the player
    if love.keyboard.isDown("left") then
        player_x = player_x - player_speed * dt
    end
    
    if love.keyboard.isDown("right") then
        player_x = player_x + player_speed * dt
    end
    
    if love.keyboard.isDown("up") then
        player_y = player_y - player_speed * dt
    end
    
    if love.keyboard.isDown("down") then
        player_y = player_y + player_speed * dt
    end
    
    -- Keep player on screen
    if player_x < 0 then player_x = 0 end
    if player_x > 800 - 50 then player_x = 800 - 50 end
    if player_y < 0 then player_y = 0 end
    if player_y > 600 - 50 then player_y = 600 - 50 end
end

-- This function draws everything on the screen
function love.draw()
    -- Set the background color to light blue
    love.graphics.setBackgroundColor(0.5, 0.8, 1)
    
    -- Draw the player as a green rectangle
    love.graphics.setColor(0, 1, 0)  -- Green color
    love.graphics.rectangle("fill", player_x, player_y, 50, 50)
    
    -- Draw some text
    love.graphics.setColor(1, 1, 1)  -- White color
    love.graphics.print("Use arrow keys to move!", 10, 10)
    love.graphics.print("Player position: " .. math.floor(player_x) .. ", " .. math.floor(player_y), 10, 30)
    
    -- Draw a red circle that follows the mouse
    local mouse_x, mouse_y = love.mouse.getPosition()
    love.graphics.setColor(1, 0, 0)  -- Red color
    love.graphics.circle("fill", mouse_x, mouse_y, 20)
end

-- This function runs when a key is pressed
function love.keypressed(key)
    if key == "space" then
        print("Space bar pressed!")
        -- Reset player position
        player_x = 400
        player_y = 300
    end
    
    if key == "escape" then
        love.event.quit()  -- Quit the game
    end
end

-- To run this game:
-- 1. Install Love2D from https://love2d.org/
-- 2. Create a new folder for your game
-- 3. Save this code as "main.lua" in that folder
-- 4. Drag the folder onto the Love2D application
-- 5. Play your game!

-- In the next lessons, we'll make this into a real game with:
-- - Enemies to avoid
-- - Items to collect
-- - Sound effects
-- - Multiple levels