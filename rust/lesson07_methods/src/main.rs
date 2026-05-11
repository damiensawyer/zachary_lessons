// Lesson 7: Methods and Impl Blocks
// Associate functions with types.

struct Rectangle {
    width: f64,
    height: f64,
}

struct Circle {
    radius: f64,
}

// Methods take `self`, `&self`, or `&mut self`
impl Rectangle {
    // Associated function (not a method — no `self`)
    fn new(width: f64, height: f64) -> Self {
        Self { width, height }
    }

    // Immutable borrow — can read but not modify
    fn area(&self) -> f64 {
        self.width * self.height
    }

    // Mutable borrow — can modify
    fn scale(&mut self, factor: f64) {
        self.width *= factor;
        self.height *= factor;
    }

    // Returns a boolean, takes &self
    fn is_square(&self) -> bool {
        (self.width - self.height).abs() < f64::EPSILON
    }
}

impl Circle {
    fn new(radius: f64) -> Self {
        Self { radius }
    }
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

// Multi-impl blocks: you can split impl across files/modules
impl Rectangle {
    fn contains(&self, point: (f64, f64)) -> bool {
        let (x, y) = point;
        x >= 0.0 && x <= self.width && y >= 0.0 && y <= self.height
    }
}

// Using `Self` — shorthand for "this type"
impl Rectangle {
    fn from_square(side: f64) -> Self {
        Self::new(side, side)
    }
}

fn main() {
    // Create with new()
    let mut rect = Rectangle::new(10.0, 5.0);
    println!("Area: {:.2}", rect.area());
    println!("Is square: {}", rect.is_square());

    // Mutable method
    rect.scale(2.0);
    println!("After 2x scale, area: {:.2}", rect.area());

    // Contains check
    println!("Contains (3, 2): {}", rect.contains((3.0, 2.0)));
    println!("Contains (12, 2): {}", rect.contains((12.0, 2.0)));

    // Circle
    let circle = Circle::new(5.0);
    println!("Circle area: {:.2}", circle.area());

    // Method chaining with builder pattern (advanced but common)
    let result = process_data("hello");
    println!("Processed: {result}");
}

// Example of fluent/builder-style API
fn process_data(input: &str) -> String {
    input.to_uppercase().trim().to_string()
}
