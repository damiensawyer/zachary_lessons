-- Lesson 14: Power-ups and Special Effects
-- Let's add power-ups to make our game more exciting!

gamestate = "menu"

game = {
    score = 0,
    lives = 3,
    level = 1,
    high_score = 0,
    particles = {},
    powerup_timer = 0
}

player = {
    x = 400,
    y = 500,
    width = 40,
    height = 40,
    speed = 300,
    invulnerable = 0,  -- Temporary invulnerability
    shield = 0,        -- Shield power-up duration
    speed_boost = 0,   -- Speed boost duration
    magnet = 0         -- Coin magnet duration
}

coins = {}
enemies = {}
powerups = {}
spawn_timer = 0
menu_timer = 0

-- Power-up types
powerup_types = {
    {name = "shield", color = {0, 0.8, 1}, duration = 5},
    {name = "speed", color = {0, 1, 0}, duration = 8},
    {name = "life", color = {1, 0.2, 1}, duration = 0},  -- Instant effect
    {name = "magnet", color = {1, 0.8, 0}, duration = 6}
}

function love.load()
    love.window.setTitle("Super Coin Collector with Power-ups!")
    math.randomseed(os.time())
end

function reset_game()
    game.score = 0
    game.lives = 3
    game.level = 1
    game.particles = {}
    game.powerup_timer = 0
    
    player.x = 400
    player.y = 500
    player.invulnerable = 0
    player.shield = 0
    player.speed_boost = 0
    player.magnet = 0
    
    coins = {}
    enemies = {}
    powerups = {}
    spawn_timer = 0
    
    for i = 1, 5 do spawn_coin() end
    for i = 1, 2 do spawn_enemy() end
end

