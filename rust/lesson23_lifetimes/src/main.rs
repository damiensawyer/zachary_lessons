// Lesson 23: Lifetimes
// Lifetimes tell the compiler how long references are valid.
// Syntax: 'a, 'b, 'static. The compiler elides (infers) most of the time.

fn main() {
    // ── Lifetime elision — most functions don't need annotations ──
    let result = longest("hello", "world"); // compiler figures it out
    println!("longest: {result}");

    // ── Explicit lifetimes on functions ──
    let string1 = String::from("long string is long");
    let result;
    {
        let string2 = String::from("xyz");
        result = longest_with_announcement(
            string1.as_str(),
            string2.as_str(),
            "[WARNING]",
        );
        // string2 dropped here, but result still borrows it — ERROR!
    }
    // println!("Result: {result}"); // would fail: string2 dropped

    // Fix: result must not outlive all inputs
    let string1 = String::from("long string is long");
    let s2;
    {
        let string2 = String::from("xyz");
        s2 = longest_with_announcement(
            string1.as_str(),
            string2.as_str(),
            "[ANNOUNCE]",
        );
    }
    println!("Announcement result: {s2}");

    // ── Structs with references need lifetime annotations ──
    let text = String::from("Rust is great!");
    let summary = Summary {
        title: "Rust".into(),
        body: &text, // borrows text
    };
    println!("Summary: {} — {}", summary.title, summary.body);
    // text must outlive summary

    // ── Lifetime elision rules (3 rules the compiler applies) ──
    // 1. Each elided lifetime becomes a different parameter
    // 2. If there's exactly one input lifetime, it's assigned to all outputs
    // 3. If there are multiple input lifetimes but one is &self, self is assigned

    // Example: impl method — self's lifetime is elided
    let name = String::from("Alice");
    let user = User { name: &name };
    println!("User: {}", user.greeting());
}

// The compiler infers this as: fn longest<'a>(x: &'a str, y: &'a str) -> &'a str
fn longest(x: &str, y: &str) -> &str {
    if x.len() > y.len() { x } else { y }
}

// Both references must live at least as long as the return value
fn longest_with_announcement<'a>(
    x: &'a str,
    y: &'a str,
    ann: &'a str,
) -> String {
    format!("{ann} Longest string is: {x}")
}

struct Summary<'a> {
    title: String,
    body: &'a str, // borrows — must live long enough
}

impl<'a> Summary<'a> {
    fn greeting(&self) -> &str {
        &self.title
    }
}

struct User<'a> {
    name: &'a str,
}

impl<'a> User<'a> {
    fn greeting(&self) -> &str {
        self.name
    }
}
