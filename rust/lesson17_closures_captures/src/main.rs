// Lesson 17: Closures — Anonymous Functions That Capture
// Closures can capture variables from their environment.

fn main() {
    // ── Basic closures ──
    let add = |a, b| a + b; // inferred return type
    println!("3 + 4 = {}", add(3, 4));

    // Explicit types
    let multiply: (i32, i32) -> i32 = |x, y| x * y;
    println!("5 * 6 = {}", multiply(5, 6));

    // Single expression (no braces, implicit return)
    let square = |x| x * x;
    println!("square(7) = {}", square(7));

    // ── Capturing variables ──
    let x = 10;
    let capture_sum = || x + 5; // captures x by reference
    println!("captured sum: {}", capture_sum());

    // Move closure — takes ownership of captured vars
    let text = String::from("hello");
    let take_ownership = || {
        println!("Text: {text}");
        // text; // would consume text
    };
    take_ownership();
    // println!("{}", text); // ERROR: text moved
    // let text2 = String::from("world");
    // let consume = || { drop(text2); };
    // consume();

    // ── Closure traits: Fn, FnMut, FnOnce ──
    let mut count = 0;

    // Fn — reads only (can be called multiple times)
    let reads = || {
        count += 1;
        count
    };
    println!("{} {}", reads(), reads());

    // ── Closures with iterators ──
    let numbers = vec![1, 2, 3, 4, 5];

    // map — transform
    let squared: Vec<i32> = numbers.iter().map(|n| n * n).collect();
    println!("squared: {:?}", squared);

    // filter — select
    let evens: Vec<i32> = numbers.iter().filter(|n| n % 2 == 0).cloned().collect();
    println!("evens: {:?}", evens);

    // filter + map
    let even_squares: Vec<i32> = numbers.iter()
        .filter(|n| n % 2 == 0)
        .map(|n| n * n)
        .collect();
    println!("even squares: {:?}", even_squares);

    // ── Higher-order function accepting closures ──
    let apply_twice = |f: fn(i32) -> i32, x| f(f(x));
    println!("apply_twice(square, 3) = {}", apply_twice(|x| x * x, 3));

    // ── Closure that returns a closure ──
    let make_adder = |n| move |x| x + n;
    let add_five = make_adder(5);
    let add_ten = make_adder(10);
    println!("add_five(3) = {}, add_ten(3) = {}", add_five(3), add_ten(3));

    // ── Collect patterns ──
    let words = vec!["hello", "world", "rust"];

    // To Vec
    let upper: Vec<String> = words.iter().map(|w| w.to_uppercase()).collect();
    println!("upper: {upper:?}");

    // To HashMap
    use std::collections::HashMap;
    let char_counts: HashMap<char, usize> = words
        .join("")
        .chars()
        .fold(HashMap::new(), |mut map, c| {
            *map.entry(c).or_insert(0) += 1;
            map
        });
    println!("char counts: {char_counts:?}");
}
