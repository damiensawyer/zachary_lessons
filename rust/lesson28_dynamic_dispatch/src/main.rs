// Lesson 28: Dynamic Dispatch and Box<dyn Trait>
// Learn when to use dynamic vs static dispatch

fn main() {
    println!("=== Dynamic Dispatch (Box<dyn Trait>) ===\n");

    // ── Static Dispatch with Generic Types ──
    // The compiler generates code for each concrete type
    
    let animals = [Cat::new("Whiskers"), Dog::new("Buddy")];
    
    for animal in &animals {
        animal.bark();  // Monomorphization - code generated per type
    }

    println!("\n---");

    // ── Dynamic Dispatch with Box<dyn Trait> ──
    // The compiler generates ONE function call, polymorphism at runtime
    
    let mixed_animals: Vec<Box<dyn Pet>> = vec![
        Box::new(Cat::new("Mittens")),
        Box::new(Dog::new("Max")),
        Box::new(Bird::new("Tweety")),  // Different vtable!
    ];

    for animal in &mixed_animals {
        animal.bark();  // Uses trait object vtable lookup
    }

    println!("\n---");

    // ── Dynamic Dispatch with Trait Objects (References) ──
    let animals_ref: Vec<&dyn Pet> = vec![
        &Cat::new("Luna"),
        &Dog::new("Rocky"),
        &Bird::new("Squawk"),
    ];

    for animal in &animals_ref {
        animal.bark();  // Same as Box<dyn Trait> but without heap allocation per item
    }

    println!("\n=== Advanced Patterns ===\n");

    // ── Pattern: Polymorphic Collections (Commented - requires HashMap)
    /*
    use std::collections::HashMap;
    
    type AnimalMap = HashMap<String, Box<dyn Pet>>;  // Trait object in collection
    
    let mut pet_shop = AnimalMap::new();
    pet_shop.insert("dog".to_string(), Box::new(Dog::new("Rex")));
    pet_shop.insert("cat".to_string(), Box::new(Cat::new("Simba")));
    
    for (name, pet) in &pet_shop {
        println!("{}: {}", name, pet.bark());
    }
    */

    // ── Pattern: Trait Objects with Multiple Types (Shapes) ──
    let shapes: Vec<Box<dyn Shape>> = vec![
        Box::new(Circle { radius: 5.0 }),
        Box::new(Rectangle { width: 10.0, height: 20.0 }),
        Box::new(Triangle { base: 3.0, height: 4.0 }),
    ];

    for shape in &shapes {
        println!("Area: {}", shape.area());  // Same function call, different implementations
    }

    // ── Pattern: Converting Between Static and Dynamic Dispatch (Commented)
    /*
    let static_dispatch = Cat::new("Garfield");
    
    // To use with dynamic dispatch:
    let dyn_cat: Box<dyn Pet> = Box::new(static_dispatch);  // Upcast to trait object
    
    // To convert back (requires downcasting):
    if let Some(downcasted) = dyn_cat.downcast_ref::<Cat>() {
        println!("It's a Cat!");
    }
    */

    println!("\n=== Performance Comparison ===\n");
    
    println!("Static Dispatch (Generic Types):");
    println!("  ✓ Faster - no vtable lookup at runtime");
    println!("  ✓ Code generated for each type");
    println!("  ✓ Better optimization opportunities");
    println!("  ✗ Limited to known types at compile time");

    println!("\nDynamic Dispatch (Box<dyn Trait>):");
    println!("  ✓ Flexible - can store any implementing type");
    println!("  ✓ Polymorphism at runtime");
    println!("  ✗ Slight overhead for vtable lookup");
    println!("  ✗ Requires heap allocation (unless using &dyn Trait)");

    // ── Real-World Example: Plugin System (Commented)
    /*
    struct Plugin<T> {
        name: &'static str,
        handler: Box<dyn PluginHandler>,
    }

    impl<T> Plugin<T> {
        fn new(name: &'static str, handler: Box<dyn PluginHandler>) -> Self {
            Plugin { name, handler }
        }
        
        fn process(&self) {
            println!("Plugin {} is processing...", self.name);
            (self.handler)();  // Call the trait method
        }
    }

    fn register_plugin(name: &'static str, plugin: Box<dyn PluginHandler>) -> Plugin<i32> {
        Plugin::new(name, plugin)
    }
    */

    println!("\nDynamic dispatch patterns demonstrated!");
}

// ── Static Dispatch Example (Generic Types) ──
struct Cat {
    name: String,
}

impl Cat {
    fn new(name: &str) -> Self {
        Cat {
            name: name.to_string(),
        }
    }
}

impl Pet for Cat {
    fn bark(&self) {
        println!("{} meows", self.name);
    }
}

struct Dog {
    name: String,
}

impl Dog {
    fn new(name: &str) -> Self {
        Dog {
            name: name.to_string(),
        }
    }
}

impl Pet for Dog {
    fn bark(&self) {
        println!("{} barks", self.name);
    }
}

struct Bird {
    name: String,
}

impl Bird {
    fn new(name: &str) -> Self {
        Bird {
            name: name.to_string(),
        }
    }
}

impl Pet for Bird {
    fn bark(&self) {
        println!("{} chirps", self.name);
    }
}

// ── Dynamic Dispatch with Box<dyn Trait> (Pet trait) ──
trait Pet {
    fn bark(&self);
    
    // You can add more methods here
}

// ── Dynamic Dispatch with Trait Objects (References - Shapes) ──
trait Shape {
    fn area(&self) -> f64;
}

struct Circle {
    radius: f64,
}

impl Shape for Circle {
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Shape for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

struct Triangle {
    base: f64,
    height: f64,
}

impl Shape for Triangle {
    fn area(&self) -> f64 {
        0.5 * self.base * self.height
    }
}

// ── Helper: Downcasting Example (if you have Box<dyn Trait>) - Commented
/*
use std::any::{Any, TypeId};

trait AnyTrait: Any + Send + Sync {
    fn downcast_ref<T: Any>(&self) -> Option<&T> {
        self.downcast_ref()  // From dyn Any trait
    }
    
    fn downcast_mut<T: Any>(&mut self) -> Option<&mut T> {
        self.downcast_mut()  // From dyn Any trait
    }
}

// If your Box<dyn Trait> also implements Any, you can use it for runtime type checks
fn process_boxed(item: &dyn AnyTrait) {
    if let Some(circle_ref) = item.downcast_ref::<Circle>() {
        println!("Got a Circle with radius: {}", circle_ref.radius);
        
        // Mutate the underlying value (only possible through downcast_mut)
        // circle_ref.radius = 10.0;  // Would need &mut
    }
}

// Or use TypeId for simple type checking without Any trait
fn process_by_type_id(item: &dyn AnyTrait) {
    let id = std::any::TypeId::of::<item>();
    
    if id == std::any::TypeId::of::<Circle>() {
        println!("Detected Circle");
    } else if id == std::any::TypeId::of::<Rectangle>() {
        println!("Detected Rectangle");
    }
}
*/
