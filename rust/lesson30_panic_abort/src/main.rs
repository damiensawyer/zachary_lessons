// Lesson 30: Panic vs Abort - Understanding Rust's Failure Modes
// Learn when and how to use panic!() vs std::process::abort()

fn main() {
    println!("=== Panic vs Abort ===\n");

    // What's the Difference?
    
    println!("panic!: ");
    println!("  - Unwinds the stack (if unwinding is enabled)");
    println!("  - Calls destructors for dropped values");
    println!("  - Can be caught with catch_unwind");
    println!("  - Prints a panic message to stderr");
    println!();

    println!("abort(): ");
    println!("  - Immediately terminates the process (no unwinding)");
    println!("  - Skips destructors");
    println!("  - Cannot be caught");
    println!("  - Typically used for FFI boundaries and critical failures");
    println!();

    // When to Use Each (Examples):
    
    panic!("This will panic (if unwinding is enabled)!");
}

/*
// Example: Recovering from Errors vs Fatal Failures:

#[derive(Debug)]
struct Config {
    port: u16,
    host: String,
}

impl Config {
    fn load() -> Result<Self, Box<dyn std::error::Error>> {
        let port = std::fs::read_to_string("config.txt")?;
        
        let parsed_port: u16 = port.trim().parse()?;
        
        Ok(Config {
            port: parsed_port,
            host: "localhost".to_string(),
        })
    }

    fn validate(&self) -> Result<(), Box<dyn std::error::Error>> {
        if self.port == 0 {
            panic!("Port must not be zero!");
        }
        
        if self.port > 65535 {
            return Err("Invalid port number".into());
        }

        Ok(())
    }
}

// Example: When to Abort vs Panic (Detailed):

fn handle_ffi_call() -> Result<i32, Box<dyn std::error::Error>> {
    let result = unsafe {
        ffi_function()?
    };
    
    Ok(result)
}

fn critical_system_failure() -> ! {
    std::process::abort();  // No unwinding - just crash immediately
}

// Example: Using catch_unwind to Recover from Panics (Detailed):

use std::panic::{catch_unwind, AssertUnwindSafe};

fn potentially_panic_function() -> Result<i32, i32> {
    match catch_unwind(AssertUnwindSafe(|| {
        42 / if false { 0 } else { 1 };
    })) {
        Ok(value) => Ok(value),
        Err(_) => Err(42),
    }
}

// Example: Graceful Shutdown vs Hard Crash (Detailed):

fn graceful_shutdown() -> ! {
    println!("Initiating graceful shutdown...");
    
    drop(temporary_resources);
    
    std::process::exit(0)  // Exit with success code
}

fn critical_error() -> ! {
    eprintln!("Critical error - cannot continue operation");
    
    std::process::abort();
}

// Example: Abort in FFI Context (Crucial!):

extern "C" {
    fn external_function() -> i32;
}

fn call_external_library() -> Result<i32, Box<dyn std::error::Error>> {
    let result = unsafe {
        let res = external_function();
        
        if res < 0 {
            return Err("External call failed".into());
        }
        
        Ok(res)
    };
    
    result
}

fn handle_external_crash() -> ! {
    std::process::abort();
}

// Example: Abort for Security Failures (Detailed):

fn verify_user_input(input: &str) -> Result<String, Box<dyn std::error::Error>> {
    if input.is_empty() {
        panic!("Empty input");
        
        // Or use abort for maximum security:
        // std::process::abort();
    }
    
    Ok(input.to_uppercase())
}

fn check_sql_injection(query: &str) -> Result<String, Box<dyn std::error::Error>> {
    if query.contains("DROP TABLE") || query.contains("--") {
        eprintln!("Security violation detected");
        std::process::abort();  // Don't let attacker continue
    }
    
    Ok(query.to_string())
}

// Example: Abort for Data Corruption Detection (Detailed):

fn verify_data_integrity(data: &[u8]) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    if calculate_checksum(data) != expected_checksum {
        eprintln!("Data corruption detected!");
        
        std::abort();  // Don't continue with corrupted data
        
        Ok(data.to_vec())
    } else {
        Ok(data.to_vec())
    }
}

fn calculate_checksum(data: &[u8]) -> u32 {
    let mut sum = 0;
    for byte in data {
        sum ^= *byte as u32;
    }
    sum
}

fn expected_checksum() -> u32 {
    0xDEADBEEF
}

// Example: Abort vs Exit with Code (Detailed):

/*
fn handle_fatal_error() -> ! {
    std::process::abort();  // Crash immediately (exit code 128 + signal)
}

fn handle_recoverable_failure(code: i32) -> ! {
    std::process::exit(code);
}

// Example: Using Abort for Security:

fn verify_signature(data: &[u8]) -> Result<(), Box<dyn std::error::Error>> {
    if !verify_data_integrity(data) {
        eprintln!("Security violation detected - terminating");
        
        std::process::abort();  // Don't let attacker continue
    }
    
    Ok(())
}

fn verify_data_integrity(data: &[u8]) -> bool {
    data.len() > 0 && data[0] == b'SIG'
}
*/