function spawn_coin()
    table.insert(coins, {
        x = math.random(50, 750),
        y = math.random(50, 300),
        width = 25,
        height = 25,
        rotation = 0,
        bob_timer = math.random() * math.pi * 2
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

function spawn_powerup()
    local powerup_type = powerup_types[math.random(1, #powerup_types)]
    table.insert(powerups, {
        x = math.random(50, 750),
        y = math.random(50, 350),
        width = 30,
        height = 30,
        type = powerup_type.name,
        color = powerup_type.color,
        duration = powerup_type.duration,
        rotation = 0,
        pulse_timer = 0
    })
end

function create_particle(x, y, color, count)
    count = count or 8
    for i = 1, count do
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
    if gamestate == "menu" then
        menu_timer = menu_timer + dt
    elseif gamestate == "playing" then
        update_game(dt)
    elseif gamestate == "gameover" then
        for i = #game.particles, 1, -1 do
            local p = game.particles[i]
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.life = p.life - dt
            if p.life <= 0 then table.remove(game.particles, i) end
        end
    end
end

function update_game(dt)
    -- Update player power-up timers
    if player.invulnerable > 0 then player.invulnerable = player.invulnerable - dt end
    if player.shield > 0 then player.shield = player.shield - dt end
    if player.speed_boost > 0 then player.speed_boost = player.speed_boost - dt end
    if player.magnet > 0 then player.magnet = player.magnet - dt end
    
    -- Player movement (with speed boost)
    local current_speed = player.speed
    if player.speed_boost > 0 then current_speed = current_speed * 1.5 end
    
    if love.keyboard.isDown("left") and player.x > 0 then
        player.x = player.x - current_speed * dt
    end
    if love.keyboard.isDown("right") and player.x < 800 - player.width then
        player.x = player.x + current_speed * dt
    end
    if love.keyboard.isDown("up") and player.y > 0 then
        player.y = player.y - current_speed * dt
    end
    if love.keyboard.isDown("down") and player.y < 600 - player.height then
        player.y = player.y + current_speed * dt
    end
    
    -- Coin magnet effect
    if player.magnet > 0 then
        for i = 1, #coins do
            local coin = coins[i]
            local dx = (player.x + player.width/2) - (coin.x + coin.width/2)
            local dy = (player.y + player.height/2) - (coin.y + coin.height/2)
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < 150 and distance > 0 then
                local speed = 200
                coin.x = coin.x + (dx/distance) * speed * dt
                coin.y = coin.y + (dy/distance) * speed * dt
            end
        end
    end
    
    -- Update coins
    for i = 1, #coins do
        local coin = coins[i]
        coin.rotation = coin.rotation + dt * 3
        coin.bob_timer = coin.bob_timer + dt * 4
    end
    
    -- Update power-ups
    for i = 1, #powerups do
        local powerup = powerups[i]
        powerup.rotation = powerup.rotation + dt * 2
        powerup.pulse_timer = powerup.pulse_timer + dt
    end
    
    -- Update enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.x = enemy.x + enemy.direction_x * enemy.speed * dt
        enemy.y = enemy.y + enemy.direction_y * enemy.speed * dt
        enemy.color_timer = enemy.color_timer + dt
        
        if enemy.x <= 0 or enemy.x >= 800 - enemy.width then
            enemy.direction_x = -enemy.direction_x
        end
        if enemy.y <= 0 or enemy.y >= 400 then
            enemy.direction_y = -enemy.direction_y
        end
        
        -- Check collision with player (only if not protected)
        if check_collision(player, enemy) and player.invulnerable <= 0 and player.shield <= 0 then
            game.lives = game.lives - 1
            player.invulnerable = 1  -- 1 second of invulnerability
            create_particle(player.x + player.width/2, player.y + player.height/2, {1, 0, 0})
            
            player.x = 400
            player.y = 500
            
            if game.lives <= 0 then
                if game.score > game.high_score then
                    game.high_score = game.score
                end
                gamestate = "gameover"
                return
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
            
            if game.score % 100 == 0 then
                game.level = game.level + 1
                spawn_enemy()
            end
        end
    end
    
    -- Check power-up collection
    for i = #powerups, 1, -1 do
        local powerup = powerups[i]
        if check_collision(player, powerup) then
            create_particle(powerup.x + powerup.width/2, powerup.y + powerup.height/2, powerup.color, 12)
            
            if powerup.type == "shield" then
                player.shield = powerup.duration
            elseif powerup.type == "speed" then
                player.speed_boost = powerup.duration
            elseif powerup.type == "life" then
                game.lives = game.lives + 1
            elseif powerup.type == "magnet" then
                player.magnet = powerup.duration
            end
            
            table.remove(powerups, i)
        end
    end
    
    -- Update particles
    for i = #game.particles, 1, -1 do
        local p = game.particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt * 2
        if p.life <= 0 then table.remove(game.particles, i) end
    end
    
    -- Spawn things
    spawn_timer = spawn_timer + dt
    if spawn_timer > 2 then
        spawn_coin()
        spawn_timer = 0
    end
    
    game.powerup_timer = game.powerup_timer + dt
    if game.powerup_timer > 10 then  -- Every 10 seconds
        spawn_powerup()
        game.powerup_timer = 0
    end
end

function love.draw()
    if gamestate == "menu" then
        draw_menu()
    elseif gamestate == "playing" then
        draw_game()
    elseif gamestate == "paused" then
        draw_game()
        draw_pause_overlay()
    elseif gamestate == "gameover" then
        draw_game_over()
    end
end

function draw_game()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Draw player with effects
    if player.invulnerable > 0 then
        -- Flashing when invulnerable
        if math.floor(player.invulnerable * 10) % 2 == 0 then
            love.graphics.setColor(1, 1, 1, 0.5)
        else
            love.graphics.setColor(0.3, 0.3, 1)
        end
    else
        love.graphics.setColor(0.3, 0.3, 1)
    end
    
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Shield effect
    if player.shield > 0 then
        love.graphics.setColor(0, 0.8, 1, 0.3)
        love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, 35)
        love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, 30)
    end
    
    -- Speed boost effect
    if player.speed_boost > 0 then
        love.graphics.setColor(0, 1, 0, 0.3)
        for i = 1, 3 do
            love.graphics.rectangle("fill", player.x - i*5, player.y, player.width, player.height)
        end
    end
    
    -- Magnet effect
    if player.magnet > 0 then
        love.graphics.setColor(1, 0.8, 0, 0.2)
        love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, 150)
    end
    
    -- Draw coins
    for i = 1, #coins do
        local coin = coins[i]
        local bob = math.sin(coin.bob_timer) * 5
        love.graphics.push()
        love.graphics.translate(coin.x + coin.width/2, coin.y + coin.height/2 + bob)
        love.graphics.rotate(coin.rotation)
        love.graphics.setColor(1, 1, 0.2)
        love.graphics.rectangle("fill", -coin.width/2, -coin.height/2, coin.width, coin.height)
        love.graphics.pop()
    end
    
    -- Draw power-ups
    for i = 1, #powerups do
        local powerup = powerups[i]
        local pulse = 0.7 + 0.3 * math.sin(powerup.pulse_timer * 4)
        love.graphics.push()
        love.graphics.translate(powerup.x + powerup.width/2, powerup.y + powerup.height/2)
        love.graphics.rotate(powerup.rotation)
        love.graphics.setColor(powerup.color[1], powerup.color[2], powerup.color[3], pulse)
        love.graphics.rectangle("fill", -powerup.width/2, -powerup.height/2, powerup.width, powerup.height)
        love.graphics.setColor(1, 1, 1, pulse)
        love.graphics.rectangle("line", -powerup.width/2, -powerup.height/2, powerup.width, powerup.height)
        love.graphics.pop()
    end
    
    -- Draw enemies
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
    
    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. game.score, 10, 10, 0, 1.5)
    love.graphics.print("Lives: " .. game.lives, 10, 35, 0, 1.5)
    love.graphics.print("Level: " .. game.level, 10, 60, 0, 1.5)
    
    -- Power-up status
    local y = 90
    if player.shield > 0 then
        love.graphics.setColor(0, 0.8, 1)
        love.graphics.print("SHIELD: " .. math.ceil(player.shield), 10, y)
        y = y + 20
    end
    if player.speed_boost > 0 then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("SPEED: " .. math.ceil(player.speed_boost), 10, y)
        y = y + 20
    end
    if player.magnet > 0 then
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.print("MAGNET: " .. math.ceil(player.magnet), 10, y)
        y = y + 20
    end
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("P to pause", 700, 570)
end

