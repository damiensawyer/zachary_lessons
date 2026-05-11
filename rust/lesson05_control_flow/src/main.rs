// Lesson 5: Control Flow
// if, loop, while, for — all expressions in Rust.

fn main() {
    // ── if / else (expressions!) ──
    let number = 7;
    let sign = if number > 0 { "positive" } else { "non-positive" };
    println!("{number} is {sign}");

    // Chained if-else
    let num = 42;
    let msg = if num < 0 {
        "negative"
    } else if num == 0 {
        "zero"
    } else if num < 100 {
        "small positive"
    } else {
        "big positive"
    };
    println!("{num} => {msg}");

    // ── loop (infinite, use break) ──
    let mut count = 0;
    let result = loop {
        count += 1;
        if count == 5 {
            break count * 10; // break returns a value
        }
    };
    println!("loop break value = {result}");

    // ── while ──
    let mut n = 3;
    while n > 0 {
        println!("{n}!");
        n -= 1;
    }
    println!("Go!");

    // ── for — the idiomatic loop in Rust ──
    for i in 1..5 {      // exclusive: 1,2,3,4
        println!("1..{i}");
    }
    for i in 1..=5 {     // inclusive: 1,2,3,4,5
        println!("1..={i}");
    }

    // Iterate over a vector
    let fruits = vec!["apple", "banana", "cherry"];
    for fruit in &fruits {
        println!("Eat a {fruit}");
    }

    // Enumerate (index + value)
    for (idx, fruit) in fruits.iter().enumerate() {
        println!("  #{idx}: {fruit}");
    }

    // ── match — Rust's super-powered switch ──
    let role = "warrior";
    let greeting = match role {
        "warrior" => "Fight bravely!",
        "mage" => "Cast your spells!",
        "thief" => "Sneak around!",
        _ => "Hello, traveler!", // _ = default / catch-all
    };
    println!("{greeting}");

    // Match with guards
    let score = 85;
    let grade = match score {
        n if n >= 90 => 'A',
        n if n >= 80 => 'B',
        n if n >= 70 => 'C',
        _ => 'F',
    };
    println!("Score {score} => grade {grade}");

    // Matching on tuples
    let point = (3, 5);
    match point {
        (0, 0) => println!("Origin"),
        (x, 0) => println!("On X axis at {x}"),
        (0, y) => println!("On Y axis at {y}"),
        (x, y) => println!("At ({x}, {y})"),
    }
}
