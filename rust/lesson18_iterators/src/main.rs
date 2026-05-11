// Lesson 18: Iterators — The Heart of Rust Iteration
// Everything iterable implements the Iterator trait.

use std::iter;

fn main() {
    // ── Creating iterators ──
    let nums = vec![1, 2, 3, 4, 5];

    // IntoIterator (consuming)
    let v: Vec<i32> = nums.clone().into_iter().filter(|x| x > 2).collect();
    println!("consuming filter: {:?}", v);

    // Iterator (borrowed)
    let sum: i32 = nums.iter().sum();
    println!("sum: {sum}");

    // ── Iterator chain ──
    let result: Vec<i32> = nums.iter()
        .map(|x| x * 2)
        .filter(|x| *x > 4)
        .skip(1)
        .take(2)
        .collect();
    println!("chained: {:?}", result); // [6, 8]

    // ── enumerate — get index ──
    for (i, val) in nums.iter().enumerate() {
        println!("  [{i}] = {val}");
    }

    // ── zip — pair up two iterators ──
    let names = vec!["Alice", "Bob", "Carol"];
    let ages = vec![30, 25, 35];
    for (name, age) in names.iter().zip(ages.iter()) {
        println!("  {name} is {age}");
    }

    // ── Iterator adaptors ──
    let data = vec![10, 20, 30, 40, 50];

    // rev — reverse
    println!("rev: {:?}", data.iter().rev().collect::<Vec<_>>());

    // peekable — look ahead
    let mut peek = data.iter().peekable();
    println!("next: {}", peek.next().unwrap());
    println!("peek: {:?}", peek.peek());
    println!("next: {}", peek.next().unwrap());

    // cycle — repeat forever (use with take!)
    let pattern: Vec<i32> = [1, 2].iter().cloned().cycle().take(6).collect();
    println!("cycle: {:?}", pattern); // [1, 2, 1, 2, 1, 2]

    // ── Folding and reducing ──
    let product: i32 = nums.iter().product();
    println!("product: {product}");

    let max_val = nums.iter().max().unwrap();
    let min_val = nums.iter().min().unwrap();
    println!("max: {max_val}, min: {min_val}");

    // fold — ultimate generalization
    let factorial: i32 = (1..=5).fold(1, |acc, x| acc * x);
    println!("5! = {factorial}");

    // ── Iterator traits ──
    // Collect needs IntoIterator + Sized
    // Iterator is defined by: next() -> Option<Self::Item>
    // All other methods have default implementations!

    // ── Custom iterator ──
    struct Counter {
        count: usize,
        max: usize,
    }

    impl Counter {
        fn new(max: usize) -> Self {
            Self { count: 0, max }
        }
    }

    impl Iterator for Counter {
        type Item = usize;
        fn next(&mut self) -> Option<Self::Item> {
            if self.count < self.max {
                let val = self.count;
                self.count += 1;
                Some(val)
            } else {
                None
            }
        }
    }

    let c = Counter::new(5);
    println!("Custom counter: {:?}", c.collect::<Vec<_>>()); // [0, 1, 2, 3, 4]

    // ── Infinite iterators ──
    let naturals = iter::successors(Some(1), |&n| Some(n + 1));
    let first_five: Vec<i32> = naturals.take(5).collect();
    println!("first 5 naturals: {first_five:?}");
}
