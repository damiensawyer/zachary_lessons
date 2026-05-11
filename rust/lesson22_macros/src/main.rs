// Lesson 22: Macros
// Macros generate code at compile time. Two kinds: declarative and procedural.

// ── Declarative macros (macro_rules!) ──
// The ! after the name is the convention

#[macro_export]
macro_rules! log {
    // Pattern: name!(pattern => body)
    (info: $msg:expr) => {
        println!("[INFO] {}", $msg);
    };
    (warn: $msg:expr) => {
        println!("[WARN] {}", $msg);
    };
    (error: $msg:expr) => {
        eprintln!("[ERROR] {}", $msg);
    };
    // Variadic: repeat with $(...)*
    ($($arg:expr),* $(,)?) => {
        println!("{:?}", vec![$($arg),*]);
    };
}

// ── A useful macro: dbg! ──
// Rust provides dbg!() built-in — prints file:line and value

// ── Repetition syntax: $(x),* means "zero or more x, comma-separated" ──
macro_rules! vec_of_strings {
    ($($s:expr),* $(,)?) => {
        vec![$($s.to_string()),*]
    };
}

// ── Attribute-style proc macro (simplified — real ones need proc_macro crate) ──

fn main() {
    // Use our macro
    log!(info: "Starting program");
    log!(warn: "Low disk space");
    log!(error: "Connection failed");
    log!("multiple", "args", "are", "collected");

    // dbg! — debug print with location
    let x = 42;
    let y = dbg!(x * 2); // prints: main.rs:XX: x * 2 = 84
    println!("y = {y}");

    // ── Derive macros (built-in) ──
    #[derive(Debug, Clone, PartialEq)]
    struct Point {
        x: i32,
        y: i32,
    }

    let p = Point { x: 1, y: 2 };
    println!("p = {p:?}");

    // ─= Copy the macro_rules pattern ──
    macro_rules! create_fn {
        ($name:ident) => {
            fn $name() {
                println!("Called {}", stringify!($name));
            }
        };
    }

    create_fn!(hello);
    create_fn!(goodbye);

    hello();
    goodbye();

    // ── Expression fragments ──
    macro_rules! assert_not_zero {
        ($val:expr) => {
            let temp = $val;
            assert_ne!(temp, 0, "{temp} should not be zero");
        };
    }

    assert_not_zero!(42);
    // assert_not_zero!(0); // would panic

    // ── Hygiene ──
    // Macro variables don't leak into outer scope
    let temp = String::from("outer");
    log!(info: "using temp");
    // temp from macro doesn't conflict
    println!("outer temp: {temp}");
}
