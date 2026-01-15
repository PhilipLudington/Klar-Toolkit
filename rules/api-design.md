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

const WINDOW_CONFIG_DEFAULT = WindowConfig { ... }

fn create_window(config: WindowConfig) -> Window
```

## Method Receivers

```klar
impl Player {
    // Read-only access
    fn get_health(self: &Player) -> i32

    // Mutable access
    fn take_damage(self: &mut Player, amount: i32)

    // Consumes self
    fn into_corpse(self: Player) -> Corpse
}
```

## Return Types

- Return owned values by default
- Return `&T` only for accessors into internal state
- Return `Result[T, E]` for fallible operations

## Trait Design

**A2**: One capability per trait:

```klar
// GOOD: Focused
trait Readable { fn read(...) }
trait Writable { fn write(...) }

// BAD: Kitchen sink
trait Stream { fn read(); fn write(); fn seek(); fn flush(); }
```

Provide default implementations where sensible.

## Generics

Use trait bounds to constrain:

```klar
fn max[T: Ordered](a: T, b: T) -> T
fn print_all[T: Display](items: &[T])
fn process[T: Ordered + Clone](value: T)
```

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
pub fn create_player(name: string) -> Result[Player, Error]
```
