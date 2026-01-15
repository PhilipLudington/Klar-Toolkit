# CarbideKlar Quick Reference

> For Claude Code and AI-assisted Klar development

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
- No stored references in structs - use ownership or indices

### Error Handling
- Return `Result[T, E]` for fallible operations
- Use `?` to propagate errors
- Use `?T` (Option) for values that may be absent
- Define custom error enums with context

### Common Patterns

```klar
// Error propagation
fn load_config(path: string) -> Result[Config, Error] {
    let content = read_file(path)?
    let config = parse(content)?
    Ok(config)
}

// Option handling
let user = find_user(id)
user match {
    Some(u) => greet(u)
    None => println("Not found")
}

// Ownership transfer
fn process(data: Data) { ... }  // Takes ownership
fn inspect(data: &Data) { ... } // Borrows immutably
fn modify(data: &mut Data) { ... } // Borrows mutably
```

## Checklist

Before committing:
- [ ] Types are `PascalCase`, functions are `snake_case`
- [ ] All fallible operations return `Result[T, E]`
- [ ] External input is validated before use
- [ ] Public items are documented
- [ ] Tests exist for public functions

## Commands

| Command | Purpose |
|---------|---------|
| `/klar-init` | Create new CarbideKlar project |
| `/klar-install` | Add CarbideKlar to existing project |
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused review |
| `/klar-check` | Run build, tests, and checks |
| `/klar-update` | Update CarbideKlar |

## Rule Categories

Rules are auto-loaded from `.claude/rules/`:
- `ownership.md` - Ownership and borrowing
- `errors.md` - Result/Option patterns
- `security.md` - Input validation, unsafe
- `naming.md` - Naming conventions
- `api-design.md` - API design patterns
- `testing.md` - Testing standards
- `concurrency.md` - Async, threads
- `comptime.md` - Compile-time patterns
- `logging.md` - Logging standards
- `portability.md` - Cross-platform
