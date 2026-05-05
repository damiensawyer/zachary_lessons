-- Lesson 15: Final Polished Game - The Complete Experience!
-- This is our masterpiece with all the features we've learned!

gamestate = "menu"

game = {
    score = 0,
    lives = 3,
    level = 1,
    high_score = 0,
    particles = {},
    powerup_timer = 0,
    difficulty_timer = 0,
    screen_shake = 0,
    boss_mode = false,
    boss = nil
}

player = {
    x = 400,
    y = 500,
    width = 40,
    height = 40,
    speed = 300,
    invulnerable = 0,
    shield = 0,
    speed_boost = 0,
    magnet = 0,
    multi_shot = 0,
    trail = {}
}

coins = {}
enemies = {}
powerups = {}
projectiles = {}
spawn_timer = 0
menu_timer = 0

powerup_types = {
    {name = "shield", color = {0, 0.8, 1}, duration = 5},
    {name = "speed", color = {0, 1, 0}, duration = 8},
    {name = "life", color = {1, 0.2, 1}, duration = 0},
    {name = "magnet", color = {1, 0.8, 0}, duration = 6},
    {name = "multi_shot", color = {1, 0.5, 0}, duration = 10}
}

function love.load()
    love.window.setTitle("Super Coin Collector DELUXE EDITION!")
    math.randomseed(os.time())
end

function reset_game()
    game.score = 0
    game.lives = 3
    game.level = 1
    game.particles = {}
    game.powerup_timer = 0
    game.difficulty_timer = 0
    game.screen_shake = 0
    game.boss_mode = false
    game.boss = nil
    
    player.x = 400
    player.y = 500
    player.invulnerable = 0
    player.shield = 0
    player.speed_boost = 0
    player.magnet = 0
    player.multi_shot = 0
    player.trail = {}
    
    coins = {}
    enemies = {}
    powerups = {}
    projectiles = {}
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
        bob_timer = math.random() * math.pi * 2,
        sparkle_timer = 0
    })
end

function spawn_enemy()
    local enemy_type = math.random(1, 3)
    local enemy = {
        x = math.random(50, 750),
        y = math.random(50, 350),
        width = 35,
        height = 35,
        speed = 50 + game.level * 15,
        direction_x = math.random() > 0.5 and 1 or -1,
        direction_y = math.random() > 0.5 and 1 or -1,
        color_timer = 0,
        type = enemy_type,
        health = 1
    }
    
    if enemy_type == 2 then  -- Fast enemy
        enemy.speed = enemy.speed * 1.5
        enemy.width = 25
        enemy.height = 25
    elseif enemy_type == 3 then  -- Tough enemy
        enemy.health = 2
        enemy.width = 45
        enemy.height = 45
        enemy.speed = enemy.speed * 0.7
    end
    
    table.insert(enemies, enemy)
end

function spawn_boss()
    game.boss = {
        x = 300,
        y = 100,
        width = 200,
        height = 100,
        health = 20,
        max_health = 20,
        direction_x = 1,
        shoot_timer = 0,
        pattern = 1
    }
    game.boss_mode = true
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

function create_particle(x, y, color, count, speed)
    count = count or 8
    speed = speed or 100
    for i = 1, count do
        table.insert(game.particles, {
            x = x,
            y = y,
            vx = math.random(-speed, speed),
            vy = math.random(-speed, speed),
            life = 1,
            color = color or {1, 1, 0},
            size = math.random(2, 5)
        })
    end
end

function screen_shake(intensity)
    game.screen_shake = math.max(game.screen_shake, intensity)
end

function check_collision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect2.x < rect1.x + rect1.width and
           rect1.y < rect2.y + rect2.height and
           rect2.y < rect1.y + rect1.height
end

function shoot_projectile(x, y, vx, vy, friendly)
    table.insert(projectiles, {
        x = x,
        y = y,
        width = 8,
        height = 8,
        vx = vx,
        vy = vy,
        friendly = friendly or false,
        life = 3
    })
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
    
    -- Update screen shake
    if game.screen_shake > 0 then
        game.screen_shake = game.screen_shake - dt * 5
        if game.screen_shake < 0 then game.screen_shake = 0 end
    end
end

