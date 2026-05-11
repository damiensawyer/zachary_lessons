// Lesson 27: Custom Error Types and the From Trait
// Learn how to create proper error types for production code

use std::fmt;
use std::error::Error as StdError;

fn main() {
    println!("=== Custom Error Types ===\n");

    // ── Example 1: Simple Enum-Based Errors (Recommended) ──
    // This is the most common pattern for custom errors
    
    match perform_division(10, 0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {:?}", e),
    }

    // ── Example 2: Custom Error with Display Implementation ──
    let custom_error = MyCustomError::InvalidInput("Value must be positive".to_string());
    
    match do_something_with_number(5) {
        Ok(v) => println!("Success! Got value: {}", v),
        Err(e) => {
            // Use format! to include the error message in a user-friendly way
            let msg = if let Some(msg) = e.as_ref() {
                format!("Error: {}", msg)
            } else {
                "An unexpected error occurred".to_string()
            };
            println!("{}", msg);
        }
    }

    // ── Example 3: Using the ? Operator with Custom Errors ──
    match parse_config_file("config.txt") {
        Ok(value) => println!("Parsed value: {}", value),
        Err(e) => eprintln!("Failed to parse config: {}", e),
    }

    // ── Example 4: Error Chain with Context (std::error::Error trait) ──
    let io_error = create_io_context();
    
    match do_file_operation(&io_error) {
        Ok(_) => println!("File operation succeeded"),
        Err(e) => {
            // Check if the error has a chain of causes
            if let Some(source) = e.source() {
                println!("Error: {}\nCaused by: {}", e, source);
            } else {
                println!("Error: {}", e);
            }
        }
    }

    println!("\n=== Advanced Patterns ===\n");

    // ── Example 5: Multiple Error Variants in One Enum ──
    match handle_multiple_error_cases() {
        Ok(v) => println!("Result: {}", v),
        Err(e) => println!("Error variant: {:?}", e.error_kind()),
    }

    // ── Example 6: Converting Other Types to Your Error (From Trait) ──
    match convert_string_to_i32("not a number") {
        Ok(n) => println!("Converted successfully: {}", n),
        Err(e) => println!("Conversion failed: {}", e),
    }

    // ── Example 7: Using anyhow for Simpler Error Handling (optional crate) ──
    /*
    use anyhow::{Result, Context};
    
    fn process_data() -> Result<i32> {
        let data = read_file("input.txt")?;  // Automatically handles errors
        parse_and_validate(data)?;           // Chain with ? operator
        Ok(compute_result(data))
    }
    */

    println!("\nCustom error types demonstrated!");
}

// ── Example 1: Basic Enum Error Type (No From Trait) ──
#[derive(Debug, PartialEq)]
enum DivisionError {
    ZeroDivision,
    NegativeInput(i32),
}

fn perform_division(numerator: i32, denominator: i32) -> Result<i32, DivisionError> {
    if denominator == 0 {
        Err(DivisionError::ZeroDivision)
    } else if numerator < 0 {
        Err(DivisionError::NegativeInput(numerator))
    } else {
        Ok(numerator / denominator)
    }
}

// ── Example 2: Custom Error with Display Trait ──
#[derive(Debug)]
enum MyCustomError {
    InvalidInput(String),
    NetworkFailure,
    DatabaseError(String),
}

impl fmt::Display for MyCustomError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MyCustomError::InvalidInput(msg) => write!(f, "Invalid input: {}", msg),
            MyCustomError::NetworkFailure => write!(f, "Network connection failed"),
            MyCustomError::DatabaseError(msg) => write!(f, "Database error: {}", msg),
        }
    }
}

fn do_something_with_number(n: i32) -> Result<i32, Box<MyCustomError>> {
    if n < 0 {
        Err(Box::new(MyCustomError::InvalidInput(
            "Numbers must be non-negative".to_string(),
        )))
    } else if n > 100 {
        Err(Box::new(MyCustomError::DatabaseError(
            "Value too large for database".to_string(),
        )))
    } else {
        Ok(n * 2)
    }
}

// ── Example 3: Using the ? Operator with Custom Errors ──
/// Returns an error if file doesn't exist or can't be read
fn parse_config_file(path: &str) -> Result<i32, MyCustomError> {
    // Simulate reading and parsing a config file
    if path == "nonexistent.txt" {
        return Err(MyCustomError::InvalidInput(
            "Config file not found".to_string(),
        ));
    }
    
    // Parse the content (simulated)
    match std::fs::read_to_string(path) {
        Ok(content) => {
            let value: i32 = content.trim().parse()
                .map_err(|_| MyCustomError::InvalidInput(
                    "Failed to parse config as integer".to_string(),
                ))?;
            Ok(value * 10)
        }
        Err(e) => Err(MyCustomError::DatabaseError(format!(
            "Failed to read file: {}", e
        ))),
    }
}

