# Error Handling Patterns

Patterns for robust error handling in Klar.

## The Error Model

Klar distinguishes between:
- **Traps**: Bugs that should never happen (panic, assert)
- **Errors**: Expected failures (Result, Option)

## Pattern 1: Result for Fallible Operations

Any operation that can fail should return `Result[T, E]`:

```klar
enum FileError {
    NotFound(string)
    PermissionDenied(string)
    IoError(string)
}

fn read_file(path: string) -> Result[string, FileError] {
    if not file_exists(path) {
        return Err(FileError.NotFound(path))
    }
    if not is_readable(path) {
        return Err(FileError.PermissionDenied(path))
    }
    // ... read and return Ok(contents)
}
```

## Pattern 2: Error Propagation with ?

Use `?` to propagate errors up the call stack:

```klar
fn load_config(path: string) -> Result[Config, ConfigError] {
    let contents = read_file(path)?         // Propagates FileError
    let parsed = parse_toml(contents)?      // Propagates ParseError
    let validated = validate(parsed)?       // Propagates ValidationError
    Ok(validated)
}
```

The `?` operator:
1. If `Ok(value)`, extracts the value
2. If `Err(e)`, returns early with the error (converted if needed)

## Pattern 3: Custom Error Types

Define meaningful error types for each module:

```klar
/// Errors that can occur during configuration.
enum ConfigError {
    /// Config file not found at the given path.
    NotFound(string)

    /// Failed to parse config file.
    ParseError {
        line: i32,
        column: i32,
        message: string
    }

    /// Config value failed validation.
    ValidationError {
        field: string,
        message: string
    }

    /// Underlying I/O error.
    IoError(IoError)
}

impl ConfigError {
    fn message(self: &ConfigError) -> string {
        self match {
            NotFound(path) => "Config not found: {path}"
            ParseError { line, column, message } =>
                "Parse error at {line}:{column}: {message}"
            ValidationError { field, message } =>
                "Invalid {field}: {message}"
            IoError(e) => "I/O error: {e}"
        }
    }
}
```

## Pattern 4: Error Conversion

Convert between error types when crossing module boundaries:

```klar
// In config module
impl From[FileError] for ConfigError {
    fn from(e: FileError) -> ConfigError {
        e match {
            FileError.NotFound(path) => ConfigError.NotFound(path)
            FileError.PermissionDenied(path) =>
                ConfigError.IoError(IoError.PermissionDenied(path))
            FileError.IoError(msg) =>
                ConfigError.IoError(IoError.Other(msg))
        }
    }
}

// Now ? automatically converts
fn load_config(path: string) -> Result[Config, ConfigError] {
    let contents = read_file(path)?  // FileError -> ConfigError
    // ...
}
```

## Pattern 5: Option for Absent Values

Use `?T` (Option) when a value may be absent (not an error):

```klar
fn find_user(id: i64) -> ?User {
    users.get(id)  // Returns None if not found
}

fn get_env(key: string) -> ?string {
    env_vars.get(key)
}
```

**Option vs Result:**
- `Option`: Value might not exist (not a failure)
- `Result`: Operation might fail (is a failure)

```klar
// Option - user might not exist, that's OK
fn find_user(id: i64) -> ?User

// Result - reading should work, failure is an error
fn read_user(id: i64) -> Result[User, DbError]
```

## Pattern 6: Pattern Matching Errors

Match on errors for specific handling:

```klar
let result = load_config(path)

result match {
    Ok(config) => {
        use_config(config)
    }

    Err(ConfigError.NotFound(_)) => {
        // Use defaults if config doesn't exist
        use_config(Config.default())
    }

    Err(ConfigError.ParseError { line, .. }) => {
        log.error("Config syntax error on line {line}")
        return Err(StartupError.BadConfig)
    }

    Err(e) => {
        // Re-raise other errors
        return Err(StartupError.from(e))
    }
}
```

## Pattern 7: Fallback Chain

Try multiple approaches, falling back on error:

```klar
fn load_config() -> Result[Config, ConfigError] {
    // Try user config first
    load_config_file("~/.config/app.toml")
        .or_else(fn(_) {
            // Fall back to system config
            load_config_file("/etc/app.toml")
        })
        .or_else(fn(_) {
            // Fall back to defaults
            Ok(Config.default())
        })
}
```

## Pattern 8: Collecting Results

Process a collection, handling errors:

```klar
// Stop on first error
fn process_all(items: [Item]) -> Result[(), ProcessError] {
    for item in items {
        process(item)?
    }
    Ok(())
}

// Collect all errors
fn validate_all(items: [Item]) -> [ValidationError] {
    let errors = []
    for item in items {
        validate(item) match {
            Ok(_) => {}
            Err(e) => errors.push(e)
        }
    }
    errors
}

// Separate successes and failures
fn partition_results[T, E](results: [Result[T, E]]) -> ([T], [E]) {
    let oks = []
    let errs = []
    for r in results {
        r match {
            Ok(v) => oks.push(v)
            Err(e) => errs.push(e)
        }
    }
    (oks, errs)
}
```

## Pattern 9: Context Enrichment

Add context when propagating errors:

```klar
fn load_user_data(user_id: i64) -> Result[UserData, AppError] {
    let config_path = get_user_config_path(user_id)

    load_config(config_path)
        .map_err(fn(e) {
            AppError.UserLoadFailed {
                user_id: user_id,
                cause: e.message()
            }
        })
}
```

## Pattern 10: Assertions for Invariants

Use assert for conditions that indicate bugs:

```klar
fn get_element(list: &List[T], index: usize) -> T {
    // Caller error if index is invalid
    assert(index < list.len(), "Index {index} out of bounds")
    list.data[index]
}

fn divide(a: i32, b: i32) -> i32 {
    // Caller error if dividing by zero
    assert(b != 0, "Division by zero")
    a / b
}
```

## Anti-Patterns to Avoid

### 1. Swallowing Errors
```klar
// BAD: Error silently ignored
let _ = save_data(data)

// GOOD: Handle or propagate
save_data(data)?
// or
save_data(data).unwrap_or_else(fn(e) { log.error("Save failed: {e}") })
```

### 2. Using panic for Expected Failures
```klar
// BAD: Panic on expected condition
fn parse(input: string) -> i32 {
    if not is_numeric(input) {
        panic("Invalid input")  // Wrong! This is expected
    }
    // ...
}

// GOOD: Return Result
fn parse(input: string) -> Result[i32, ParseError] {
    if not is_numeric(input) {
        return Err(ParseError.InvalidFormat)
    }
    // ...
}
```

### 3. Stringly-Typed Errors
```klar
// BAD: Error as string
fn load() -> Result[Data, string] {
    Err("Failed to load")  // No structure!
}

// GOOD: Typed error
fn load() -> Result[Data, LoadError] {
    Err(LoadError.NotFound { path: path })
}
```
