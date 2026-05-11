// Lesson 20: Modules and Crates
// Organize code into modules, control visibility with pub.

mod frontend {
    pub mod ui {
        pub fn render() {
            println!("  Rendering UI...");
        }

        fn internal_helper() {
            println!("  Internal helper (not public)");
        }

        pub fn button(label: &str) {
            internal_helper();
            println!("  Button: {label}");
        }
    }

    pub mod layout {
        pub fn grid(cols: usize) {
            println!("  Grid: {cols} columns");
        }
    }
}

mod backend {
    pub mod database {
        pub struct Connection {
            pub url: String,
        }

        impl Connection {
            pub fn new(url: &str) -> Self {
                Self { url: url.to_string() }
            }
            pub fn connect(&self) {
                println!("  Connected to {}", self.url);
            }
        }
    }

    mod auth {
        pub fn login(username: &str) -> String {
            format!("Logged in as {username}")
        }
    }
}

// ── Use declarations (import) ──
use std::fs::File;
use std::io::{self, Write};
use std::path::Path;

// ── Use with renaming ──
use std::collections::HashMap as Map;

fn main() {
    // Access public modules
    frontend::ui::render();
    frontend::ui::button("Click me!");
    frontend::layout::grid(4);

    // Nested module access
    let conn = backend::database::Connection::new("localhost:5432");
    conn.connect();

    // Auth is accessible if pub, but it's in a private module
    // backend::auth::login("user"); // ERROR: auth is private

    // ── Use statements ──
    let _path = Path::new("test.txt");

    let mut file = File::create("test_output.txt").unwrap();
    write!(file, "Hello from use!").unwrap();

    // HashMap via alias
    let my_map: Map<&str, i32> = Map::new();
    println!("Empty map has {} entries", my_map.len());

    // ── Re-exporting with pub use ──
    // pub use crate::foo::Bar; // makes Bar available at current scope
    // (use in a real project for facade patterns)

    // ── Crate structure ──
    // In Cargo:
    //   src/
    //     main.rs  (binary crate root)
    //     lib.rs   (library crate root)
    //     mod1.rs  (module)
    //   Cargo.toml
    println!("\nModule system: organized, private by default!");
}
