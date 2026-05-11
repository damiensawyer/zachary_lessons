// Lesson 13: Generics and Trait Bounds
// Generic types and functions — write once, use with any type.

// ── Generic struct ──
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }

    // Generic method — T is already bound by the struct
    fn distance_from_origin(&self) -> f64
    where
        T: std::ops::Add<Output = T> + std::ops::Mul<Output = T> + Copy + From<i32>,
    {
        let zero: T = From::from(0);
        let two: T = From::from(2);
        let x_sq = self.x * self.x;
        let y_sq = self.y * self.y;
        // For this demo, we only fully work with f64
        // In real code, you'd use num_traits crate for numeric generics
        unimplemented!("Only f64 works without num_traits")
    }
}

// Special impl for f64
impl Point<f64> {
    fn euclidean_distance(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }
}

// ── Generic function ──
fn first_element<T>(slice: &[T]) -> &T {
    &slice[0]
}

// ── Trait bounds as generic constraints ──
fn print_double<T: std::fmt::Display + std::ops::Mul<Output = T, Result = std::ops::MulErr>>(
    value: &T,
) {
    println!("Value: {value}");
}

// ── where clause (cleaner syntax) ──
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    for item in &list[1..] {
        if item > largest {
            largest = item;
        }
    }
    largest
}

// ── Multiple trait bounds with + ──
fn notify(item: &impl std::fmt::Display) {
    println!("Breaking news: {item}");
}

// Equivalent with where clause (more readable for long bounds):
fn notify_where<T: std::fmt::Display>(item: &T) {
    println!("Breaking news: {item}");
}

// ── NewType pattern (type-safe wrappers) ──
struct Meters(f64);
struct Seconds(f64);

impl Meters {
    fn meters(&self) -> f64 { self.0 }
}

// Different types, can't mix accidentally
fn calculate_speed(dist: Meters, time: Seconds) -> f64 {
    dist.meters() / time.0
}

fn main() {
    // Generic struct with different types
    let int_point = Point::new(1, 2);
    let float_point = Point::new(1.0, 4.0);
    let dist = float_point.euclidean_distance();
    println!("Distance: {:.2}", dist);

    // Generic function
    let nums = vec![34, 50, 25, 100, 65];
    println!("Largest: {}", largest(&nums));

    let chars = vec!['y', 'm', 'a', 'q'];
    println!("Largest char: {}", largest(&chars));

    // Trait objects via impl trait
    notify(&42);
    notify("hello world");
    notify_where(3.14);
}
