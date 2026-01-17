# Klar-Toolkit Quick Reference

> For Claude Code and AI-assisted Klar development
>
> **Version 0.4.1** - Aligned with Klar Phase 4 (Language Completion)

## Standards Location

Full standards: `STANDARDS.md`

## Key Rules

### Naming
- Types: `PascalCase` (PlayerState, HttpError)
- Functions: `snake_case` (create_player, read_file)
- Variables: `snake_case` (player_count, is_valid)
- Constants: `UPPER_SNAKE_CASE` (MAX_SIZE, DEFAULT_PORT)
- Modules: `snake_case` (std.collections)

### Ownership
- Every value has one owner
- Use `&T` for immutable borrow, `&mut T` for mutable borrow
- No stored references in structs - use ownership, `Rc[T]`, or indices

### Syntax Requirements
- **Explicit types** on all variables: `let x: i32 = 42`
- **Explicit return** in all functions: `return value`
- **Statement-based control flow**: assign inside blocks, not expression returns
- **Closures with full types**: `|x: i32| -> i32 { return x * 2 }`

### Error Handling
- Return `Result[T, E]` for fallible operations
- Use `?` to propagate errors
- Use `?T` (Option) for values that may be absent
- Use `??` for default values: `value ?? default`

### Generics and Traits
- Generic functions: `fn max[T: Ordered](a: T, b: T) -> T`
- Generic structs: `struct Pair[A, B] { first: A, second: B }`
- Trait bounds: `T: Ordered + Clone`
- Builtin traits: `Eq`, `Ordered`, `Clone`, `Drop`

### Common Patterns

```klar
// Error propagation (explicit return required)
fn load_config(path: string) -> Result[Config, Error] {
    let content: string = read_file(path)?
    let config: Config = parse(content)?
    return Ok(config)
}

// Match statement (statement-based)
let user: ?User = find_user(id)
var greeting: string
match user {
    Some(u) => { greeting = "Hello, {u.name}" }
    None => { greeting = "Not found" }
}

// Generics with trait bounds
fn max[T: Ordered](a: T, b: T) -> T {
    if a > b {
        return a
    }
    return b
}

// Closures with explicit types
let double: fn(i32) -> i32 = |x: i32| -> i32 { return x * 2 }

// Ownership transfer
fn process(data: Data) { ... }      // Takes ownership
fn inspect(data: &Data) { ... }     // Borrows immutably
fn modify(data: &mut Data) { ... }  // Borrows mutably
```

## Checklist

Before committing:
- [ ] Types are `PascalCase`, functions are `snake_case`
- [ ] All variables have explicit type annotations
- [ ] All functions use explicit `return` statements
- [ ] All fallible operations return `Result[T, E]`
- [ ] External input is validated before use
- [ ] Public items are documented
- [ ] Tests exist for public functions

## Commands

| Command | Purpose |
|---------|---------|
| `/klar-init` | Create new Klar-Toolkit project |
| `/klar-install` | Add Klar-Toolkit to existing project |
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused review |
| `/klar-check` | Run build, tests, and checks |
| `/klar-update` | Update Klar-Toolkit |

## Rule Categories

Rules are auto-loaded from `.claude/rules/`:
- `klar-ownership.md` - Ownership and borrowing
- `klar-errors.md` - Result/Option patterns
- `klar-security.md` - Input validation, unsafe
- `klar-naming.md` - Naming conventions
- `klar-api-design.md` - API design patterns
- `klar-testing.md` - Testing standards
- `klar-concurrency.md` - Async, threads, channels
- `klar-comptime.md` - Compile-time patterns
- `klar-logging.md` - Logging standards
- `klar-portability.md` - Cross-platform
