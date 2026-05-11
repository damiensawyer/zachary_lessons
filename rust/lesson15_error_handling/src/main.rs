// Lesson 15: Error Handling — Panic vs Recover
// Rust has no exceptions. Use Result<T, E> for recoverable errors,
// panic!() for unrecoverable ones.

use std::fs;
use std::num::ParseIntError;

fn main() {
    // ── panic! — unrecoverable ──
    // println!("This will panic: {}", 1 / 0); // uncomment to crash

    // Custom panic with message
    let result = divide(10, 0);
    println!("divide(10, 0) returned: {result:?}");

    // ── Result<T, E> — the idiomatic way ──
    let parse_result: Result<i32, _> = "42".parse();
    match parse_result {
        Ok(n) => println!("Parsed: {n}"),
        Err(e) => println!("Parse error: {e}"),
    }

    // Unwrap — panics on error (OK in tests, bad in production)
    let value = "42".parse::<i32>().unwrap();
    println!("Unwrapped: {value}");

    // Unwrap or else
    let val = "not_a_number".parse::<i32>().unwrap_or(-1);
    println!("unwrap_or: {val}");

    // expect — like unwrap but with a custom message
    let val = "42".parse::<i32>().expect("Should be a number");

    // ── The ? operator — propagate errors concisely ──
    match read_and_parse() {
        Ok(n) => println!("read_and_parse returned: {n}"),
        Err(e) => println!("Error: {e}"),
    }

    // ── Custom error types ──
    let parse_err: Result<i32, ParseIntError> = "abc".parse();
    if let Err(e) = parse_err {
        println!("Custom error: {e}");
    }

    // ── File I/O with ? ──
    match fs::read_to_string("lesson01_hello_world/src/main.rs") {
        Ok(content) => println!("File has {} chars", content.chars().count()),
        Err(e) => eprintln!("Could not read file: {e}"),
    }

    // ── anyhow — for application-level errors ──
    // (commonly used in practice: `cargo add anyhow`)
    // let result = anyhow::Result::Ok(42);
}

fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err(format!("Cannot divide {a} by zero"))
    } else {
        Ok(a / b)
    }
}

// Functions using ? can only return Result or Option
fn read_and_parse() -> Result<i32, ParseIntError> {
    let content = fs::read_to_string("lesson01_hello_world/src/main.rs")?; // propagate
    // Find first number-like token
    let first_word = content.split_whitespace().next().unwrap_or("0");
    let num: i32 = first_word.parse()?; // propagate
    Ok(num)
}
