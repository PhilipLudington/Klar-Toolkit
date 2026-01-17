---
globs: ["**/*.kl"]
---

# Traits Rules

## Trait Definition

Define focused traits with clear purposes:

```klar
// GOOD: Single-purpose trait
trait Ordered {
    fn compare(self, other: Self) -> Ordering
}

trait Clone {
    fn clone(self) -> Self
}

// BAD: Kitchen-sink trait
trait Entity {
    fn serialize(self)
    fn deserialize(data: string)
    fn validate(self)
    fn display(self)
    fn hash(self)
}
```

## Trait Implementation

Use the `impl Type: Trait` syntax:

```klar
// Implement trait for concrete type
impl Point: Ordered {
    fn compare(self, other: Point) -> Ordering {
        let self_dist: f64 = self.x * self.x + self.y * self.y
        let other_dist: f64 = other.x * other.x + other.y * other.y
        if self_dist < other_dist {
            return Ordering.Less
        } else if self_dist > other_dist {
            return Ordering.Greater
        }
        return Ordering.Equal
    }
}
```

## Default Implementations

Provide defaults for methods that can be derived:

```klar
trait Printable {
    fn to_string(self) -> string

    // Default implementation
    fn print(self) {
        println(self.to_string())
    }
}

// Implementation can override default
impl User: Printable {
    fn to_string(self) -> string {
        return "User({self.name})"
    }

    // Uses default print() implementation
}
```

## Trait Bounds

Constrain generic types with trait bounds:

```klar
// Single bound
fn max[T: Ordered](a: T, b: T) -> T {
    if a.compare(b) is Ordering.Greater {
        return a
    }
    return b
}

// Multiple bounds
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

## Trait Inheritance

Traits can inherit from other traits:

```klar
// Single inheritance
trait Ordered: Eq {
    fn compare(self, other: Self) -> Ordering
}

// Multiple inheritance
trait Sortable: Ordered + Clone {
    fn sort_key(self) -> i64
}
```

## Builtin Traits

Klar provides builtin traits for primitive types:

| Trait | Purpose | Primitives |
|-------|---------|------------|
| `Eq` | Equality (`==`, `!=`) | All primitives |
| `Ordered` | Ordering (`<`, `>`, `<=`, `>=`) | Numeric, string |
| `Clone` | Value copying | All primitives |
| `Drop` | Cleanup on scope exit | User-defined |

## Custom Drop

Implement `Drop` for types that need cleanup:

```klar
struct FileHandle {
    fd: i32
}

impl FileHandle: Drop {
    fn drop(self: &mut Self) {
        close_fd(self.fd)
    }
}

// Automatic cleanup when scope ends
fn use_file() {
    let handle: FileHandle = open_file("data.txt")
    // ... use handle ...
}   // drop() called automatically here
```

## Associated Types (Future)

Associated types allow traits to have placeholder types:

```klar
trait Iterator {
    type Item
    fn next(self: &mut Self) -> ?Self.Item
}

impl List[T]: Iterator {
    type Item = T
    fn next(self: &mut Self) -> ?T {
        // Implementation
    }
}
```

## Operator Overloading (Future)

Operators are implemented via traits:

```klar
trait Add[Rhs] {
    type Output
    fn add(self, rhs: Rhs) -> Self.Output
}

impl Vec2: Add[Vec2] {
    type Output = Vec2
    fn add(self, rhs: Vec2) -> Vec2 {
        return Vec2 { x: self.x + rhs.x, y: self.y + rhs.y }
    }
}

// Usage
let c: Vec2 = a + b  // Calls a.add(b)
```

## Trait Objects (Future)

Use `dyn` for dynamic dispatch:

```klar
fn draw_all(shapes: List[dyn Drawable]) {
    for shape in shapes {
        shape.draw()
    }
}
```

## Best Practices

1. **Keep traits focused** - one capability per trait
2. **Provide default implementations** where sensible
3. **Use trait bounds** to constrain generics
4. **Implement Drop** for resources that need cleanup
5. **Prefer static dispatch** over `dyn` when types are known
