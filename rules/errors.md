---
globs: ["**/*.kl"]
---

# Error Handling Rules

## Result and Option Types

All fallible operations MUST return `Result[T, E]`:

```klar
fn read_file(path: string) -> Result[string, IoError]
fn parse_int(s: string) -> Result[i32, ParseError]
```

Use `?T` (Option) for values that may be absent (not errors):

```klar
fn find_user(id: i64) -> ?User
fn get_env(key: string) -> ?string
```

## Error Propagation

Use `?` to propagate errors up the call stack:

```klar
fn load_config(path: string) -> Result[Config, ConfigError] {
    let content = read_file(path)?      // Propagates on error
    let parsed = parse_toml(content)?
    Ok(Config.from_toml(parsed))
}
```

## Custom Error Types

Define error enums with context for each module:

```klar
enum ConfigError {
    NotFound(string)                      // Include the path
    ParseError { line: i32, msg: string } // Include location
    ValidationError(string)               // Include what failed
    IoError(IoError)                      // Wrap underlying errors
}
```

## Error Handling Patterns

```klar
// Match for specific handling
result match {
    Ok(value) => use(value)
    Err(ConfigError.NotFound(_)) => use_defaults()
    Err(e) => return Err(e)
}

// Provide defaults
let value = result.unwrap_or(default_value)

// Transform success value
let mapped = result.map(fn(x) { transform(x) })

// Chain fallbacks
let final = try_first().or_else(fn(_) { try_second() })
```

## Traps vs Errors

- **Traps**: Bugs that should never happen - use `assert()`, `panic()`
- **Errors**: Expected failures - use `Result[T, E]`

```klar
// Trap: Bug if index is invalid (caller's error)
fn get(self: &List[T], index: usize) -> T {
    assert(index < self.len())
    // ...
}

// Error: File may legitimately not exist
fn read_file(path: string) -> Result[string, IoError]
```
