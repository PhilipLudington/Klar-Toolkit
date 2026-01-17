---
globs: ["**/*.kl"]
---

# API Design Rules

## Function Parameters

**A1**: Maximum 4 parameters. Use config structs for more:

```klar
// BAD
fn create_window(title: string, x: i32, y: i32, w: i32, h: i32, fs: bool)

// GOOD
struct WindowConfig {
    title: string
    x: i32
    y: i32
    width: i32
    height: i32
    fullscreen: bool
}

const WINDOW_CONFIG_DEFAULT: WindowConfig = WindowConfig {
    title: "Untitled"
    x: 100
    y: 100
    width: 800
    height: 600
    fullscreen: false
}

fn create_window(config: WindowConfig) -> Window { ... }
```

## Method Receivers

```klar
impl Player {
    // Read-only access
    fn get_health(self: &Player) -> i32 {
        return self.health
    }

    // Mutable access
    fn take_damage(self: &mut Player, amount: i32) {
        self.health = max(0, self.health - amount)
    }

    // Consumes self
    fn into_corpse(self: Player) -> Corpse {
        return Corpse { name: self.name, position: self.position }
    }
}
```

## Return Types

- Return owned values by default
- Return `&T` only for accessors into internal state
- Return `Result[T, E]` for fallible operations
- Always use explicit `return` statements

## Trait Design

**A2**: One capability per trait:

```klar
// GOOD: Focused
trait Readable {
    fn read(self: &mut Self, buf: &mut [u8]) -> Result[usize, IoError]
}

trait Writable {
    fn write(self: &mut Self, data: &[u8]) -> Result[usize, IoError]
}

// BAD: Kitchen sink
trait Stream { fn read(); fn write(); fn seek(); fn flush(); }
```

Provide default implementations where sensible.

## Generic Functions

Use trait bounds to constrain generic types:

```klar
// Single trait bound
fn max[T: Ordered](a: T, b: T) -> T {
    if a > b {
        return a
    }
    return b
}

// Multiple trait bounds
fn print_sorted[T: Ordered + Printable](items: List[T]) {
    let sorted: List[T] = sort(items)
    for item in sorted {
        item.print()
    }
}

// Where clause for complex bounds
fn merge[K, V](a: Map[K, V], b: Map[K, V]) -> Map[K, V]
where
    K: Hashable + Eq
    V: Clone
{
    // Implementation
}
```

## Generic Types

Define generic structs and enums with type parameters:

```klar
// Generic struct
struct Pair[A, B] {
    first: A
    second: B
}

// Generic enum
enum Option[T] {
    Some(T)
    None
}

enum Result[T, E] {
    Ok(T)
    Err(E)
}

// Usage with explicit type parameters
let pair: Pair[i32, string] = Pair { first: 42, second: "hello" }
let maybe: Option[i32] = Some(42)
```

## Trait Implementation

Use the `impl Type: Trait` syntax:

```klar
// Implement for concrete type
impl Point: Ordered {
    fn compare(self, other: Point) -> Ordering {
        if self.x < other.x {
            return Ordering.Less
        } else if self.x > other.x {
            return Ordering.Greater
        }
        return Ordering.Equal
    }
}

// Implement for generic type
impl List[T]: Iterator {
    type Item = T
    fn next(self: &mut Self) -> ?T { ... }
}
```

## Builtin Traits

Use Klar's builtin traits for common operations:

| Trait | Purpose | Example |
|-------|---------|---------|
| `Eq` | Equality comparison | `fn equals[T: Eq](a: T, b: T) -> bool` |
| `Ordered` | Ordering comparison | `fn max[T: Ordered](a: T, b: T) -> T` |
| `Clone` | Explicit copying | `fn duplicate[T: Clone](v: T) -> (T, T)` |
| `Drop` | Custom cleanup | `impl Handle: Drop { fn drop(...) }` |

Prefer concrete types in public APIs when types are known.

## Visibility

Private by default. Only expose what's necessary:

```klar
module http_client

pub struct Client { ... }      // Public
pub fn create() -> Client      // Public

struct Pool { ... }            // Private
fn manage_pool(p: &mut Pool)   // Private
```

## Documentation

Document all public items:

```klar
/// Creates a new player with the given name.
///
/// # Arguments
/// * `name` - Display name (1-32 chars)
///
/// # Returns
/// New Player, or error if name invalid.
///
/// # Example
/// ```
/// let player: Result[Player, Error] = create_player("Alice")
/// ```
pub fn create_player(name: string) -> Result[Player, Error] { ... }
```
