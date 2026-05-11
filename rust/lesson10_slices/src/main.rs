// Lesson 10: Slices and String Handling
// Slices are Rust's way of borrowing a contiguous portion of data.

fn main() {
    // ── String slices (&str) — a borrow into a String ──
    let s = String::from("hello world");
    let hello = &s[0..5]; // slice from byte 0 to 4
    println!("{hello}"); // "hello" — no allocation!
    println!("Full: {}", s);

    // Slices auto-coerce
    let s2 = "hello world"; // &str is a string literal (static lifetime)
    let world = &s2[6..]; // from index 6 to end
    println!("{world}");

    // ── String methods using slices ──
    let mut greeting = String::from("Hello");
    greeting.push_str(", world!"); // append
    println!("{greeting}");

    greeting.insert(5, ' '); // insert at position
    println!("{greeting}");

    // Pop last char
    greeting.pop();
    println!("{greeting}");

    // Truncate
    greeting.truncate(5);
    println!("{greeting}");

    // ── Slice patterns in functions ──
    let scores = [100, 90, 80, 70, 60];
    let high_scores = &scores[..3];
    let low_scores = &scores[2..];
    println!("high: {:?}, low: {:?}", high_scores, low_scores);

    // Split at a specific index
    let mid = scores.len() / 2;
    let (left, right) = scores.split_at(mid);
    println!("left: {:?}, right: {:?}", left, right);

    // ── Splitting strings ──
    let sentence = "rust is awesome and powerful";
    for word in sentence.split_whitespace() {
        println!("  word: '{word}'");
    }

    // Split by comma
    let csv = "alpha,beta,gamma";
    for part in csv.split(',') {
        println!("  csv part: '{part}'");
    }

    // ── Bytes and chars ──
    let utf8 = "hello 🌍";
    println!("Chars: {:?}", utf8.chars().collect::<Vec<_>>());
    println!("Bytes: {:?}", utf8.as_bytes());
    println!("Char count: {}", utf8.chars().count());
    println!("Byte count: {}", utf8.len());

    // ── Slice syntax for vectors ──
    let mut vec = vec![1, 2, 3, 4, 5];
    let first_two: &mut Vec<i32> = &mut vec[..2];
    first_two[0] = 99;
    println!("vec after mutating first two: {vec:?}");

    // ── Empty slices ──
    let empty: &[i32] = &[];
    println!("Empty slice is empty: {}", empty.is_empty());
}