// Example: Abort for Resource Exhaustion (Detailed):

fn handle_memory_exhaustion() -> ! {
    eprintln!("Cannot allocate memory - system is out of resources");
    
    std::process::abort();
}

// Example: Controlled Panic with Context Preservation (Detailed):

use std::panic::{catch_unwind, AssertUnwindSafe};

struct OperationContext {
    id: String,
    data: Vec<u8>,
}

impl OperationContext {
    fn execute(&self) -> Result<i32, Box<dyn std::error::Error>> {
        let result = catch_unwind(AssertUnwindSafe(|| {
            self.calculate()
        }));

        match result {
            Ok(value) => Ok(value),
            Err(_) => {
                eprintln!("Operation {} failed unexpectedly", self.id);
                
                log_failure(self.id.clone());
                
                Err("Internal operation failure".into())
            }
        }
    }

    fn calculate(&self) -> i32 {
        if self.data.is_empty() || !self.data.iter().any(|&x| x > 0) {
            panic!("Invalid data for calculation");
        }
        
        self.data.iter().sum::<i32>()
    }
}

fn log_failure(id: String) {
    println!("[LOG] Failure recorded for {}", id);
}

// Example: Abort for Critical Resource Exhaustion (Detailed):

/*
struct ResourceManager {
    memory_blocks: Vec<u8>,
    files: Vec<String>,
}

impl ResourceManager {
    fn allocate(&mut self, size: usize) -> Result<&[u8], Box<dyn std::error::Error>> {
        let block = if self.memory_blocks.len() + size > 1024 * 1024 {
            eprintln!("Memory allocation failed: system is out of resources");
            std::process::abort();
        } else {
            &mut self.memory_blocks[..]
        };
        
        Ok(block)
    }
}

// Example: Abort for Security Failures (Don't Leak Information):

fn validate_password(password: &str) -> Result<String, Box<dyn std::error::Error>> {
    if password.is_empty() {
        panic!("Empty input");  // Prevent timing attacks
        
        // Or abort for maximum security:
        // std::process::abort();
    }
    
    Ok(password.to_uppercase())
}

// Example: Abort in Network Services (Critical):

fn handle_client_request(request: &str) -> Result<String, Box<dyn std::error::Error>> {
    if !request.starts_with("GET ") && !request.starts_with("POST ") {
        eprintln!("Invalid HTTP method - potential attack");
        
        std::process::abort();
    }
    
    Ok(String::from("OK"))
}

// Example: Using Abort vs Exit (Detailed Comparison):

/*
fn demonstrate_exit_codes() {
    eprintln!("Exit codes demonstrate different failure modes:");
    eprintln!("- Exit(0): Success");
    eprintln!("- Exit(n): Custom error code");
    eprintln!("- Abort(): Signal-based crash (exit 128 + signal)");
    
    std::process::exit(0);   // Normal exit - success
    std::process::exit(1);   // General error
    std::process::exit(2);   // Invalid argument
    
    // Or just let the OS handle it
    // std::process::abort();
}

// Example: Abort for Data Corruption (Critical Systems):

fn verify_checksum(data: &[u8]) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    let calculated = calculate_checksum(data);
    
    if calculated != 0xDEADBEEF {
        eprintln!("CRITICAL: Data corruption detected!");
        
        // Don't try to recover - just crash immediately
        std::abort();
        
        Ok(data.to_vec())  // Never reached due to abort()
    } else {
        Ok(data.to_vec())
    }
}

// Example: Abort vs Panic Summary Table (Commented):

/*
| Scenario                              | Use      | Reason                                |
| -------------------------------------| -------- | -------------------------------------|
| Logic error in debug code            | panic!   | Catch during development              |
| Invalid user input                   | panic!   | Help developers fix the bug          |
| Data validation failure              | Err      | Recoverable, expected                 |
| FFI call failure                     | abort()  | Undefined behavior with panic        |
| Security violation                   | abort()  | Don't let attacker continue          |
| Memory exhaustion                    | abort()  | Can't recover                        |
| File not found                       | Err      | Recoverable                          |
| Database connection lost             | Err      | Retry possible                       |
| Cryptographic verification fails     | abort()  | Security-critical                     */

*/

