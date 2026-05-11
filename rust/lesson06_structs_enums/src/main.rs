// Lesson 6: Structs and Enums
// Algebraic data types: the backbone of Rust programs.

// ── Tuple struct ──
struct Point(i32, i32);

// ── Unit-like struct (zero fields, useful for traits) ──
struct Empty;

// ── Regular struct ──
struct User {
    username: String,
    email: String,
    active: bool,
    age: u32,
}

// ── Enum with data variants ──
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(u8, u8, u8),
}

// ── Enum as a type (like a discriminated union) ──
enum Shape {
    Circle(f64),
    Rectangle { width: f64, height: f64 },
    Triangle { a: f64, b: f64, c: f64 },
}

fn main() {
    // ── Struct instantiation ──
    let p = Point(10, 20);
    println!("Point: ({}, {})", p.0, p.1);

    // Update (must be mutable)
    let mut user = User {
        username: String::from("rustacean"),
        email: String::from("rust@example.com"),
        active: true,
        age: 25,
    };
    user.age = 26; // field-level mutation
    println!("User {} is {} years old", user.username, user.age);

    // Struct update syntax
    let user2 = User {
        email: String::from("new@example.com"),
        ..user // copy remaining fields from `user`
    };
    println!("Email changed to {}", user2.email);

    // ── Enum usage ──
    let msg = Message::Write(String::from("Hello!"));

    // Pattern match on enum
    match msg {
        Message::Quit => println!("Quitting."),
        Message::Move { x, y } => println!("Move to ({x}, {y})"),
        Message::Write(text) => println!("Text: {text}"),
        Message::ChangeColor(r, g, b) => println!("Color: rgb({r},{g},{b})"),
    }

    // Enum methods (like associated functions)
    let circle = Shape::Circle(5.0);
    println!("Circle area: {:.2}", circle.area());
}

// Method on enum — like a trait impl but for the type itself
impl Shape {
    fn area(&self) -> f64 {
        match self {
            Shape::Circle(r) => std::f64::consts::PI * r * r,
            Shape::Rectangle { width, height } => width * height,
            Shape::Triangle { a, b, c } => {
                let s = (a + b + c) / 2.0;
                (s * (s - a) * (s - b) * (s - c)).sqrt()
            }
        }
    }
}
