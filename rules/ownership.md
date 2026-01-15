---
globs: ["**/*.kl"]
---

# Ownership and Borrowing Rules

## Ownership Fundamentals

Every value in Klar has exactly one owner. When writing code:

1. **Transfer ownership explicitly** - When a function takes ownership, document it
2. **Prefer borrowing** - Use `&T` or `&mut T` when ownership transfer isn't needed
3. **Return owned values** - Functions typically return owned data, not references

## Borrowing Rules

```klar
// Immutable borrow - multiple allowed
fn inspect(data: &Data) { ... }

// Mutable borrow - exclusive access
fn modify(data: &mut Data) { ... }

// Ownership transfer - data is consumed
fn consume(data: Data) { ... }
```

## Smart Pointer Guidelines

| Type | When to Use |
|------|-------------|
| `Rc[T]` | Single-threaded shared ownership |
| `Arc[T]` | Thread-safe shared ownership |
| `RefCell[T]` | Interior mutability with runtime checks |

**Avoid**:
- Using `Rc`/`Arc` when ownership would work
- Creating reference cycles (use weak references)
- `RefCell` when compile-time borrowing suffices

## No Stored References

Klar prohibits storing references in structs. Instead:

```klar
// BAD: Cannot store reference
struct Parser { input: &string }

// GOOD: Own the data
struct Parser { input: string }

// GOOD: Use indices
struct Selection { buffer_id: usize, start: usize, end: usize }
```

## Common Patterns

```klar
// Builder pattern - takes ownership, returns owned
fn with_name(self: Config, name: string) -> Config {
    Config { name: name, ..self }
}

// Clone when needed
let copy = original.clone()

// Take ownership to prevent further use
fn close(connection: Connection) {
    // connection is dropped at end
}
```
