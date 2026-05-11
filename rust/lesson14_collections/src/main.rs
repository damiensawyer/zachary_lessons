// Lesson 14: Collections
// Vec, HashMap, HashSet — the standard collection types.

use std::collections::HashMap;

fn main() {
    // ── Vec<T>: growable array ──
    let mut vec = Vec::new();
    vec.push(1);
    vec.push(2);
    vec.push(3);
    println!("vec: {:?}", vec);

    // Common patterns
    let mut numbers = vec![10, 20, 30, 40, 50];
    println!("pop: {}", numbers.pop().unwrap()); // 50
    println!("len: {}", numbers.len());

    // Iteration
    for n in &numbers {
        print!("{n} ");
    }
    println!();

    // Mutable iteration
    for n in &mut numbers {
        *n *= 2;
    }
    println!("doubled: {:?}", numbers);

    // Slicing
    let slice = &numbers[1..3];
    println!("slice: {:?}", slice);

    // ── HashMap<K, V>: associative array ──
    let mut scores = HashMap::new();
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
    scores.insert("Red".to_string(), 30); // &str auto-converts

    // Lookup
    if let Some(score) = scores.get("Blue") {
        println!("Blue score: {score}");
    }

    // Insert or update
    scores.entry(String::from("Green")).or_insert(75);
    scores.entry(String::from("Green")).and_modify(|s| *s += 25);
    println!("Green score (updated): {}", scores["Green"]);

    // Iterate
    for (team, score) in &scores {
        println!("  {team}: {score}");
    }

    // Build from iterator
    let words = vec!["apple", "banana", "apple", "cherry", "banana", "apple"];
    let mut freq: HashMap<&str, usize> = HashMap::new();
    for word in words {
        *freq.entry(word).or_insert(0) += 1;
    }
    println!("Word frequency: {freq:?}");

    // ── HashSet: unique items ──
    use std::collections::HashSet;
    let mut set = HashSet::new();
    set.insert(1);
    set.insert(2);
    set.insert(3);
    set.insert(2); // duplicate, ignored
    println!("Set size: {}", set.len());
    println!("Contains 2: {}", set.contains(2));

    // Set operations
    let set_a: HashSet<i32> = vec![1, 2, 3, 4].into_iter().collect();
    let set_b: HashSet<i32> = vec![3, 4, 5, 6].into_iter().collect();
    println!("Union: {:?}", set_a.union(&set_b).collect::<Vec<_>>());
    println!("Intersection: {:?}", set_a.intersection(&set_b).collect::<Vec<_>>());
    println!("Difference: {:?}", set_a.difference(&set_b).collect::<Vec<_>>());

    // ── Struct of vectors ──
    let mut students: HashMap<String, Vec<String>> = HashMap::new();
    students.entry("Math".to_string()).or_default().push("Alice".into());
    students.entry("Math".to_string()).or_default().push("Bob".into());
    students.entry("CS".to_string()).or_default().push("Alice".into());
    students.entry("CS".to_string()).or_default().push("Carol".into());

    for (course, names) in &students {
        println!("  {course}: {:?}", names);
    }
}
