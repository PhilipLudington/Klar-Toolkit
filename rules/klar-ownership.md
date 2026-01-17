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

## Reference Syntax

| Syntax | Meaning |
|--------|---------|
| `T` | Owned value (takes ownership) |
| `&T` | Immutable reference (read-only borrow) |
| `&mut T` | Mutable reference (read-write borrow) |
| `?T` | Optional value (may be `None`) |

## Smart Pointer Guidelines

| Type | When to Use |
|------|-------------|
| `Rc[T]` | Single-threaded shared ownership |
| `Arc[T]` | Thread-safe shared ownership |
| `Cell[T]` | Interior mutability for Copy types |
| `RefCell[T]` | Interior mutability with runtime checks |
| `Weak[T]` | Non-owning reference to break cycles |

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

// GOOD: Use Rc for shared ownership
struct Parser { input: Rc[string] }

// GOOD: Use indices for referencing into collections
struct Selection {
    buffer_id: i32
    start: i32
    end: i32
}
```

## Common Patterns

```klar
// Builder pattern - takes ownership, returns owned
fn with_name(self: Config, name: string) -> Config {
    return Config { name: name, ..self }
}

// Clone when needed
let copy: Data = original.clone()

// Take ownership to prevent further use
fn close(connection: Connection) {
    // connection is dropped at end
}

// Interior mutability for shared mutable state
let counter: Rc[Cell[i32]] = Rc.new(Cell.new(0))
counter.set(counter.get() + 1)

// RefCell for complex values
let buffer: Rc[RefCell[Buffer]] = Rc.new(RefCell.new(Buffer.new(1024)))
buffer.borrow_mut().write(data)
```

## Drop Trait

Implement `Drop` for custom cleanup:

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