function update_game(dt)
    -- Update player timers
    if player.invulnerable > 0 then player.invulnerable = player.invulnerable - dt end
    if player.shield > 0 then player.shield = player.shield - dt end
    if player.speed_boost > 0 then player.speed_boost = player.speed_boost - dt end
    if player.magnet > 0 then player.magnet = player.magnet - dt end
    if player.multi_shot > 0 then player.multi_shot = player.multi_shot - dt end
    
    -- Player movement
    local current_speed = player.speed
    if player.speed_boost > 0 then current_speed = current_speed * 1.5 end
    
    local old_x, old_y = player.x, player.y
    
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
    
    -- Player trail effect
    if old_x ~= player.x or old_y ~= player.y then
        table.insert(player.trail, {x = old_x + player.width/2, y = old_y + player.height/2, life = 0.3})
        if #player.trail > 10 then
            table.remove(player.trail, 1)
        end
    end
    
    -- Update trail
    for i = #player.trail, 1, -1 do
        player.trail[i].life = player.trail[i].life - dt
        if player.trail[i].life <= 0 then
            table.remove(player.trail, i)
        end
    end
    
    -- Shooting (space bar)
    if love.keyboard.isDown("space") then
        if player.multi_shot > 0 then
            -- Multi-shot pattern
            for angle = -0.5, 0.5, 0.25 do
                shoot_projectile(player.x + player.width/2, player.y, 
                    math.sin(angle) * 300, -300 + math.abs(angle) * 100, true)
            end
        else
            shoot_projectile(player.x + player.width/2, player.y, 0, -300, true)
        end
    end
    
    -- Coin magnet
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
        coin.sparkle_timer = coin.sparkle_timer + dt
    end
    
    -- Update powerups
    for i = 1, #powerups do
        local powerup = powerups[i]
        powerup.rotation = powerup.rotation + dt * 2
        powerup.pulse_timer = powerup.pulse_timer + dt
    end
    
    -- Update projectiles
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt
        proj.life = proj.life - dt
        
        if proj.life <= 0 or proj.x < 0 or proj.x > 800 or proj.y < 0 or proj.y > 600 then
            table.remove(projectiles, i)
        end
    end
    
    -- Update boss
    if game.boss then
        local boss = game.boss
        boss.x = boss.x + boss.direction_x * 100 * dt
        
        if boss.x <= 0 or boss.x >= 800 - boss.width then
            boss.direction_x = -boss.direction_x
        end
        
        boss.shoot_timer = boss.shoot_timer + dt
        if boss.shoot_timer > 0.5 then
            -- Boss shooting pattern
            local px = player.x + player.width/2
            local py = player.y + player.height/2
            local bx = boss.x + boss.width/2
            local by = boss.y + boss.height/2
            
            local angle = math.atan2(py - by, px - bx)
            shoot_projectile(bx, by, math.cos(angle) * 200, math.sin(angle) * 200, false)
            
            boss.shoot_timer = 0
        end
        
        -- Check boss hit by projectiles
        for i = #projectiles, 1, -1 do
            local proj = projectiles[i]
            if proj.friendly and check_collision(proj, boss) then
                boss.health = boss.health - 1
                create_particle(proj.x, proj.y, {1, 0.5, 0}, 5)
                table.remove(projectiles, i)
                screen_shake(0.2)
                
                if boss.health <= 0 then
                    create_particle(boss.x + boss.width/2, boss.y + boss.height/2, {1, 1, 0}, 20, 200)
                    game.score = game.score + 500
                    game.boss = nil
                    game.boss_mode = false
                    screen_shake(0.5)
                end
            end
        end
        
        -- Boss collision with player
        if check_collision(player, boss) and player.invulnerable <= 0 and player.shield <= 0 then
            game.lives = game.lives - 1
            player.invulnerable = 1
            screen_shake(0.3)
        end
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
        
        -- Check enemy hit by projectiles
        for j = #projectiles, 1, -1 do
            local proj = projectiles[j]
            if proj.friendly and check_collision(proj, enemy) then
                enemy.health = enemy.health - 1
                create_particle(proj.x, proj.y, {1, 0, 0}, 3)
                table.remove(projectiles, j)
                
                if enemy.health <= 0 then
                    create_particle(enemy.x + enemy.width/2, enemy.y + enemy.height/2, {1, 0, 0}, 8)
                    game.score = game.score + 25
                    table.remove(enemies, i)
                    break
                end
            end
        end
        
        -- Enemy collision with player
        if i <= #enemies and check_collision(player, enemy) and player.invulnerable <= 0 and player.shield <= 0 then
            game.lives = game.lives - 1
            player.invulnerable = 1
            create_particle(player.x + player.width/2, player.y + player.height/2, {1, 0, 0})
            screen_shake(0.2)
            
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
    
    -- Player hit by enemy projectiles
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        if not proj.friendly and check_collision(player, proj) and player.invulnerable <= 0 and player.shield <= 0 then
            game.lives = game.lives - 1
            player.invulnerable = 1
            create_particle(proj.x, proj.y, {1, 0, 0})
            screen_shake(0.15)
            table.remove(projectiles, i)
            
            if game.lives <= 0 then
                if game.score > game.high_score then
                    game.high_score = game.score
                end
                gamestate = "gameover"
                return
            end
        end
    end
    
    -- Coin collection
    for i = #coins, 1, -1 do
        local coin = coins[i]
        if check_collision(player, coin) then
            game.score = game.score + 10
            create_particle(coin.x + coin.width/2, coin.y + coin.height/2)
            table.remove(coins, i)
        end
    end
    
    -- Powerup collection
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
            elseif powerup.type == "multi_shot" then
                player.multi_shot = powerup.duration
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
    
    -- Spawning logic
    spawn_timer = spawn_timer + dt
    if spawn_timer > 1.5 then
        spawn_coin()
        if math.random() < 0.7 then
            spawn_enemy()
        end
        spawn_timer = 0
    end
    
    game.powerup_timer = game.powerup_timer + dt
    if game.powerup_timer > 8 then
        spawn_powerup()
        game.powerup_timer = 0
    end
    
    -- Difficulty scaling
    game.difficulty_timer = game.difficulty_timer + dt
    if game.difficulty_timer > 30 then -- Every 30 seconds
        game.level = game.level + 1
        game.difficulty_timer = 0
        
        -- Spawn boss every 5 levels
        if game.level % 5 == 0 and not game.boss_mode then
            spawn_boss()
        end
    end
