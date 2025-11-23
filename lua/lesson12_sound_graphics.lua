-- Lesson 12: Adding Sound and Better Graphics
-- Let's make our game more exciting with sounds and improved visuals!

-- Game variables
game = {
    score = 0,
    lives = 3,
    level = 1,
    particles = {}
}

player = {
    x = 400,
    y = 500,
    width = 40,
    height = 40,
    speed = 300
}

coins = {}
enemies = {}
spawn_timer = 0

-- Sound effects (you'll need to add sound files to your game folder)
sounds = {}

function love.load()
    love.window.setTitle("Super Coin Collector!")
    
    -- Try to load sounds (optional - game works without them)
    -- Put .wav or .mp3 files in your game folder
    -- sounds.coin = love.audio.newSource("coin.wav", "static")
    -- sounds.hurt = love.audio.newSource("hurt.wav", "static")
    
    math.randomseed(os.time())
    
    -- Start with some coins and enemies
    for i = 1, 5 do
        spawn_coin()
    end
    for i = 1, 2 do
        spawn_enemy()
    end
end

function spawn_coin()
    table.insert(coins, {
        x = math.random(50, 750),
        y = math.random(50, 300),
        width = 25,
        height = 25,
        rotation = 0,
        bob_timer = math.random() * math.pi * 2  -- For floating animation
    })
end

function spawn_enemy()
    table.insert(enemies, {
        x = math.random(50, 750),
        y = math.random(50, 350),
        width = 35,
        height = 35,
        speed = 50 + game.level * 20,
        direction_x = math.random() > 0.5 and 1 or -1,
        direction_y = math.random() > 0.5 and 1 or -1,
        color_timer = 0
    })
end

function create_particle(x, y, color)
    for i = 1, 8 do
        table.insert(game.particles, {
            x = x,
            y = y,
            vx = math.random(-100, 100),
            vy = math.random(-100, 100),
            life = 1,
            color = color or {1, 1, 0}
        })
    end
end

function check_collision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect2.x < rect1.x + rect1.width and
           rect1.y < rect2.y + rect2.height and
           rect2.y < rect1.y + rect1.height
end

function love.update(dt)
    -- Player movement
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
    
    -- Update coin animations
    for i = 1, #coins do
        local coin = coins[i]
        coin.rotation = coin.rotation + dt * 3
        coin.bob_timer = coin.bob_timer + dt * 4
    end
    
    -- Update enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x + enemy.direction_x * enemy.speed * dt
        enemy.y = enemy.y + enemy.direction_y * enemy.speed * dt
        enemy.color_timer = enemy.color_timer + dt
        
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
            create_particle(player.x + player.width/2, player.y + player.height/2, {1, 0, 0})
            
            -- Play hurt sound
            -- if sounds.hurt then sounds.hurt:play() end
            
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
            create_particle(coin.x + coin.width/2, coin.y + coin.height/2)
            table.remove(coins, i)
            
            -- Play coin sound
            -- if sounds.coin then sounds.coin:play() end
            
            -- Level up every 100 points
            if game.score % 100 == 0 then
                game.level = game.level + 1
                spawn_enemy()
                print("Level up! Now level", game.level)
            end
        end
    end
    
    -- Update particles
    for i = #game.particles, 1, -1 do
        local p = game.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt * 2
        
        if p.life <= 0 then
            table.remove(game.particles, i)
        end
    end
    
    -- Spawn new coins
    spawn_timer = spawn_timer + dt
    if spawn_timer > 2 then
        spawn_coin()
        spawn_timer = 0
    end
end

function love.draw()
    -- Gradient background
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Draw player with a glow effect
    love.graphics.setColor(0.2, 0.2, 0.8, 0.3)
    love.graphics.rectangle("fill", player.x - 5, player.y - 5, player.width + 10, player.height + 10)
    love.graphics.setColor(0.3, 0.3, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Draw coins with rotation and bobbing
    for i = 1, #coins do
        local coin = coins[i]
        local bob = math.sin(coin.bob_timer) * 5
        
        love.graphics.push()
        love.graphics.translate(coin.x + coin.width/2, coin.y + coin.height/2 + bob)
        love.graphics.rotate(coin.rotation)
        love.graphics.setColor(1, 1, 0.2)
        love.graphics.rectangle("fill", -coin.width/2, -coin.height/2, coin.width, coin.height)
        love.graphics.setColor(1, 1, 0.7)
        love.graphics.rectangle("line", -coin.width/2, -coin.height/2, coin.width, coin.height)
        love.graphics.pop()
    end
    
    -- Draw enemies with pulsing color
    for i = 1, #enemies do
        local enemy = enemies[i]
        local pulse = 0.5 + 0.3 * math.sin(enemy.color_timer * 6)
        love.graphics.setColor(1, pulse * 0.3, pulse * 0.3)
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
    end
    
    -- Draw particles
    for i = 1, #game.particles do
        local p = game.particles[i]
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.circle("fill", p.x, p.y, 3)
    end
    
    -- UI with better styling
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. game.score, 10, 10, 0, 1.5)
    love.graphics.print("Lives: " .. game.lives, 10, 35, 0, 1.5)
    love.graphics.print("Level: " .. game.level, 10, 60, 0, 1.5)
    
    -- Instructions
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Arrow keys to move • Collect coins • Avoid red enemies!", 10, 570)
end

-- Next lesson: We'll add multiple game states and a menu!