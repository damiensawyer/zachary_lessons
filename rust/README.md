# Rust Course: Learn Rust from Scratch 🦀

A comprehensive course to learn Rust programming, covering everything from basics to advanced topics. Each lesson is a standalone example you can compile and run.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installing Rust Toolchain](#installing-rust-toolchain)
  - [Setting Up for Fast Development](#setting-up-for-fast-development)
  - [IDE Setup with VS Code](#ide-setup-with-vs-code)
- [Lessons Overview](#lessons-overview)
- [Additional Resources](#additional-resources)

---

## Getting Started

### Prerequisites

- Basic programming knowledge (any language will do)
- A modern web browser for viewing examples
- ~2GB of disk space

### Installing Rust Toolchain

#### Option 1: Install via rustup (Recommended)

```bash
# Install rustup and latest stable Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Source your shell configuration to load Rust
source "$HOME/.cargo/env"

# Verify installation
rustc --version
cargo --version
```

#### Option 2: Install via Package Manager (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install rustc cargo
```

### Setting Up for Fast Development

Fast compilation is crucial for learning Rust. Follow these steps to optimize your development environment:

#### 1. Use the Latest Stable Toolchain

Rust's toolchain improves constantly. Always stay updated:

```bash
rustup update
rustup default stable
```

#### 2. Configure Cargo for Fast Builds

Create or edit `~/.cargo/config` (or `~/.cargo/config.toml`) with these settings:

```toml
[build]
# Disable debug assertions in release mode, but keep them in dev
# This speeds up builds significantly
rustflags = ["-C", "link-arg=-Wl,-z,muldefs"]

[target.x86_64-unknown-linux-gnu]
rustflags = ["-C", "target-feature=+crt-static"]  # Static linking for faster builds
```

#### 3. Use the `--profile` Flag for Different Build Modes

```bash
# Fast dev build (default) - includes debug info, keeps assertions enabled
cargo build --release --features fast-build 2>/dev/null || cargo build

# Ultra-fast release compilation (for testing final code only)
CARGO_INCREMENTAL=0 RUSTFLAGS="-C link-arg=-Wl,-z,muldefs" cargo build --profile release-fast

# Debug builds for error messages
cargo run
```

#### 4. Use `RUSTFLAGS` Environment Variable

Add this to your `~/.bashrc`, `~/.zshrc`, or equivalent:

```bash
export RUSTFLAGS="-C link-arg=-Wl,-z,muldefs"
export CARGO_INCREMENTAL=0
```

Then reload:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

#### 5. Enable Cargo Cache (Optional but Recommended)

```toml
# Add to ~/.cargo/config.toml
[net]
git-fetch-with-cli = true

[source.crates-io]
replace = "https://github.com/rust-lang/crates.io-index" = "https://fastly-us-edge.cdn.gcr.dev/2024-12-25/crates/index/v1.json"
```

### IDE Setup with VS Code

See the `vscode/settings.json` file for recommended extensions and settings. The recommended setup includes:

- **rust-analyzer**: Intellisense, go-to-definition, refactor support (ESSENTIAL)
- **Better Comments**: Highlight special code patterns
- **Error Lens**: Show errors inline as you type (highly recommended for learning)
- **GitLens**: Git integration and blame annotations

#### Install Recommended Extensions

1. Open VS Code Settings (`Ctrl+,` or `Cmd+,`)
2. Search for extensions to install:
   - `rust-lang.rust-analyzer`
   - `usernamehw.errorlens`
   - `dbaeumer.vscode-eslint` (optional)

#### Configure rust-analyzer for Fast Feedback

Add this to your VS Code settings (`settings.json`):

```jsonc
{
    "[rust]": {
        "editor.defaultFormatter": "rust-lang.rust-analyzer",
        "editor.suggestSelection": "first"
    },
    // Enable error lens if installed
    "rust-analyzer.cargo.buildOnSave": true,
}
```

---

## Lessons Overview

| # | Topic | File | Description |
|---|-------|------|-------------|
| 01 | Hello World | `lesson01_hello_world/` | Your first Rust program |
| 02 | Variables | `lesson02_variables/` | Immutable and mutable variables |
| 03 | Basic Types | `lesson03_basic_types/` | Strings, integers, booleans, chars |
| 04 | Functions | `lesson04_functions/` | Parameters, return values, closures intro |
| 05 | Control Flow | `lesson05_control_flow/` | If/else, match expressions |
| 06 | Structs & Enums | `lesson06_structs_enums/` | Data structures and pattern matching |
| 07 | Methods | `lesson07_methods/` | Adding methods to types with impl blocks |
| 08 | Ownership (Basics) | `lesson08_ownership/` | Rust's ownership system intro |
| 09 | References | `lesson09_references/` | Borrowing, lifetimes basics |
| 10 | Slices | `lesson10_slices/` | Dynamic views into collections |
| 11 | Strings | `lesson11_strings/` | String types: String and &str |
| 12 | Traits | `lesson12_traits/` | Generic behavior, trait bounds |
| 13 | Generics & Bounds | `lesson13_generics_bounds/` | Type parameters and constraints |
| 14 | Collections | `lesson14_collections/` | Vec, HashMap, BTreeMap |
| 15 | Error Handling (Part 1) | `lesson15_error_handling/` | panic!, expect(), unwrap() |
| 16 | Result & Option | `lesson16_result_option/` | Functional error handling patterns |
| 17 | Closures & Captures | `lesson17_closures_captures/` | Anonymous functions and captures |
| 18 | Iterators | `lesson18_iterators/` | Chaining iterator adapters |
| 19 | Smart Pointers | `lesson19_smart_pointers/` | Box, Rc, Arc, RefCell |
| 20 | Modules & Crates | `lesson20_modules_crates/` | Organizing code structure |
| 21 | Testing | `lesson21_testing/` | Unit tests and integration tests |
| 22 | Macros | `lesson22_macros/` | Declarative and procedural macros |
| 23 | Lifetimes | `lesson23_lifetimes/` | Borrow checker lifetime annotations |
| 24 | Concurrency | `lesson24_concurrency/` | Threads, channels, atomics |
| 25 | Final Project | `lesson25_final_project/` | Build a complete application |

---

## How to Run Each Lesson

```bash
# Navigate to a lesson directory
cd /home/damien/code/zachary_lessons/rust/lesson01_hello_world

# Compile and run
cargo build
cargo run

# Or compile with optimizations (slower but faster runtime)
cargo build --release

# Run directly from project root (recommended for quick iteration)
cd lesson01_hello_world/src && cargo run --manifest-path ../Cargo.toml
```

## Additional Resources

### Official Rust Documentation
- [The Rust Book](https://doc.rust-lang.org/book/) - The definitive guide to Rust
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) - Interactive examples
- [Rust Reference](https://doc.rust-lang.org/reference/) - Detailed language reference

### Community Resources
- [Rust Discord Server](https://rust-lang.github.io/rustafarian/links/discord.html) - Real-time help from the community
- [r/rust](https://www.reddit.com/r/rust/) - Reddit community for Rust discussions

### Performance Optimization
- [`cargo-bloat`](https://github.com/sharkdp/cargo-bloat) - Analyze binary size
- [`criterion`](https://crates.io/crates/criterion) - Benchmarking framework
- [`flamegraph`](https://github.com/flamegraph-rs/flamegraph) - Profiling tool

### Fast Compilation Tips
1. **Use `--release` for final testing** - Dev builds are slower but include assertions
2. **Clear cargo cache periodically**: `cargo clean`
3. **Keep your toolchain updated**: `rustup update`
4. **Use VS Code's built-in terminal** - Faster than opening new terminals

---

## Quick Reference Commands

```bash
# Install Rust (one time)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Update toolchain
rustup update

# Create a new project
cargo new my_project && cd my_project

# Build and run
cargo build           # Debug mode
cargo build --release # Release mode (optimized)
cargo run             # Build + run (debug)
cargo run --release   # Build + run (release)

# Test your code
cargo test            # Run all tests
cargo test --test integration_tests  # Specific test file

# Format and lint
cargo clippy          # Catch bugs before they happen
cargo fmt             # Auto-format code

# Generate documentation
cargo doc --open      # Open generated docs in browser
```

---

## License

This course material is provided as-is for educational purposes.