-- Include the menu, pause, and game over drawing functions from lesson 13...
function draw_menu()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.3)
    local bounce = math.sin(menu_timer * 3) * 10
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("POWER-UP COLLECTOR", 180, 150 + bounce, 0, 3, 3)
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print("PRESS ENTER TO START", 280, 300, 0, 1.5, 1.5)
    
    -- Show power-up legend
    love.graphics.print("POWER-UPS:", 50, 400, 0, 1.2, 1.2)
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.rectangle("fill", 50, 430, 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Shield", 80, 430)
    
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", 50, 460, 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Speed Boost", 80, 460)
    
    love.graphics.setColor(1, 0.2, 1)
    love.graphics.rectangle("fill", 250, 430, 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Extra Life", 280, 430)
    
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.rectangle("fill", 250, 460, 20, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Coin Magnet", 280, 460)
end

function draw_pause_overlay()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("PAUSED", 350, 280, 0, 3, 3)
    love.graphics.print("Press P to continue", 320, 340)
end

function draw_game_over()
    love.graphics.setBackgroundColor(0.2, 0.05, 0.05)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.print("GAME OVER", 280, 200, 0, 3, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Final Score: " .. game.score, 320, 280, 0, 1.5)
    love.graphics.print("High Score: " .. game.high_score, 325, 320, 0, 1.5)
    love.graphics.print("Press ENTER to play again", 270, 400)
end

function love.keypressed(key)
    if gamestate == "menu" then
        if key == "return" then
            reset_game()
            gamestate = "playing"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gamestate == "playing" then
        if key == "p" then
            gamestate = "paused"
        elseif key == "escape" then
            gamestate = "menu"
        end
    elseif gamestate == "paused" then
        if key == "p" then
            gamestate = "playing"
        elseif key == "escape" then
            gamestate = "menu"
        end
    elseif gamestate == "gameover" then
        if key == "return" then
            reset_game()
            gamestate = "playing"
        elseif key == "escape" then
            gamestate = "menu"
        end
    end
end

-- Final lesson coming up: polishing and advanced features!