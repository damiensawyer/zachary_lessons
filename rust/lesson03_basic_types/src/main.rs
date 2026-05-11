// Lesson 3: Basic Types
// Rust is statically typed with strong inference.

fn main() {
    // ── Integer types ──
    let a: i32 = 42;       // signed 32-bit
    let b: u32 = 42;       // unsigned 32-bit
    let c: u8 = 255;       // unsigned 8-bit
    let d: i8 = -128;      // signed 8-bit
    let e: usize = 1_000;  // pointer-sized (arena-dependent)
    println!("i32: {a}, u32: {b}, u8: {c}, i8: {d}, usize: {e}");

    // ── Floating-point ──
    let pi: f64 = 3.14159265;
    let e_f: f32 = 2.718;
    println!("pi = {pi}, e = {e_f}");

    // ── Boolean ──
    let is_rust_great = true;
    let is_easier_than_c = false;
    println!("{is_rust_great}, {is_easier_than_c}");

    // ── Character (Unicode scalar, always 4 bytes) ──
    let heart: char = '❤';
    let emoji: char = '🦀'; // Rust's crab!
    println!("{heart} {emoji}");

    // ── Type inference ──
    let inferred = 42;      // i32
    let inferred_f = 3.14;  // f64
    println!("inferred: {inferred}, {inferred_f}");

    // ── Casting (explicit, never implicit) ──
    let i: i32 = 100;
    let u: u16 = i as u16; // explicit cast required
    println!("i32 {i} as u16 = {u}");

    // ── Tuple types ──
    let point: (f64, f64) = (3.0, 4.0);
    println!("point = {:?}", point);
    println!("x = {}, y = {}", point.0, point.1);

    // ── Array types (fixed size, stack-allocated) ──
    let primes: [u32; 5] = [2, 3, 5, 7, 11];
    println!("primes = {primes:?}");
    let zeros = [0i32; 100]; // 100 zeros
    println!("zeros array len = {}", zeros.len());

    // ── Unit of measure (no unit type needed in print) ──
    println!("Types are checked at compile time. No runtime overhead!");
}
