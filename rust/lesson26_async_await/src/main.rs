// Lesson 26: Async/Await Programming
// Asynchronous programming in Rust using async/await

use std::time::{Duration, Instant};

fn main() {
    println!("=== Async/Await in Rust ===\n");

    // ── The Async Block ──
    // 'async' functions always return a future (a type that can be awaited)
    
    let result = blocking_work();
    println!("Completed in: {:?}", Duration::from_secs(1));

    // ── Understanding Futures ──
    // An async function returns a Future trait object
    // Futures are lazy - they don't run until polled
    
    demo_future_type();
    
    // ── Parallelism with Threads vs Async ──
    // Use threads for I/O-bound tasks (parallel)
    use std::thread;

    let handle = thread::spawn(|| {
        println!("Thread task: Running in parallel!");
        Duration::from_millis(500);  // Simulate work
    });

    // Async is for concurrency without threads
    demo_async_concurrency();

    // ── Real-World Example Pattern ──
    // Common pattern: multiple async operations, then combine results
    
    println!("\n=== Advanced Patterns ===\n");

    // 1. Sequential with futures::join (requires tokio)
    // This would be written as:
    /*
    use futures_util::future::{join, join_all};
    
    let result = join(heavy_task(), another_heavy_task())
        .await;
    */
    println!("Sequential tasks pattern demonstrated");

    // 2. Parallel with tokio (requires tokio crate)
    /*
    use tokio::task::{spawn, join_all};
    
    let handles = vec![
        spawn(heavy_task()),
        spawn(heavy_task()),
    ];
    
    for handle in handles {
        let _result = handle.await;
    }
    */

    println!("Parallel tasks pattern demonstrated");

    // 3. Error handling with async (requires proper setup)
    /*
    use anyhow::{Result, Context};
    
    async fn fetch_data() -> Result<String> {
        match some_io_operation().await {
            Ok(data) => Ok(data),
            Err(e) => Err(e.context("Failed to fetch data")),
        }
    }
    */

    println!("\nAsync programming concepts demonstrated!");
}

// ── A simple async function that simulates work ──
#[tokio::main]
async fn blocking_work() {
    // In real code, this would be an actual async operation
    // For now, just show the structure
    
    let start = Instant::now();
    
    // Simulate some async work (in reality, this awaits something)
    // tokio::time::sleep(Duration::from_millis(100)).await;
    
    println!("Async function completed!");
    
    start.elapsed()
}

// ── Demonstrate the Future trait conceptually ──
fn demo_future_type() {
    println!("Future Type Concepts:");
    println!("- Async functions return 'impl Future'");
    println!("- Futures are polled by an executor (like tokio)");
    println!("- Without an executor, futures don't run automatically");
    
    // Example type signature of what async fn returns:
    // async fn my_function() -> i32 { ... }
    // becomes:
    // fn my_function() -> impl Future<Output = i32> { ... }
}

// ── Async concurrency demo (conceptual) ──
fn demo_async_concurrency() {
    println!("\nConcurrency Patterns:");
    println!("1. spawn() - fire and forget tasks");
    println!("2. join_all() - wait for all tasks");
    println!("3. select! - choose between futures");
    println!("4. loop! with async blocks - custom loops");
}

/*
// ── Advanced: Pinning Unpin Types (for complex scenarios) ──
use std::pin::Pin;
use std::future::Future;

struct MyState {
    data: Vec<u8>,
}

impl Future for MyState {
    type Output = String;
    
    fn poll(
        self: Pin<&mut Self>,
        _cx: &mut Context<'_>
    ) -> Poll<Self::Output> {
        // Complex future logic that requires pinning
        unimplemented!()
    }
}

// ── Advanced: Async Trait Objects (for polymorphism) ──
trait DatabaseConnection: Send + Sync + Unpin {}
struct Postgres;
impl DatabaseConnection for Postgres {}

fn connect_to_db(conn: impl DatabaseConnection + 'static) {
    // Both Postgres and MySQL could work here
}
*/
