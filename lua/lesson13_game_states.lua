-- Lesson 13: Game States - Menu, Playing, Game Over
-- Professional games have different screens. Let's add them!

-- Game state system
gamestate = "menu"  -- Can be "menu", "playing", "gameover", "paused"

-- Game data
game = {
    score = 0,
    lives = 3,
    level = 1,
    high_score = 0,
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

-- Menu animation
menu_timer = 0

function love.load()
    love.window.setTitle("Super Coin Collector Deluxe!")
    math.randomseed(os.time())
end

function reset_game()
    game.score = 0
    game.lives = 3
    game.level = 1
    game.particles = {}
    
    player.x = 400
    player.y = 500
    
    coins = {}
    enemies = {}
    spawn_timer = 0
    
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
    if gamestate == "menu" then
        menu_timer = menu_timer + dt
        
    elseif gamestate == "playing" then
        update_game(dt)
        
    elseif gamestate == "paused" then
        -- Game is paused, don't update anything
        
    elseif gamestate == "gameover" then
        -- Update particles for game over screen
        for i = #game.particles, 1, -1 do
            local p = game.particles[i]
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.life = p.life - dt
            if p.life <= 0 then
                table.remove(game.particles, i)
            end
        end
    end
end

function update_game(dt)
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
    
    -- Update coins
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
        
        if enemy.x <= 0 or enemy.x >= 800 - enemy.width then
            enemy.direction_x = -enemy.direction_x
        end
        if enemy.y <= 0 or enemy.y >= 400 then
            enemy.direction_y = -enemy.direction_y
        end
        
        if check_collision(player, enemy) then
            game.lives = game.lives - 1
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

function draw_menu()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.3)
    
    -- Animated title
    local bounce = math.sin(menu_timer * 3) * 10
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("SUPER COIN COLLECTOR", 200, 150 + bounce, 0, 3, 3)
    
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print("PRESS ENTER TO START", 280, 300, 0, 1.5, 1.5)
    love.graphics.print("ARROW KEYS TO MOVE", 290, 350, 0, 1.2, 1.2)
    love.graphics.print("ESC TO QUIT", 340, 400, 0, 1.2, 1.2)
    
    if game.high_score > 0 then
        love.graphics.print("HIGH SCORE: " .. game.high_score, 320, 450, 0, 1.2, 1.2)
    end
    
    -- Floating demo coins
    for i = 1, 5 do
        local x = 100 + i * 120
        local y = 500 + math.sin(menu_timer * 2 + i) * 20
        love.graphics.setColor(1, 1, 0.2)
        love.graphics.circle("fill", x, y, 15)
    end
end

function draw_game()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.15)
    
    -- Draw player
    love.graphics.setColor(0.3, 0.3, 1)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
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
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("P to pause", 700, 570)
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
    love.graphics.print("Press ESC to quit", 320, 440)
    
    -- Draw particles
    for i = 1, #game.particles do
        local p = game.particles[i]
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.circle("fill", p.x, p.y, 3)
    end
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

-- Next lesson: We'll add power-ups and special effects!