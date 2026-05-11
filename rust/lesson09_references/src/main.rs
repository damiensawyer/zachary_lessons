// Lesson 9: References and Borrowing
// One rule of borrowing: either ONE mutable reference OR many immutable ones.

fn main() {
    // ── Immutable references ──
    let s = String::from("hello world");
    let len = calculate_length(&s); // borrow s, don't own it
    println!("length of '{s}' is {len}");
    println!("s is still valid: {s}");

    // Multiple immutable references are fine
    let word = String::from("rust");
    let first = &word[0..1];
    let second = &word[0..1]; // overlapping borrows are OK if immutable
    println!("{first} {second}");

    // ── Mutable references (exclusive!) ──
    let mut data = vec![1, 2, 3];
    add_item(&mut data, 4);
    println!("After adding 4: {data:?}");

    // Can't have & and &mut at the same time
    // let r1 = &data;   // borrow
    // let r2 = &mut data; // ERROR! can't mutate while borrowed
    // println!("{} {}", r1[0], r2[0]);

    // But scopes fix this:
    let r1 = &data;
    println!("first element: {}", r1[0]); // r1 used, then dropped
    let r2 = &mut data;
    r2.push(99); // now we can mutate
    println!("after mutable: {data:?}");

    // ── Dangling references prevented by the compiler ──
    // let r;
    // {
    //     let x = String::from("temp");
    //     r = &x; // ERROR: x would be dropped here, r would dangle
    // }

    // ── Slices (borrowed references to contiguous sequences) ──
    let text = String::from("hello world");
    let word = first_word_slice(&text); // returns &str (a slice of the String)
    println!("first word: {word}");

    // Slices on arrays/vectors
    let nums = [1, 2, 3, 4, 5];
    let slice: &[i32] = &nums[1..4]; // slice from index 1 to 3 (exclusive)
    println!("slice: {:?}", slice);

    // ── Struct with references (lifetime annotations needed) ──
    let name = String::from("Alice");
    let user = UserRef { name: &name };
    println!("User: {}", user.name);

    // Can't return a reference to a local variable
    // fn broken() -> &str {
    //     let s = String::from("hello");
    //     &s // ERROR! s is dropped at end of function
    // }
}

fn calculate_length(s: &String) -> usize {
    s.len() // borrow s, return length, don't take ownership
}

fn add_item(v: &mut Vec<i32>) {
    v.push(42);
}

fn first_word_slice(s: &str) -> &str {
    let bytes = s.as_bytes();
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[..i];
        }
    }
    s
}

struct UserRef<'a> {
    name: &'a str, // lifetime annotation: name lives as long as 'a
}
