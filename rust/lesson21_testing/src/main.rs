// Lesson 21: Testing
// Rust has built-in test support. No external framework needed.
//
// Run with: cargo test

// ── Unit tests (in the same file) ──
fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*; // import everything from parent module

    // Basic assertion test
    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
        assert_eq!(add(0, 0), 0);
    }

    // Panic test — expect a panic
    #[test]
    #[should_panic(expected = "division by zero")]
    fn test_div_zero() {
        divide(10, 0).unwrap();
    }

    // Custom messages
    #[test]
    fn test_add_negative() {
        assert!(add(-5, -3) < 0, "sum of negatives should be negative");
    }

    // Test functions that return Result
    #[test]
    fn test_divide_ok() -> Result<(), String> {
        let result = divide(10, 2)?;
        assert_eq!(result, 5);
        Ok(())
    }

    // Test with assertions
    #[test]
    fn test_divide_error() {
        let result = divide(10, 0);
        assert!(result.is_err(), "divide(10, 0) should return Err");
    }
}

// ── Integration tests ──
// (placed in tests/ directory — only public API visible)

fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err("division by zero".to_string())
    } else {
        Ok(a / b)
    }
}

fn greet(name: &str) -> String {
    if name.is_empty() {
        String::from("Hello, stranger!")
    } else {
        format!("Hello, {name}!")
    }
}

#[cfg(test)]
mod greet_tests {
    use super::*;

    #[test]
    fn test_greet_normal() {
        assert_eq!(greet("World"), "Hello, World!");
    }

    #[test]
    fn test_greet_empty() {
        assert_eq!(greet(""), "Hello, stranger!");
    }
}

// ── Doc tests ──
/// Add two numbers together.
///
/// # Examples
///
/// ```
/// assert_eq!(add(2, 3), 5);
/// ```
pub fn doc_add(a: i32, b: i32) -> i32 {
    a + b
}

// Doc tests run `cargo test` too!
