// Lesson 2: Variables and Immutability
// Rust variables are immutable by default.

fn main() {
    // Immutable by default (like `final` in Java or `const` in JS)
    let x = 5;
    println!("x = {x}");

    // Override with shadowing (same name, new scope/value)
    let x = x + 1;
    println!("x = {x} (shadowed!)");

    // Mutable with `mut`
    let mut y = 10;
    println!("y = {y}");
    y = y + 5;
    println!("y = {y} (now mutable!)");

    // Shadowing also lets you change types
    let spaces = "   ";
    let spaces: usize = spaces.len(); // shadow: now it's a number
    println!("spaces is now a {spaces} (type changed via shadowing)");

    // Constants: must be typed, must be const-evaluated
    const MAX_POINTS: u32 = 100_000;
    println!("MAX_POINTS = {MAX_POINTS}");

    // Destructuring: unpack a tuple into variables
    let color_tuple = (255u8, 0u8, 128u8);
    let (red, green, blue) = color_tuple;
    println!("RGB: {red}, {green}, {blue}");

    // Unit type: () — the "void" of Rust
    let unit = ();
    println!("Unit value: {:?}", unit);
}
