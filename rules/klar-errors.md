---
globs: ["**/*.kl"]
---

# Error Handling Rules

## Result and Option Types

All fallible operations MUST return `Result[T, E]`:

```klar
fn read_file(path: string) -> Result[string, IoError] { ... }
fn parse_int(s: string) -> Result[i32, ParseError] { ... }
```

Use `?T` (Option) for values that may be absent (not errors):

```klar
fn find_user(id: i64) -> ?User { ... }
fn get_env(key: string) -> ?string { ... }
```

## Error Propagation

Use `?` to propagate errors up the call stack:

```klar
fn load_config(path: string) -> Result[Config, ConfigError] {
    let content: string = read_file(path)?      // Propagates on error
    let parsed: Toml = parse_toml(content)?
    return Ok(Config.from_toml(parsed))
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
// Match for specific handling (statement-based)
var output: Config
match result {
    Ok(value) => { output = value }
    Err(ConfigError.NotFound(_)) => { output = use_defaults() }
    Err(e) => { return Err(e) }
}

// Provide defaults with ??
let value: i32 = result ?? default_value

// Transform success value (closure with explicit types)
let transformer: fn(T) -> U = |x: T| -> U { return transform(x) }
let mapped: Result[U, E] = result.map(transformer)

// Chain fallbacks
let final_result: Result[T, E] = try_first()
    .or_else(|_: E| -> Result[T, E] { return try_second() })
```

## Traps vs Errors

- **Traps**: Bugs that should never happen - use `assert()`, `panic()`
- **Errors**: Expected failures - use `Result[T, E]`

```klar
// Trap: Bug if index is invalid (caller's error)
fn get[T](self: &List[T], index: i32) -> T {
    assert(index < self.len())
    return self.data[index]
}

// Error: File may legitimately not exist
fn read_file(path: string) -> Result[string, IoError] { ... }
```

## Try Blocks (Future)

Group fallible operations with try blocks:

```klar
var result: Result[Data, Error]
try {
    let a: Data1 = step_one()?
    let b: Data2 = step_two(a)?
    let c: Data3 = step_three(b)?
    result = Ok(c)
} catch e {
    result = Err(e)
}
```

## Error Conversion

Implement `Into` trait for automatic error conversion with `?`:

```klar
impl IoError: Into[ProcessError] {
    fn into(self) -> ProcessError {
        return ProcessError.Io(self)
    }
}

// Now IoError automatically converts when propagating
fn process() -> Result[Data, ProcessError] {
    let file: string = read_file(path)?  // IoError -> ProcessError
    return Ok(parse(file))
}
```
