// Lesson 16: Result, Option, and Combinators
// Functional error handling — no exceptions, just combinators.

use std::fs;

fn main() {
    // ── Option combinators ──
    let maybe_num: Option<i32> = Some(42);
    let none: Option<i32> = None;

    // map: transform the value
    let doubled = maybe_num.map(|n| n * 2);
    println!("doubled: {:?}", doubled); // Some(84)

    // map on None — does nothing
    let none_doubled = none.map(|n| n * 2);
    println!("none doubled: {:?}", none_doubled); // None

    // flat_map: chain Option-producing functions
    let result = maybe_num.and_then(|n| {
        if n > 0 {
            Some(n * 10)
        } else {
            None
        }
    });
    println!("chained: {:?}", result); // Some(420)

    // unwrap_or, unwrap_or_else (lazy default)
    println!("default: {}", none.unwrap_or(-1));
    println!("lazy: {}", none.unwrap_or_else(|| {
        println!("  (computed)");
        999
    }));

    // and_then: chain functions returning Option
    let str_val = Some("hello");
    let len = str_val.and_then(|s| {
        if s.len() > 0 {
            Some(s.len())
        } else {
            None
        }
    });
    println!("length: {:?}", len);

    // ── Result combinators ──
    let ok: Result<i32, &str> = Ok(100);
    let err: Result<i32, &str> = Err("something broke");

    let mapped = ok.map(|x| x * 2);
    println!("ok mapped: {:?}", mapped); // Some(200)

    let mapped_err = err.map(|x| x * 2);
    println!("err mapped: {:?}", mapped_err); // Err("something broke")

    // map_err: transform the error
    let parse: Result<i32, std::num::ParseIntError> = "abc".parse();
    let string_err = parse.map_err(|e| e.to_string());
    println!("string error: {string_err:?}");

    // unwrap_or_else for Result
    let val = err.unwrap_or_else(|e| {
        eprintln!("Recovered from: {e}");
        0
    });
    println!("recovered value: {val}");

    // ── Combinator chains (functional style) ──
    let input = Some("  42  ");
    let num = input
        .and_then(|s| Some(s.trim()))
        .and_then(|s| s.parse::<i32>().ok())
        .unwrap_or(0);
    println!("chained parse: {num}");

    // ── Real-world file parsing ──
    let content = fs::read_to_string("lesson01_hello_world/src/main.rs").unwrap_or_default();
    let first_number = content
        .split_whitespace()
        .next()
        .and_then(|w| w.parse::<i32>().ok())
        .unwrap_or(-1);
    println!("First number in file: {first_number}");

    // ── Iterators with Option/Result — try_fold, etc. ──
    let numbers = vec!["1", "2", "abc", "4"];
    let sum: Result<i32, _> = numbers
        .iter()
        .map(|s| s.parse::<i32>())
        .collect(); // collects Result<Vec<i32>, E> → Result<Vec<i32>, E>
    println!("sum of all: {sum:?}");
}