// ── Example 4: Error Chain (std::error::Error trait) ──
#[derive(Debug)]
struct DatabaseConnectionError {
    message: String,
}

impl std::fmt::Display for DatabaseConnectionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Database connection failed: {}", self.message)
    }
}

impl StdError for DatabaseConnectionError {}  // Implements Error trait

fn create_io_context() -> Result<(), Box<dyn std::error::Error>> {
    let io_error = std::io::Error::new(
        std::io::ErrorKind::Other,
        "Could not open database connection",
    );
    
    Err(Box::new(DatabaseConnectionError {
        message: format!("IO error: {}", io_error),
    }))
}

fn do_file_operation(io_err: &Result<(), Box<dyn StdError>>) -> Result<String, Box<dyn StdError>> {
    match io_err {
        Ok(()) => {
            // Would perform file operations here
            Err(Box::new(DatabaseConnectionError {
                message: "Unexpected success but still failed".to_string(),
            }))
        }
        Err(e) => Err(Box::new(DatabaseConnectionError {
            message: format!("IO error during operation: {}", e),
        })),
    }
}

// ── Example 5: Error Enum with Multiple Variants ──
#[derive(Debug)]
enum ValidationError {
    EmptyInput,
    InvalidFormat(String),
    OutOfRange(i32),
    NetworkError(String),
    DatabaseError(Box<dyn StdError>),
}

impl fmt::Display for ValidationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ValidationError::EmptyInput => write!(f, "Input cannot be empty"),
            ValidationError::InvalidFormat(s) => write!(f, "Invalid format: {}", s),
            ValidationError::OutOfRange(v) => write!(f, "Value {} out of range", v),
            ValidationError::NetworkError(e) => write!(f, "Network error: {}", e),
            ValidationError::DatabaseError(e) => write!(f, "Database error: {}", e),
        }
    }
}

impl StdError for ValidationError {}

fn handle_multiple_error_cases() -> Result<i32, ValidationError> {
    // Simulate processing with multiple potential failure points
    
    if let Err(_) = std::io::stdin().read_line(&mut String::new()) {
        return Err(ValidationError::NetworkError(
            "Failed to read input".to_string(),
        ));
    }
    
    let value: i32 = "not a number"
        .parse()
        .map_err(|_| ValidationError::InvalidFormat("Expected integer".to_string()))?;
    
    if value < 0 || value > 100 {
        return Err(ValidationError::OutOfRange(value));
    }
    
    Ok(value)
}

fn handle_multiple_error_cases_simple() -> Result<i32, Box<dyn StdError>> {
    // Simpler version using anyhow-like pattern
    let _ = std::fs::read_to_string("input.txt");  // Would fail if file doesn't exist
    
    Err(Box::new(ValidationError::EmptyInput))
}

// ── Example 6: Converting Other Types (From Trait) ──
#[derive(Debug)]
enum ConversionError {
    ParseFailure(String),
    Overflow,
    InvalidType(String),
}

impl fmt::Display for ConversionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ConversionError::ParseFailure(msg) => write!(f, "Parse failure: {}", msg),
            ConversionError::Overflow => write!(f, "Numeric overflow occurred"),
            ConversionError::InvalidType(t) => write!(f, "Cannot convert to type: {}", t),
        }
    }
}

impl StdError for ConversionError {}

// Implement From<String> to automatically convert parse failures
impl From<std::num::ParseIntError> for ConversionError {
    fn from(err: std::num::ParseIntError) -> Self {
        // This is what happens when you use the ? operator with a String that can't be parsed as i32
        ConversionError::ParseFailure(format!("Failed to parse integer: {}", err))
    }
}

// Implement From<&str> for string slices (common case)
impl From<&str> for ConversionError {
    fn from(s: &str) -> Self {
        ConversionError::InvalidType(format!("Cannot convert '{}' to i32", s))
    }
}

fn convert_string_to_i32(input: &str) -> Result<i32, Box<dyn StdError>> {
    // The ? operator will use From<str> if we implement it above
    let number = input.parse::<i32>()?;  // Uses our From implementation
    
    Ok(number * 100)
}

/*
// ── Alternative: Using anyhow crate for simpler error handling
// Add to Cargo.toml: [dependencies] anyhow = "1.0"

use anyhow::{Result, Context};

fn read_file(path: &str) -> Result<String> {
    std::fs::read_to_string(path).with_context(|| format!("Failed to read {}", path))
}

fn parse_and_validate(content: String) -> Result<i32> {
    let number: i32 = content.trim().parse()
        .context("Failed to parse as integer")?;
    
    if number < 0 {
        Err(anyhow!("Number must be non-negative"))
    } else {
        Ok(number)
    }
}

fn process_data() -> Result<i32> {
    let content = read_file("input.txt")?;
    parse_and_validate(content)?;
    
    // If any operation above fails, the error context chain is preserved
    Ok(42)
}
*/
