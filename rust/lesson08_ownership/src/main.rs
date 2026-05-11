// Lesson 8: Ownership — Rust's Killer Feature
// "A value can have exactly one owner at a time."
// Three rules: ownership, borrowing, lifetimes. Start with ownership.

fn main() {
    // ── Ownership ──
    let s1 = String::from("hello");
    let s2 = s1.clone(); // Clone creates a deep copy
    println!("s1: {}, s2: {}", s1, s2); // Both valid

    // Without clone — s1 is *moved* to s3
    let s3 = s1; // s1 is now invalid
    // println!("s1: {}", s1); // ERROR! use of moved value

    println!("s3: {}", s3); // Only s3 is valid

    // Types that implement Copy don't move — they copy
    let x = 5; // i32 implements Copy
    let y = x; // copy, not move
    println!("x: {}, y: {}", x, y); // Both still valid!

    // ── Functions and ownership ──
    let word = String::from("rust");
    let owned = take_ownership(word); // word moved into function
    println!("owned back: {owned}"); // function returned it

    // borrow instead of move
    let msg = String::from("borrowed!");
    print_borrowed(&msg); // &msg borrows, doesn't move
    println!("still mine: {}", msg);

    // ── The stack vs the heap ──
    // Stack: Copy types (i32, bool, char, f64, &str, tuples of Copy types)
    // Heap: String, Vec<T>, Box<T>, etc. (need explicit clone/move)

    // ── Debug with derive ──
    #[derive(Debug, Clone)]
    struct Person {
        name: String,
        age: u32,
    }

    let alice = Person { name: "Alice".into(), age: 30 };
    let bob = alice; // Person doesn't implement Copy → move
    // println!("alice: {:?}", alice); // ERROR! moved

    println!("bob: {:?}", bob);

    // But we can derive Copy for simple structs
    #[derive(Debug, Copy, Clone)]
    struct Point2D {
        x: f64,
        y: f64,
    }
    let p = Point2D { x: 1.0, y: 2.0 };
    let q = p; // Copy!
    println!("p: {:?}, q: {:?}", p, q);
}

fn take_ownership(s: String) -> String {
    println!("Got: {s}");
    s // returned, ownership goes back
}

fn print_borrowed(s: &str) {
    println!("Borrowed: {s}");
}
