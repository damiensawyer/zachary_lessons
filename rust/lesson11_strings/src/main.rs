// Lesson 11: Strings Deep Dive
// Rust has two string types: &str (borrowed, zero-cost) and String (owned, heap).

fn main() {
    // ── String literals: &str, compile-time, static ──
    let literal: &str = "hello"; // lives for the entire program
    println!("Literal: {literal}");

    // ── Owned String: heap-allocated, growable ──
    let mut owned = String::from("hello");
    owned.push_str(" world");
    owned.push('!');
    println!("Owned: {owned}");

    // ── String formatting ──
    let name = "Rust";
    let year = 2010;
    let version = 1.75;
    let msg = format!("{name} (est. {year}), version {version:.2}");
    println!("{msg}");

    // ── From various types ──
    let from_char: String = 'a'.into();
    let from_bytes = String::from_utf8(vec![72, 101, 108, 108, 111]).unwrap();
    println!("from bytes: {from_bytes}");

    // ── String operations ──
    let a = String::from("hello");
    let b = String::from(" world");

    // + operator (consumes left side — moves ownership!)
    // let c = a + &b; // a is moved, b must be &b (borrowed)
    // println!("a + b = {}", c);

    // push_str is non-consuming
    let mut c = a.clone();
    c.push_str(&b);
    println!("push_str: {c}");

    // ── Indexing strings — Rust doesn't allow it (unicode!) ──
    // let first = s[0]; // ERROR — can't index into String

    // Use chars() or bytes() instead
    let greeting = "Привет"; // "Hello" in Russian
    let first_char = greeting.chars().next().unwrap();
    println!("First char: {first_char}");
    println!("First 3 chars: {}", greeting.chars().take(3).collect::<String>());

    // ── Contains, starts_with, ends_with ──
    let text = "Rust is great";
    println!("Contains 'Rust': {}", text.contains("Rust"));
    println!("Starts with 'Rust': {}", text.starts_with("Rust"));
    println!("Ends with 'great': {}", text.ends_with("great"));

    // ── Trim variants ──
    let spaced = "  hello  ";
    println!("Trimmed: '{}'", spaced.trim());
    println!("Trimmed left: '{}'", spaced.trim_start());
    println!("Trimmed right: '{}'", spaced.trim_end());

    // ── Case conversion ──
    println!("UPPER: {}", text.to_uppercase());
    println!("lower: {}", text.to_lowercase());

    // ── String vs &str in function signatures ──
    // Prefer &str — it accepts both &String and &str
    process_string(&owned); // works because &String coerces to &str

    // ── Unicode properties ──
    let emoji = "🦀🦀🦀";
    println!("Emojis: {}", emoji.chars().count()); // 3, not 9 bytes
    println!("Bytes: {}", emoji.len()); // 12 bytes (4 per crab emoji)
}

// Accepting &str is idiomatic — works with both String and &str
fn process_string(s: &str) {
    println!("Processing: {s} ({} bytes)", s.len());
}
