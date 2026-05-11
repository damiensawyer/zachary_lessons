// Lesson 24: Concurrency
// Threads, message passing, shared state — no data races guaranteed.

use std::sync::{mpsc, Arc, Mutex};
use std::thread;
use std::time::Duration;

fn main() {
    // ── Threads — spawn and join ──
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("Spawned thread: {i}");
            thread::sleep(Duration::from_millis(50));
        }
    });

    for i in 1..5 {
        println!("Main thread: {i}");
        thread::sleep(Duration::from_millis(50));
    }

    handle.join().unwrap(); // wait for thread to finish
    println!("Thread finished!");

    // ── Move closures for thread safety ──
    let data = String::from("hello from main");
    let handle = thread::spawn(move || {
        println!("Thread got: {data}");
        data // ownership transferred
    });
    let owned = handle.join().unwrap(); // get value back
    println!("Back in main: {owned}");

    // ── Message passing with channels (mpsc) ──
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        let msgs = vec!["ping", "pong", "done"];
        for msg in msgs {
            tx.send(msg.to_string()).unwrap();
            thread::sleep(Duration::from_millis(100));
        }
    });

    for received in rx {
        println!("Got: {received}");
    }
    println!("Channel closed!");

    // ── Shared state with Arc<Mutex<T>> ──
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Counter: {}", *counter.lock().unwrap());

    // ── Interior mutability patterns ──
    use std::cell::Cell;
    let cell = Cell::new(0);
    cell.set(42);
    println!("Cell: {}", cell.get());

    // ── Scoped threads (Rust 1.63+) — no Arc needed! ──
    let data = vec![1, 2, 3, 4, 5];
    let mut results = vec![0; 5];

    thread::scope(|s| {
        for (i, item) in data.iter().enumerate() {
            s.spawn(move || {
                results[i] = item * 2;
            });
        }
    });

    println!("Scoped results: {results:?}");
}
