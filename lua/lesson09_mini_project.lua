-- Lesson 9: Mini Project - Adventure Game!
-- Let's combine everything we've learned to make a simple text adventure!

-- Game data
player = {
    name = "",
    health = 100,
    items = {}
}

-- Function to show player status
function show_status()
    print("\n--- " .. player.name .. "'s Status ---")
    print("Health:", player.health)
    print("Items:", #player.items)
    for i = 1, #player.items do
        print("  - " .. player.items[i])
    end
    print("---")
end

-- Function to add an item
function add_item(item)
    table.insert(player.items, item)
    print("You found a " .. item .. "!")
end

-- Function to use health potion
function use_potion()
    for i = 1, #player.items do
        if player.items[i] == "health potion" then
            player.health = player.health + 50
            if player.health > 100 then
                player.health = 100
            end
            table.remove(player.items, i)
            print("You used a health potion! Health restored!")
            return
        end
    end
    print("You don't have any health potions!")
end

-- Start the game
print("🗡️  Welcome to the Mini Adventure! 🗡️")
print("What's your name, brave adventurer?")
player.name = io.read()

print("\nHello, " .. player.name .. "! Your adventure begins...")

-- Game loop
playing = true
while playing do
    print("\nYou're in a magical forest. What do you want to do?")
    print("1. Search for treasure")
    print("2. Rest (restore health)")
    print("3. Check status")
    print("4. Use health potion")
    print("5. Quit game")
    
    choice = io.read()
    
    if choice == "1" then
        -- Random events when searching
        event = math.random(1, 4)
        if event == 1 then
            add_item("magic sword")
        elseif event == 2 then
            add_item("health potion")
        elseif event == 3 then
            print("You found nothing but enjoyed the beautiful forest!")
        else
            damage = math.random(10, 25)
            player.health = player.health - damage
            print("A wild monster attacked! You lost " .. damage .. " health!")
            if player.health <= 0 then
                print("💀 Game Over! You were defeated!")
                playing = false
            end
        end
        
    elseif choice == "2" then
        heal = math.random(20, 40)
        player.health = player.health + heal
        if player.health > 100 then
            player.health = 100
        end
        print("You rest peacefully and restore " .. heal .. " health!")
        
    elseif choice == "3" then
        show_status()
        
    elseif choice == "4" then
        use_potion()
        
    elseif choice == "5" then
        print("Thanks for playing! See you next time!")
        playing = false
        
    else
        print("I don't understand that choice. Try again!")
    end
end

-- Try to enhance this game:
-- 1. Add more items like "magic shield" or "gold coins"
-- 2. Create a monster battle system
-- 3. Add different locations to explore