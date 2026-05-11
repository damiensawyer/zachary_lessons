// Lesson 19: Smart Pointers
// Box<T>, Rc<T>, Arc<T> — pointers with extra capabilities.

use std::rc::Rc;
use std::sync::Arc;
use std::sync::Mutex;

fn main() {
    // ── Box<T>: heap allocation, single owner ──
    let b = Box::new(42);
    println!("Boxed: {}", *b); // deref to get value

    // Recursive types MUST use Box (infinite size without it)
    #[derive(Debug)]
    enum List {
        Cons(i32, Box<List>),
        Nil,
    }
    let linked_list = List::Cons(1, Box::new(List::Cons(2, Box::new(List::Nil))));
    println!("Linked list: {linked_list:?}");

    // ── Rc<T>: reference counting (single-threaded) ──
    let a = Rc::new(String::from("hello"));
    let b = Rc::clone(&a); // increments ref count
    println!("a: {}, b: {}", a, b);
    println!("ref count: {}", Rc::strong_count(&a));

    // When last Rc drops, value is freed
    {
        let c = Rc::clone(&a);
        println!("In scope, count: {}", Rc::strong_count(&a));
    }
    println!("After scope, count: {}", Rc::strong_count(&a));

    // ── Arc<T>: atomically reference counted (thread-safe) ──
    let shared = Arc::new(vec![1, 2, 3]);
    let clone1 = Arc::clone(&shared);
    let clone2 = Arc::clone(&shared);
    println!("Arc count: {}", Arc::strong_count(&shared));

    // ── RefCell<T>: interior mutability (borrow checking at runtime) ──
    use std::cell::RefCell;
    let value = RefCell::new(5);
    {
        let mut borrow = value.borrow_mut();
        *borrow += 10;
    }
    println!("RefCell: {}", value.borrow());

    // Double borrow panics at runtime (not compile time!)
    // {
    //     let r1 = value.borrow();
    //     let r2 = value.borrow_mut(); // panics at runtime
    // }

    // ── Combining Rc + RefCell for shared mutable state ──
    #[derive(Debug)]
    struct Node {
        value: i32,
        children: RefCell<Vec<Rc<Node>>>,
    }

    let root = Rc::new(Node {
        value: 1,
        children: RefCell::new(vec![]),
    });

    let child1 = Rc::new(Node {
        value: 2,
        children: RefCell::new(vec![]),
    });
    let child2 = Rc::new(Node {
        value: 3,
        children: RefCell::new(vec![]),
    });

    root.children.borrow_mut().push(Rc::clone(&child1));
    root.children.borrow_mut().push(Rc::clone(&child2));

    println!("Tree: {root:?}");
    println!("Children of root: {}", root.children.borrow().len());
}
