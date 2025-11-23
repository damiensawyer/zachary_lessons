-- Lesson 11: Game Basics - Adding Objects and Collision
-- Let's start building a real game! Save as main.lua for Love2D

-- Game state
game = {
    score = 0,
    lives = 3
}

-- Player object
player = {
    x = 400,
    y = 500,
    width = 50,
    height = 50,
    speed = 300
}

-- Collectible items (coins)
coins = {}

-- Enemies
enemies = {}

-- Timer for spawning things
spawn_timer = 0

function love.load()
    love.window.setTitle("Coin Collector Game!")
    math.randomseed(os.time())  -- Make random numbers actually random
    
    -- Create some initial coins
    for i = 1, 5 do
        spawn_coin()
    end
    
    -- Create some enemies
    for i = 1, 3 do
        spawn_enemy()
    end
end

function spawn_coin()
    local coin = {
        x = math.random(50, 750),
        y = math.random(50, 200),
        width = 30,
        height = 30
    }
    table.insert(coins, coin)
end

function spawn_enemy()
    local enemy = {
        x = math.random(50, 750),
        y = math.random(50, 300),
        width = 40,
        height = 40,
        speed = math.random(50, 150),
        direction_x = math.random() > 0.5 and 1 or -1,
        direction_y = math.random() > 0.5 and 1 or -1
    }
    table.insert(enemies, enemy)
end

-- Function to check if two rectangles overlap (collision detection)
function check_collision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect2.x < rect1.x + rect1.width and
           rect1.y < rect2.y + rect2.height and
           rect2.y < rect1.y + rect1.height
end

function love.update(dt)
    -- Move player with arrow keys
    if love.keyboard.isDown("left") and player.x > 0 then
        player.x = player.x - player.speed * dt
    end
    
    if love.keyboard.isDown("right") and player.x < 800 - player.width then
        player.x = player.x + player.speed * dt
    end
    
    if love.keyboard.isDown("up") and player.y > 0 then
        player.y = player.y - player.speed * dt
    end
    
    if love.keyboard.isDown("down") and player.y < 600 - player.height then
        player.y = player.y + player.speed * dt
    end
    
    -- Move enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x + enemy.direction_x * enemy.speed * dt
        enemy.y = enemy.y + enemy.direction_y * enemy.speed * dt
        
        -- Bounce off walls
        if enemy.x <= 0 or enemy.x >= 800 - enemy.width then
            enemy.direction_x = -enemy.direction_x
        end
        if enemy.y <= 0 or enemy.y >= 400 then
            enemy.direction_y = -enemy.direction_y
        end
        
        -- Check collision with player
        if check_collision(player, enemy) then
            game.lives = game.lives - 1
            print("Ouch! Lives left:", game.lives)
            
            -- Move player away from enemy
            player.x = 400
            player.y = 500
            
            if game.lives <= 0 then
                print("Game Over! Final score:", game.score)
                love.event.quit()
            end
        end
    end
    
    -- Check coin collection
    for i = #coins, 1, -1 do
        local coin = coins[i]
        if check_collision(player, coin) then
            game.score = game.score + 10
            table.remove(coins, i)
            print("Coin collected! Score:", game.score)
        end
    end
    
    -- Spawn new coins occasionally
    spawn_timer = spawn_timer + dt
    if spawn_timer > 3 then  -- Every 3 seconds
        spawn_coin()
        spawn_timer = 0
    end
end

function love.draw()
    -- Background
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
    
    -- Draw player (blue)
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Draw coins (yellow)
    love.graphics.setColor(1, 1, 0)
    for i = 1, #coins do
        local coin = coins[i]
        love.graphics.circle("fill", coin.x + coin.width/2, coin.y + coin.height/2, coin.width/2)
    end
    
    -- Draw enemies (red)
    love.graphics.setColor(1, 0, 0)
    for i = 1, #enemies do
        local enemy = enemies[i]
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
    end
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. game.score, 10, 10)
    love.graphics.print("Lives: " .. game.lives, 10, 30)
    love.graphics.print("Use arrow keys to move and collect yellow coins!", 10, 570)
end

-- Try this game and then enhance it:
-- 1. Make enemies move in different patterns
-- 2. Add power-ups that give extra lives
-- 3. Increase difficulty over time