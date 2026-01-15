# Ownership Patterns

Patterns for managing ownership and borrowing in Klar.

## The Ownership Model

Every value in Klar has exactly one owner. When the owner goes out of scope, the value is dropped (resources freed).

```klar
fn example() {
    let data = create_data()   // data owns the value
    process(data)              // ownership transferred
    // data no longer valid here
}
```

## Pattern 1: Transfer Ownership

When a function needs to own its data (store it, modify it exclusively):

```klar
struct Database {
    connections: List[Connection]
}

impl Database {
    /// Adds a connection to the pool.
    /// Takes ownership - caller cannot use connection after this.
    fn add_connection(self: &mut Database, conn: Connection) {
        self.connections.push(conn)
    }
}

// Usage
let conn = create_connection(config)
db.add_connection(conn)  // conn moved into db
// conn no longer valid
```

## Pattern 2: Borrow Immutably

When a function only needs to read data:

```klar
/// Calculates statistics from data.
/// Borrows immutably - caller retains ownership.
fn calculate_stats(data: &[i32]) -> Stats {
    Stats {
        sum: data.iter().sum(),
        count: data.len(),
        avg: data.iter().sum() as f64 / data.len() as f64
    }
}

// Usage
let numbers = [1, 2, 3, 4, 5]
let stats = calculate_stats(&numbers)
// numbers still valid and usable
println("Sum: {stats.sum}, Numbers: {numbers}")
```

## Pattern 3: Borrow Mutably

When a function needs to modify data in place:

```klar
/// Sorts the slice in place.
/// Borrows mutably - exclusive access during call.
fn sort_in_place(data: &mut [i32]) {
    // ... sorting logic ...
}

// Usage
let numbers = [5, 2, 8, 1, 9]
sort_in_place(&mut numbers)
// numbers is now sorted
```

## Pattern 4: Clone When Needed

When you need a copy to preserve the original:

```klar
fn process_copy(original: &Config) -> Config {
    let copy = original.clone()
    // Modify copy without affecting original
    copy.name = "Modified"
    copy
}
```

**When to clone:**
- You need to preserve the original
- Ownership model doesn't allow borrowing
- Data is small and cheap to copy

**When NOT to clone:**
- Large data structures (expensive)
- Just to "make the compiler happy" (rethink design)

## Pattern 5: Builder Pattern

Return ownership at each step for fluent APIs:

```klar
struct RequestBuilder {
    method: string
    url: string
    headers: Map[string, string]
    body: ?string
}

impl RequestBuilder {
    fn new() -> RequestBuilder {
        RequestBuilder {
            method: "GET",
            url: "",
            headers: Map.new(),
            body: none
        }
    }

    fn method(self: RequestBuilder, m: string) -> RequestBuilder {
        RequestBuilder { method: m, ..self }
    }

    fn url(self: RequestBuilder, u: string) -> RequestBuilder {
        RequestBuilder { url: u, ..self }
    }

    fn header(self: RequestBuilder, key: string, value: string) -> RequestBuilder {
        let headers = self.headers
        headers.insert(key, value)
        RequestBuilder { headers: headers, ..self }
    }

    fn body(self: RequestBuilder, b: string) -> RequestBuilder {
        RequestBuilder { body: Some(b), ..self }
    }

    fn build(self: RequestBuilder) -> Request {
        Request {
            method: self.method,
            url: self.url,
            headers: self.headers,
            body: self.body
        }
    }
}

// Usage - ownership flows through chain
let request = RequestBuilder.new()
    .method("POST")
    .url("https://api.example.com")
    .header("Content-Type", "application/json")
    .body("{\"key\": \"value\"}")
    .build()
```

## Pattern 6: Interior Mutability

When you need mutation through shared references:

```klar
struct Counter {
    value: Cell[i32]  // Interior mutability
}

impl Counter {
    fn new() -> Counter {
        Counter { value: Cell.new(0) }
    }

    fn increment(self: &Counter) {
        let current = self.value.get()
        self.value.set(current + 1)
    }

    fn get(self: &Counter) -> i32 {
        self.value.get()
    }
}

// Usage - can mutate through &Counter
let counter = Counter.new()
let r1 = &counter
let r2 = &counter
r1.increment()  // OK despite multiple borrows
r2.increment()
```

**Use interior mutability when:**
- Shared ownership requires mutation (e.g., Rc + RefCell)
- Caching/memoization in otherwise immutable types
- Concurrent data structures

## Pattern 7: Indices Instead of References

Since Klar doesn't allow stored references, use indices:

```klar
// Instead of storing references to nodes
struct Graph {
    nodes: List[Node]
    edges: List[(usize, usize)]  // Indices into nodes
}

impl Graph {
    fn add_edge(self: &mut Graph, from: usize, to: usize) {
        assert(from < self.nodes.len())
        assert(to < self.nodes.len())
        self.edges.push((from, to))
    }

    fn get_node(self: &Graph, index: usize) -> &Node {
        &self.nodes[index]
    }
}
```

## Pattern 8: Shared Ownership with Rc

When multiple owners genuinely need the same data:

```klar
struct TreeNode {
    value: i32
    children: List[Rc[TreeNode]]
}

fn build_tree() -> Rc[TreeNode] {
    let shared_leaf = Rc.new(TreeNode {
        value: 42,
        children: List.new()
    })

    // Multiple parents can share the same child
    let parent1 = Rc.new(TreeNode {
        value: 1,
        children: [shared_leaf.clone()]
    })

    let parent2 = Rc.new(TreeNode {
        value: 2,
        children: [shared_leaf.clone()]
    })

    // shared_leaf now has 3 owners (original + 2 clones)
    // Dropped when all owners are dropped
}
```

**Warning:** Avoid reference cycles with Rc - use Weak for back-references.

## Anti-Patterns to Avoid

### 1. Unnecessary Cloning
```klar
// BAD: Cloning just to satisfy borrow checker
fn process(data: Data) {
    let copy = data.clone()  // Unnecessary!
    use_data(&copy)
    use_data(&copy)
}

// GOOD: Borrow instead
fn process(data: &Data) {
    use_data(data)
    use_data(data)
}
```

### 2. Rc When Ownership Works
```klar
// BAD: Using Rc unnecessarily
let data = Rc.new(MyStruct { ... })

// GOOD: Just own it
let data = MyStruct { ... }
```

### 3. RefCell Without Need
```klar
// BAD: RefCell when &mut works
struct Counter { value: RefCell[i32] }

// GOOD: Just use &mut
struct Counter { value: i32 }
fn increment(self: &mut Counter) { self.value += 1 }
```
