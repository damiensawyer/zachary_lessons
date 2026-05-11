// Lesson 4: Functions
// Everything lives in functions. No top-level code.

// Functions return the value of their last expression (no `return` needed)
fn add(a: i32, b: i32) -> i32 {
    a + b  // no semicolon = implicit return
}

fn greet(name: &str) -> String {
    let greeting = format!("Hello, {name}! Welcome to Rust!");
    greeting // explicit return also works
}

// Unit return (no -> clause needed)
fn print_message(msg: &str) {
    println!("{msg}");
}

// Multiple parameters, multiple expressions in block
fn max(a: i32, b: i32) -> i32 {
    if a > b { a } else { b } // ternary-like, but it's just an if expression
}

fn main() {
    // Function calls
    println!("5 + 3 = {}", add(5, 3));
    println!("{}", greet("Rustacean"));
    print_message("Functions are first-class citizens... kind of.");

    // Using if as an expression (no ternary operator needed!)
    let result = if true { 1 } else { 2 };
    println!("if expression = {result}");

    // Matching with if let chains (Rust 1.82+)
    let opt = Some(42);
    let value = if let Some(v) = opt {
        v * 2
    } else {
        0
    };
    println!("if let unwrapping = {value}");

    // Functions can be passed as parameters (higher-order functions)
    let numbers = vec![1, 2, 3, 4, 5];
    let doubled: Vec<i32> = numbers.iter().map(|x| x * 2).collect();
    println!("doubled = {:?}", doubled);

    // Functions can be stored in variables
    let say_hi = |name: &str| -> String { format!("Hi, {name}!") };
    println!("{}", say_hi("World"));
}
