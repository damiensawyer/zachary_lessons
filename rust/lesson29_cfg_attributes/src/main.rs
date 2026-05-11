// Lesson 29: Conditional Compilation with #[cfg] Attributes
// Learn how to compile different code paths based on conditions

fn main() {
    println!("=== Conditional Compilation ===\n");

    // Basic cfg Attribute Usage
    
    if feature_enabled("feature-a") {
        use_feature_a();
    } else {
        use_feature_b();
    }

    // Feature Flags (Cargo.toml) Example:
    
    let debug_mode = cfg!(debug_assertions);
    
    if debug_mode {
        println!("Debug mode enabled - assertions active");
    } else {
        println!("Release mode - optimized build");
    }

    println!("\n=== Advanced Patterns ===\n");

    // Platform-Specific Code Example:
    
    let os_name = std::env::var("OS").unwrap_or_else(|_| "unknown".to_string());
    println!("Detected OS: {}", os_name);

    // Feature-Gated Dependencies Example:
    
    println!("Feature flags available via #[cfg] attributes");
    println!("Debug assertions active: {}", cfg!(debug_assertions));
    
    if cfg!(target_os == "linux") {
        println!("Running on Linux");
    } else if cfg!(target_os == "windows") {
        println!("Running on Windows");
    }

    println!("\nConditional compilation patterns demonstrated!");
}

// Helper Functions to Demonstrate Different Code Paths:

#[inline(never)]
fn feature_a_code() {
    println!("Feature A code path executed");
}

#[inline(never)]
fn feature_b_code() {
    println!("Feature B code path executed");
}

fn use_feature_a() {
    feature_a_code();
}

fn use_feature_b() {
    feature_b_code();
}

// Platform-Specific Code Examples (commented out):

/*
#[cfg(target_os = "linux")]
fn linux_specific_code() {
    println!("  - Using /etc/hosts");
    println!("  - Using apt/dpkg package manager");
    println!("  - Using systemd for services");
}

#[cfg(target_os = "windows")]
fn windows_specific_code() {
    println!("  - Using Windows Registry");
    println!("  - Using PowerShell/CMD");
    println!("  - Using Windows Services");
}

#[cfg(target_os = "macos")]
fn macos_specific_code() {
    println!("  - Using /etc/hosts");
    println!("  - Using Homebrew package manager");
    println!("  - Using launchd for services");
}
*/

// Debug vs Release Configuration:

#[cfg(debug_assertions)]
fn debug_only_function() -> String {
    "Debug mode active".to_string()
}

#[cfg(not(debug_assertions))]
fn debug_only_function() -> String {
    "Release mode - debug assertions disabled".to_string()
}

// Test-Specific Code (Only Compiled in Tests):

#[cfg(test)]
mod test_specific_code {
    
    #[test]
    fn test_debug_assertions_active() {
        assert!(true);  // Debug assertions would catch this if it were false
        
        println!("Running in test mode with debug assertions");
    }

    #[cfg(target_os = "linux")]
    #[test]
    fn test_linux_specific() {
        // Linux-specific tests only compile on Linux
        assert!(true);
    }

    #[test]
    fn common_test_for_all_platforms() {
        let x = 42;
        assert_eq!(x, 42);
    }
}

// cfg! Macro Examples:

/*
fn platform_info() -> String {
    format!(
        "Target: {} - OS: {}",
        std::env!("CARGO_CFG_TARGET_ARCH"),
        std::env!("CARGO_CFG_TARGET_OS")
    )
}

fn build_mode_info() -> String {
    if cfg!(debug_assertions) {
        "Debug".to_string()
    } else {
        "Release".to_string()
    }
}
*/