end

function love.draw()
    -- Apply screen shake
    if game.screen_shake > 0 then
        local shake_x = (math.random() - 0.5) * game.screen_shake * 20
        local shake_y = (math.random() - 0.5) * game.screen_shake * 20
        love.graphics.push()
        love.graphics.translate(shake_x, shake_y)
    end
    
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
    
    if game.screen_shake > 0 then
        love.graphics.pop()
    end
end

function draw_game()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Draw player trail
    for i = 1, #player.trail do
        local trail = player.trail[i]
        love.graphics.setColor(0.3, 0.3, 1, trail.life)
        love.graphics.circle("fill", trail.x, trail.y, 5)
    end
    
    -- Draw player
    if player.invulnerable > 0 and math.floor(player.invulnerable * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(0.3, 0.3, 1)
    end
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Player effects
    if player.shield > 0 then
        love.graphics.setColor(0, 0.8, 1, 0.3)
        love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, 35)
    end
    if player.speed_boost > 0 then
        love.graphics.setColor(0, 1, 0, 0.3)
        for i = 1, 3 do
            love.graphics.rectangle("fill", player.x - i*5, player.y, player.width, player.height)
        end
    end
    if player.magnet > 0 then
        love.graphics.setColor(1, 0.8, 0, 0.2)
        love.graphics.circle("line", player.x + player.width/2, player.y + player.height/2, 150)
    end
    
    -- Draw coins with sparkles
    for i = 1, #coins do
        local coin = coins[i]
        local bob = math.sin(coin.bob_timer) * 5
        
        -- Sparkle effect
        if math.sin(coin.sparkle_timer * 8) > 0.8 then
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.circle("fill", coin.x + coin.width/2, coin.y + coin.height/2 + bob, coin.width/2 + 5)
        end
        
        love.graphics.push()
        love.graphics.translate(coin.x + coin.width/2, coin.y + coin.height/2 + bob)
        love.graphics.rotate(coin.rotation)
        love.graphics.setColor(1, 1, 0.2)
        love.graphics.rectangle("fill", -coin.width/2, -coin.height/2, coin.width, coin.height)
        love.graphics.pop()
    end
    
    -- Draw powerups
    for i = 1, #powerups do
        local powerup = powerups[i]
        local pulse = 0.7 + 0.3 * math.sin(powerup.pulse_timer * 4)
        love.graphics.push()
        love.graphics.translate(powerup.x + powerup.width/2, powerup.y + powerup.height/2)
        love.graphics.rotate(powerup.rotation)
        love.graphics.setColor(powerup.color[1], powerup.color[2], powerup.color[3], pulse)
        love.graphics.rectangle("fill", -powerup.width/2, -powerup.height/2, powerup.width, powerup.height)
        love.graphics.pop()
    end
    
    -- Draw enemies
    for i = 1, #enemies do
        local enemy = enemies[i]
        local pulse = 0.5 + 0.3 * math.sin(enemy.color_timer * 6)
        
        if enemy.type == 1 then -- Normal enemy
            love.graphics.setColor(1, pulse * 0.3, pulse * 0.3)
        elseif enemy.type == 2 then -- Fast enemy
            love.graphics.setColor(pulse, 0.5, 0.5)
        elseif enemy.type == 3 then -- Tough enemy
            love.graphics.setColor(0.8, 0, 0)
        end
        
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
        
        -- Health indicator for tough enemies
        if enemy.type == 3 and enemy.health == 1 then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("fill", enemy.x, enemy.y - 10, enemy.width, 5)
        end
    end
    
    -- Draw boss
    if game.boss then
        local boss = game.boss
        love.graphics.setColor(0.8, 0, 0.8)
        love.graphics.rectangle("fill", boss.x, boss.y, boss.width, boss.height)
        
        -- Boss health bar
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", boss.x, boss.y - 20, boss.width, 10)
        love.graphics.setColor(0, 1, 0)
        local health_ratio = boss.health / boss.max_health
        love.graphics.rectangle("fill", boss.x, boss.y - 20, boss.width * health_ratio, 10)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("BOSS", boss.x + boss.width/2 - 15, boss.y + boss.height/2)
    end
    
    -- Draw projectiles
    for i = 1, #projectiles do
        local proj = projectiles[i]
        if proj.friendly then
            love.graphics.setColor(0, 1, 1)
        else
            love.graphics.setColor(1, 0.5, 0)
        end
        love.graphics.circle("fill", proj.x, proj.y, proj.width/2)
    end
    
    -- Draw particles
    for i = 1, #game.particles do
        local p = game.particles[i]
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.circle("fill", p.x, p.y, p.size)
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
    if player.multi_shot > 0 then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("MULTI-SHOT: " .. math.ceil(player.multi_shot), 10, y)
        y = y + 20
    end
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("SPACE to shoot • P to pause", 10, 570)
end

