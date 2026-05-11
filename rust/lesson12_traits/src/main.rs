// Lesson 12: Traits — Rust's Version of Interfaces
// Traits define shared behavior. Like interfaces or typeclasses.

use std::fmt;

// ── Define a trait ──
trait Shape {
    fn area(&self) -> f64;
    fn perimeter(&self) -> f64;
    fn description(&self) -> String {
        // Default implementation (like a default method in Java)
        format!("Shape with area {:.2}", self.area())
    }
}

// ── Implement the trait for a struct ──
struct Circle { radius: f64 }
struct Rectangle { width: f64, height: f64 }

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
    fn perimeter(&self) -> f64 {
        2.0 * std::f64::consts::PI * self.radius
    }
    // Override default description
    fn description(&self) -> String {
        format!("Circle(radius={:.2})", self.radius)
    }
}

impl Shape for Rectangle {
    fn area(&self) -> f64 { self.width * self.height }
    fn perimeter(&self) -> f64 { 2.0 * (self.width + self.height) }
}

// ── Trait bounds on generics ──
fn print_described<T: Shape>(shape: &T) {
    println!("{} → area: {:.2}, perimeter: {:.2}",
             shape.description(), shape.area(), shape.perimeter());
}

// ── Multiple trait bounds ──
fn print_both<T: Shape + fmt::Debug>(shape: &T) {
    println!("{:?}: {}", shape, shape.area());
}

// ── where clause (cleaner for complex bounds) ──
fn process_shape<T>(shape: T)
where
    T: Shape + fmt::Debug + Clone,
{
    let clone = shape.clone();
    println!("Area of clone: {:.2}", clone.area());
}

// ── Trait objects (dynamic dispatch) ──
fn print_all_shapes(shapes: &[&dyn Shape]) {
    for s in shapes {
        println!("  {} → {:.2}", s.description(), s.area());
    }
}

// ── Derive macros (built-in traits) ──
#[derive(Debug, Clone, PartialEq)]
enum Color { Red, Green, Blue }

// Debug is for {:?} formatting
fn main() {
    let circle = Circle { radius: 5.0 };
    println!("{}", circle.description());
    println!("Area: {:.2}", circle.area());

    let rect = Rectangle { width: 10.0, height: 3.0 };
    println!("Area: {:.2}", rect.area());

    // Trait bounds work with generics
    print_described(&circle);
    print_described(&rect);

    // Multiple bounds
    print_both(&circle);

    // Trait objects: heterogeneous collection
    let shapes: Vec<&dyn Shape> = vec![&circle, &rect];
    print_all_shapes(&shapes);

    // PartialEq derive
    println!("Red == Red: {}", Color::Red == Color::Red);
    println!("Red == Green: {}", Color::Red == Color::Green);

    // Clone derive
    let cloned = circle.clone();
    println!("Cloned circle radius: {}", cloned.radius);
}