function draw_menu()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.3)
    local bounce = math.sin(menu_timer * 3) * 10
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("ULTIMATE COLLECTOR", 150, 100 + bounce, 0, 3, 3)
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print("DELUXE EDITION", 270, 150, 0, 2, 2)
    love.graphics.print("PRESS ENTER TO START", 280, 250, 0, 1.5, 1.5)
    
    if game.high_score > 0 then
        love.graphics.print("HIGH SCORE: " .. game.high_score, 320, 300, 0, 1.2, 1.2)
    end
    
    love.graphics.print("CONTROLS:", 50, 380, 0, 1.2, 1.2)
    love.graphics.print("Arrow Keys: Move", 50, 410)
    love.graphics.print("Space: Shoot", 50, 430)
    love.graphics.print("Collect coins, avoid enemies!", 50, 450)
    
    -- Animated background elements
    for i = 1, 8 do
        local x = 100 + i * 80
        local y = 500 + math.sin(menu_timer * 2 + i) * 30
        love.graphics.setColor(1, 1, 0.2, 0.6)
        love.graphics.circle("fill", x, y, 10)
    end
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
    love.graphics.print("GAME OVER", 280, 150, 0, 3, 3)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Final Score: " .. game.score, 320, 230, 0, 1.5)
    love.graphics.print("High Score: " .. game.high_score, 325, 270, 0, 1.5)
    
    if game.score == game.high_score then
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("NEW HIGH SCORE!", 300, 310, 0, 1.2)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Press ENTER to play again", 270, 400)
    love.graphics.print("Press ESC for menu", 320, 440)
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

-- Congratulations! You've built a complete game with Lua and Love2D!
-- This game includes: multiple enemy types, boss battles, power-ups,
-- particle effects, screen shake, shooting mechanics, trail effects,
-- game states, difficulty scaling, and much more!

-- Ideas for further improvement:
-- 1. Add sound effects and music
-- 2. Create different levels/backgrounds
-- 3. Add more enemy types and boss patterns
-- 4. Implement a save system for high scores
-- 5. Add achievements or unlockables
-- 6. Create animated sprites instead of rectangles
-- 7. Add multiplayer support