# Klar-Toolkit Coding Standards

> Hardened Klar development standards for safe, consistent, and maintainable code.

These standards define unambiguous, enforceable rules for writing Klar code. They are designed to work with AI-assisted development (Claude Code) and provide clear guidance for both humans and AI to follow.

**Version**: 0.4.1 (aligned with Klar Phase 4 - Language Completion)

---

## Table of Contents

1. [Language Standards](#1-language-standards)
2. [Naming Conventions](#2-naming-conventions)
3. [Ownership and Memory](#3-ownership-and-memory)
4. [Error Handling](#4-error-handling)
5. [API Design](#5-api-design)
6. [Security](#6-security)
7. [Code Organization](#7-code-organization)
8. [Documentation](#8-documentation)
9. [Testing](#9-testing)
10. [Concurrency](#10-concurrency)
11. [Compile-Time Programming](#11-compile-time-programming)
12. [Logging](#12-logging)
13. [Portability](#13-portability)

---

## 1. Language Standards

### 1.1 Klar Version

Target **Klar Phase 4** (Language Completion) with full native compilation via LLVM.

**Implemented Features:**
- Generic functions, structs, and enums with monomorphization
- Trait definitions, implementations, and bounds
- Trait inheritance (single and multiple)
- Builtin traits: Eq, Ordered, Clone, Drop
- Three execution backends: interpreter, bytecode VM, native compilation

**In Progress:**
- Associated types in traits
- Module system and imports
- Standard library

### 1.2 Core Principles

1. **Unambiguous syntax** — No context needed to parse code
2. **No undefined behavior** — Every operation has defined semantics
3. **Memory safe by default** — Ownership system prevents common bugs
4. **Explicit over implicit** — No type inference, explicit `return`, statement-based control flow
5. **One obvious way** — Single syntax form for each construct
6. **Fail fast, fail loud** — Detect errors early and report clearly
7. **AI-first design** — Optimized for AI code generation clarity

---

## 2. Naming Conventions

### 2.1 Case Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Types (struct, enum, trait) | `PascalCase` | `PlayerState`, `HttpError` |
| Functions | `snake_case` | `player_create`, `read_file` |
| Variables | `snake_case` | `player_count`, `is_valid` |
| Struct fields | `snake_case` | `health`, `max_speed` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_PLAYERS`, `DEFAULT_PORT` |
| Enum variants | `PascalCase` | `Some`, `None`, `ReadError` |
| Modules | `snake_case` | `std.collections`, `http_client` |
| Type parameters | Single uppercase or `PascalCase` | `T`, `Key`, `Value` |

### 2.2 Module Prefixing

Public symbols in library modules SHOULD use a consistent prefix to avoid collisions:

```klar
// In module: game.player
pub struct Player { ... }
pub fn create(name: string) -> Player { ... }

// Usage: game.player.create("Alice")
```

For standalone libraries, use the module system for namespacing rather than name prefixes.

### 2.3 Function Naming Patterns

| Pattern | Meaning | Example |
|---------|---------|---------|
| `create` / `destroy` | Allocate/deallocate owned resource | `connection_create()` |
| `new` | Create value type (no allocation) | `Point.new(x, y)` |
| `from_*` | Convert from another type | `Config.from_toml(data)` |
| `to_*` | Convert to another type | `number.to_string()` |
| `as_*` | Cheap reference conversion | `slice.as_bytes()` |
| `into_*` | Consuming conversion | `builder.into_string()` |
| `get_*` / `set_*` | Accessor/mutator | `player.get_health()` |
| `is_*` / `has_*` / `can_*` | Boolean query | `list.is_empty()` |
| `try_*` | May fail, returns Result | `try_parse(input)` |
| `*_or` | Fallback variant | `get_or(default)` |
| `*_unchecked` | Skips validation (unsafe) | `get_unchecked(index)` |

### 2.4 Boolean Naming

Boolean variables and functions MUST read as true/false statements:

```klar
// GOOD
let is_valid: bool = true
let has_children: bool = node.children.len() > 0
if connection.is_open() { ... }

// BAD
let valid: bool = true        // Ambiguous
let children: bool = true     // Noun, not predicate
if connection.open() { ... }  // Could be verb "open it"
```

Preferred prefixes: `is_`, `has_`, `can_`, `should_`, `was_`, `will_`

### 2.5 Acronyms and Abbreviations

Treat acronyms as words for casing:

```klar
// GOOD
struct HttpClient { ... }
fn parse_json(data: string) -> Result[Json, ParseError] { ... }
let html_content: string = fetch_page(url)

// BAD
struct HTTPClient { ... }  // Use Http, not HTTP
fn parseJSON(data: string) // Use Json, not JSON
```

Common abbreviations that are acceptable:
- `len` (length), `str` (string), `num` (number)
- `max`, `min`, `avg`, `err`, `msg`, `buf`, `ptr`, `ctx`

---

## 3. Ownership and Memory

Klar uses an ownership system to ensure memory safety without garbage collection.

### 3.1 Ownership Rules

**O1**: Every value has exactly one owner at any time.

**O2**: When the owner goes out of scope, the value is dropped.

**O3**: Ownership can be transferred (moved) to another variable or function.

```klar
let data = load_data()     // data owns the value
process(data)              // Ownership transferred to process()
// data is no longer valid here - compile error if used
```

### 3.2 Borrowing Rules

**B1**: You can have either ONE mutable reference OR any number of immutable references.

**B2**: References must not outlive the value they reference.

```klar
let data = create_data()

// Immutable borrows - multiple allowed
let a = &data
let b = &data
print(a, b)  // OK

// Mutable borrow - exclusive access
let c = &mut data
c.modify()
// Cannot use &data while &mut data exists
```

### 3.3 Reference Syntax

| Syntax | Meaning |
|--------|---------|
| `T` | Owned value (takes ownership) |
| `&T` | Immutable reference (read-only borrow) |
| `&mut T` | Mutable reference (read-write borrow) |
| `?T` | Optional value (may be `None`) |

### 3.4 Copy vs Move Types

**Copy types** (automatically copied, not moved):
- All primitive types: `i8`-`i128`, `u8`-`u128`, `f32`, `f64`, `bool`, `char`
- Fixed-size arrays of copy types: `[i32; 4]`
- Tuples of copy types: `(i32, bool)`

**Move types** (ownership transfers):
- `string`
- Collections: `List[T]`, `Map[K, V]`, `Set[T]`
- User-defined structs (unless implementing `Copy` trait)
- `Rc[T]`, `Arc[T]`

### 3.5 Smart Pointers

Use smart pointers when ownership rules are insufficient:

| Type | Use Case |
|------|----------|
| `Rc[T]` | Single-threaded shared ownership |
| `Arc[T]` | Thread-safe shared ownership |
| `Cell[T]` | Interior mutability (copy types) |
| `RefCell[T]` | Interior mutability with runtime checks |

**SP1**: Prefer ownership and borrowing over smart pointers.

**SP2**: Use `Rc[T]` only when multiple owners are genuinely needed.

**SP3**: Use `Arc[T]` only in concurrent contexts.

**SP4**: Avoid reference cycles with `Rc`/`Arc` - use weak references when needed.

### 3.6 No Stored References

Klar simplifies lifetimes by prohibiting stored references in structs:

```klar
// NOT ALLOWED in Klar
struct Parser {
    input: &string  // Error: cannot store reference
}

// INSTEAD: Use ownership or indices
struct Parser {
    input: string   // Own the data
}

// OR: Use indices for referencing into collections
struct Selection {
    buffer_id: usize
    start: usize
    end: usize
}
```

---

## 4. Error Handling

Klar distinguishes between **traps** (bugs) and **errors** (expected failures).

### 4.1 Traps vs Errors

| Category | Examples | Handling |
|----------|----------|----------|
| **Traps** | Index out of bounds, integer overflow, unwrap on `none` | Program halts with diagnostic |
| **Errors** | File not found, parse failure, network timeout | Return `Result[T, E]` |

**E1**: Use traps for programming errors that should never happen in correct code.

**E2**: Use `Result[T, E]` for operations that can legitimately fail.

### 4.2 Result Type

```klar
enum Result[T, E] {
    Ok(T)
    Err(E)
}
```

**E3**: All fallible operations MUST return `Result[T, E]` with a meaningful error type.

```klar
fn read_file(path: string) -> Result[string, IoError] {
    if not file_exists(path) {
        return Err(IoError.NotFound(path))
    }
    // ... read file ...
    return Ok(contents)
}
```

### 4.3 Error Propagation

Use `?` to propagate errors up the call stack:

```klar
fn load_config(path: string) -> Result[Config, ConfigError] {
    let contents: string = read_file(path)?        // Propagates IoError
    let parsed: Toml = parse_toml(contents)?       // Propagates ParseError
    let config: Config = Config.from_toml(parsed)? // Propagates ValidationError
    return Ok(config)
}
```

**E4**: Use `?` for error propagation instead of explicit matching when appropriate.

**E5**: Convert error types when propagating across module boundaries.

### 4.4 Option Type

```klar
enum Option[T] {
    Some(T)
    None
}

// Shorthand syntax
?T  // Equivalent to Option[T]
```

**E6**: Use `?T` for values that may be absent (not for errors).

```klar
fn find_user(id: i64) -> ?User {
    return users.get(id)  // Returns None if not found
}

// Usage with match statement (statement-based, not expression)
let user: ?User = find_user(42)
match user {
    Some(u) => { greet(u) }
    None => { println("User not found") }
}
```

### 4.5 Error Types

**E7**: Define custom error enums for each module or subsystem.

```klar
enum ConfigError {
    NotFound(string)
    ParseError { line: i32, message: string }
    ValidationError(string)
    IoError(IoError)  // Wrap underlying errors
}
```

**E8**: Include context in error variants (file path, line number, etc.).

### 4.6 Error Handling Patterns

```klar
// Pattern 1: Match for specific handling (statement-based)
var output: Config
match result {
    Ok(value) => { output = value }
    Err(ConfigError.NotFound(_)) => { output = use_defaults() }
    Err(e) => { return Err(e) }
}

// Pattern 2: Unwrap with default
let value: i32 = result ?? default

// Pattern 3: Map the success value (closure with explicit types)
let mapper: fn(i32) -> i32 = |x: i32| -> i32 { return x * 2 }
let mapped: Result[i32, E] = result.map(mapper)

// Pattern 4: Chain fallible operations
let final_result: Result[Data, Error] = first_try()
    .or_else(|_: Error| -> Result[Data, Error] { return second_try() })
    .or_else(|_: Error| -> Result[Data, Error] { return third_try() })
```

### 4.7 Panic and Assert

**E9**: Use `panic(message)` only for unrecoverable situations.

**E10**: Use `assert(condition)` for invariants that indicate bugs if violated.

```klar
fn divide(a: i32, b: i32) -> i32 {
    assert(b != 0)  // Bug if called with b=0
    return a / b
}
```

---

## 5. API Design

### 5.1 Function Design

**A1**: Functions SHOULD have at most 4 parameters. Use config structs for more.

```klar
// BAD: Too many parameters
fn create_window(title: string, x: i32, y: i32, width: i32, height: i32,
                 fullscreen: bool, vsync: bool) -> Window

// GOOD: Config struct
struct WindowConfig {
    title: string
    x: i32
    y: i32
    width: i32
    height: i32
    fullscreen: bool
    vsync: bool
}

const WINDOW_CONFIG_DEFAULT = WindowConfig {
    title: "Untitled"
    x: 100
    y: 100
    width: 800
    height: 600
    fullscreen: false
    vsync: true
}

fn create_window(config: WindowConfig) -> Window
```

**A2**: Use `&self` for methods that read, `&mut self` for methods that modify.

```klar
impl Player {
    fn get_health(self: &Player) -> i32 {
        return self.health
    }

    fn take_damage(self: &mut Player, amount: i32) {
        self.health = max(0, self.health - amount)
    }
}
```

### 5.2 Return Types

**A3**: Return owned values by default. Return references only for accessors.

```klar
// Owned return - caller owns the result
fn load_texture(path: string) -> Result[Texture, LoadError] { ... }

// Reference return - for accessing internal state
fn get_name(self: &Player) -> &string {
    return &self.name
}
```

### 5.3 Trait Design

**A4**: Keep traits focused - one capability per trait.

```klar
// GOOD: Focused traits
trait Readable {
    fn read(self: &mut Self, buf: &mut [u8]) -> Result[usize, IoError]
}

trait Writable {
    fn write(self: &mut Self, data: &[u8]) -> Result[usize, IoError]
}

// BAD: Kitchen-sink trait
trait Stream {
    fn read(...)
    fn write(...)
    fn seek(...)
    fn flush(...)
    fn close(...)
}
```

**A5**: Provide default implementations where sensible.

```klar
trait Printable {
    fn to_string(self) -> string

    // Default implementation uses to_string()
    fn print(self) {
        println(self.to_string())
    }
}
```

### 5.4 Generics

**A6**: Use trait bounds to constrain generic types.

```klar
// Generic function with trait bound
fn max[T: Ordered](a: T, b: T) -> T {
    if a > b {
        return a
    }
    return b
}

// Multiple trait bounds
fn print_all[T: Printable + Clone](items: &[T]) {
    for item in items {
        println("{item}")
    }
}

// Where clauses for complex bounds
fn merge[K, V](a: Map[K, V], b: Map[K, V]) -> Map[K, V]
where
    K: Hashable + Eq
    V: Clone
{
    // ...
}
```

**A7**: Prefer concrete types over generics for public APIs when the types are known.

### 5.5 Generic Types

**A8**: Define generic structs and enums with type parameters.

```klar
// Generic struct
struct Pair[A, B] {
    first: A
    second: B
}

// Generic enum (standard library)
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

### 5.6 Trait Implementation

**A9**: Implement traits with the `impl Type: Trait` syntax.

```klar
// Implement trait for concrete type
impl i32: Ordered {
    fn compare(self, other: i32) -> Ordering {
        if self < other {
            return Ordering.Less
        } else if self > other {
            return Ordering.Greater
        }
        return Ordering.Equal
    }
}

// Implement trait for generic type
impl List[T]: Iterator {
    type Item = T
    fn next(self: &mut Self) -> ?T { ... }
}
```

### 5.7 Builtin Traits

Klar provides builtin traits that are automatically implemented for primitive types:

| Trait | Purpose | Primitives |
|-------|---------|------------|
| `Eq` | Equality comparison (`==`, `!=`) | All primitives |
| `Ordered` | Ordering comparison (`<`, `>`, `<=`, `>=`) | Numeric, string |
| `Clone` | Explicit value copying | All primitives |
| `Drop` | Custom cleanup on scope exit | User-defined |

```klar
// Using builtin traits
fn equals[T: Eq](a: T, b: T) -> bool {
    return a == b
}

// Custom Drop implementation
struct FileHandle {
    fd: i32
}

impl FileHandle: Drop {
    fn drop(self: &mut Self) {
        close_fd(self.fd)
    }
}
```

### 5.8 Module Visibility

**A10**: Make items private by default. Only expose what's necessary.

```klar
module http_client

// Public API
pub struct Client { ... }
pub fn create() -> Client { ... }
pub fn get(client: &Client, url: string) -> Result[Response, HttpError] { ... }

// Private implementation details
struct ConnectionPool { ... }
fn manage_pool(pool: &mut ConnectionPool) { ... }
```

---

## 6. Security

### 6.1 Input Validation

**S1**: Validate all external input before use.

External input includes:
- User input (command line, stdin, GUI)
- File contents
- Network data
- Environment variables

```klar
fn process_user_input(input: string) -> Result[Command, InputError] {
    // Validate length
    if input.len() > MAX_INPUT_LENGTH {
        return Err(InputError.TooLong)
    }

    // Validate format
    if not is_valid_command_format(input) {
        return Err(InputError.InvalidFormat)
    }

    parse_command(input)
}
```

### 6.2 Bounds Checking

**S2**: Klar performs automatic bounds checking on array access.

```klar
let arr = [1, 2, 3]
let x = arr[5]  // Trap: index out of bounds
```

For performance-critical code where bounds are already validated:

```klar
// Only use when you've validated bounds yourself
let x = arr.get_unchecked(index)  // No bounds check - unsafe
```

**S3**: Never use `get_unchecked` on untrusted indices.

### 6.3 Integer Safety

**S4**: Use explicit overflow handling for arithmetic on untrusted values.

```klar
// Standard operators trap on overflow
let result = a + b  // Traps if overflow

// Wrapping operators (overflow wraps around)
let result = a +% b  // Wraps on overflow

// Saturating operators (clamp to min/max)
let result = a +| b  // Saturates on overflow

// Checked arithmetic returns Option
let result = a.checked_add(b)  // Returns ?i32
```

**S5**: Use saturating or checked arithmetic for sizes and counts from external input.

### 6.4 Unsafe Blocks

**S6**: Minimize use of `unsafe` blocks.

```klar
unsafe {
    // Code here bypasses safety checks
    // Required for: FFI, raw pointers, certain optimizations
}
```

**S7**: Document WHY each unsafe block is safe.

```klar
// SAFETY: index was validated above to be < len
unsafe {
    arr.get_unchecked(index)
}
```

**S8**: Never use unsafe to work around ownership/borrowing errors.

### 6.5 Path Safety

**S9**: Validate file paths to prevent directory traversal.

```klar
fn safe_read_file(base_dir: string, user_path: string) -> Result[string, PathError] {
    // Reject paths with traversal attempts
    if user_path.contains("..") {
        return Err(PathError.TraversalAttempt)
    }

    let full_path = join_path(base_dir, user_path)

    // Verify the resolved path is within base_dir
    let canonical = canonicalize(full_path)?
    if not canonical.starts_with(base_dir) {
        return Err(PathError.OutsideBaseDir)
    }

    read_file(canonical)
}
```

### 6.6 Command Execution

**S10**: Never pass untrusted input directly to command execution.

```klar
// BAD: Command injection vulnerability
fn run_user_command(user_input: string) {
    system("process " + user_input)  // DANGEROUS
}

// GOOD: Use explicit argument arrays
fn run_user_command(filename: string) -> Result[(), ExecError] {
    // Validate filename first
    if not is_safe_filename(filename) {
        return Err(ExecError.InvalidFilename)
    }
    exec("process", [filename])
}
```

---

## 7. Code Organization

### 7.1 Module Structure

```
project/
├── src/
│   ├── main.kl           # Entry point (if executable)
│   ├── lib.kl            # Library root (if library)
│   ├── module_a.kl       # Top-level modules
│   ├── module_b.kl
│   └── submodule/        # Nested modules
│       ├── mod.kl        # Submodule root
│       └── helper.kl
├── tests/
│   ├── test_module_a.kl
│   └── test_module_b.kl
└── README.md
```

### 7.2 Import Organization

Order imports as follows:

1. Standard library imports
2. Third-party library imports
3. Project imports

```klar
// Standard library
import std.collections.{List, Map}
import std.io.{read_file, write_file}

// Third-party
import http.{Client, Request}
import json.{parse, stringify}

// Project modules
import crate.config.Config
import crate.utils.helpers
```

### 7.3 File Length

**F1**: Keep files under 500 lines. Split large files into submodules.

**F2**: Keep functions under 50 lines. Extract helpers for complex logic.

### 7.4 Section Comments

For longer files, use section comments:

```klar
// ============================================================
// Types
// ============================================================

struct Player { ... }
enum PlayerState { ... }

// ============================================================
// Public API
// ============================================================

pub fn create_player(name: string) -> Player { ... }

// ============================================================
// Private Helpers
// ============================================================

fn validate_name(name: string) -> bool { ... }
```

---

## 8. Documentation

### 8.1 Function Documentation

**D1**: Document all public functions.

```klar
/// Creates a new player with the given name.
///
/// # Arguments
/// * `name` - The player's display name (1-32 characters)
///
/// # Returns
/// A new Player instance, or ConfigError if name is invalid.
///
/// # Example
/// ```
/// let player = create_player("Alice")?
/// assert(player.get_name() == "Alice")
/// ```
pub fn create_player(name: string) -> Result[Player, ConfigError] {
    // ...
}
```

### 8.2 Required Documentation Elements

For public functions:
- Brief description (first line)
- Parameter descriptions (for non-obvious params)
- Return value description
- Error conditions (if returns Result)
- Example (for complex APIs)

### 8.3 Module Documentation

```klar
/// HTTP client library for making web requests.
///
/// This module provides a simple interface for HTTP GET, POST, PUT, and DELETE
/// requests with support for timeouts, headers, and JSON bodies.
///
/// # Example
/// ```
/// let client = http.Client.new()
/// let response = client.get("https://api.example.com/users")?
/// println(response.body)
/// ```
module http_client
```

### 8.4 Comment Guidelines

**D2**: Explain WHY, not WHAT. The code shows what; comments explain intent.

```klar
// BAD: Restates the code
// Increment counter by 1
counter = counter + 1

// GOOD: Explains why
// Track retry attempts for exponential backoff
retry_count = retry_count + 1
```

**D3**: Keep comments up to date. Wrong comments are worse than no comments.

---

## 9. Testing

### 9.1 Test Organization

**T1**: One test file per module: `tests/test_<module>.kl`

**T2**: Test function naming: `test_<function>_<scenario>`

```klar
// tests/test_player.kl

fn test_create_player_success() {
    let player = create_player("Alice")
    assert(player.is_ok())
    assert(player.unwrap().get_name() == "Alice")
}

fn test_create_player_empty_name() {
    let result = create_player("")
    assert(result.is_err())
    result.unwrap_err() match {
        ConfigError.InvalidName(_) => {}  // Expected
        _ => panic("Wrong error type")
    }
}

fn test_create_player_name_too_long() {
    let long_name = "a".repeat(100)
    let result = create_player(long_name)
    assert(result.is_err())
}
```

### 9.2 Test Categories

Every module SHOULD have tests for:

1. **Happy path**: Normal successful operation
2. **Edge cases**: Empty input, zero values, maximum values, boundaries
3. **Error conditions**: Invalid input, missing resources, permission errors
4. **State transitions**: Objects in different states behave correctly

### 9.3 Test Structure

Use Arrange-Act-Assert pattern:

```klar
fn test_player_take_damage() {
    // Arrange
    let player = create_player("Test")
    player.set_health(100)

    // Act
    player.take_damage(30)

    // Assert
    assert(player.get_health() == 70)
}
```

### 9.4 Assertions

**T3**: One logical assertion per test (may be multiple assert calls).

**T4**: Use descriptive assertion messages.

```klar
assert(result.is_ok(), "Expected successful parse")
assert(value == expected, "Health should be {expected}, got {value}")
```

### 9.5 Test Coverage

**T5**: All public API functions MUST have tests.

**T6**: Error paths MUST be tested, not just happy paths.

---

## 10. Concurrency

### 10.1 Thread Safety

**C1**: Document thread safety of every public type and function.

```klar
/// A thread-safe counter.
///
/// This type can be safely shared between threads using Arc.
pub struct AtomicCounter { ... }

/// Get the player's current health.
///
/// Thread-safety: Safe for concurrent reads. Not safe for concurrent
/// read+write - use a mutex for read-modify-write operations.
pub fn get_health(self: &Player) -> i32 { ... }
```

### 10.2 Shared State

**C2**: Prefer message passing over shared state.

```klar
// PREFERRED: Message passing
let channel_pair: (Sender[Message], Receiver[Message]) = channel[Message]()
let tx: Sender[Message] = channel_pair.0
let rx: Receiver[Message] = channel_pair.1

// Spawn with explicit closure type
let worker: fn() -> void = || -> void {
    loop {
        let msg: Message = rx.recv()
        process(msg)
    }
}
spawn worker

tx.send(Message.DoWork(data))

// AVOID when possible: Shared mutable state
let shared: Arc[Mutex[Data]] = Arc.new(Mutex.new(data))
```

**C3**: When using shared state, prefer `Arc[Mutex[T]]` for clarity.

### 10.3 Async/Await

**C4**: Use `async`/`await` for I/O-bound concurrent operations.

```klar
async fn fetch_data(url: string) -> Result[Data, HttpError] {
    let response: Response = http.get(url).await?
    let body: string = response.read_body().await?
    return Ok(parse(body))
}

async fn main() {
    let data: Data = fetch_data("https://api.example.com").await?
    process(data)
}
```

**C5**: Avoid blocking in async functions.

### 10.4 Concurrent Operations

**C6**: Use `await_all` for concurrent async operations.

```klar
async fn fetch_multiple(urls: List[string]) -> List[Result[Response, HttpError]] {
    let results: (Data, Data, Data) = await_all(
        fetch("/api/a"),
        fetch("/api/b"),
        fetch("/api/c")
    )
    let a: Data = results.0
    let b: Data = results.1
    let c: Data = results.2
    return process_all(a, b, c)
}

// First to complete
let first: Data = await_first(
    fetch("/primary"),
    fetch("/backup")
)
```

### 10.5 Spawn and Tasks

**C7**: Use `spawn` for concurrent tasks.

```klar
// Fire and forget
spawn handle_connection(conn)

// Await result
let task: Task[Data] = spawn fetch_data(url)
let result: Data = task.await
```

### 10.6 Channels and Select

**C8**: Use select for multiplexing channels.

```klar
loop {
    select {
        msg from inbox => { handle_message(msg) }
        tick from timer => { handle_tick() }
        _ from shutdown => { break }
    }
}
```

### 10.7 Synchronization Primitives

**C9**: Use appropriate synchronization for shared state.

```klar
// Mutex for exclusive access
let data: Mutex[HashMap[string, i32]] = Mutex.new(HashMap.new())
{
    var guard: MutexGuard[HashMap[string, i32]] = data.lock()
    guard.insert("key", value)
}

// RwLock for read-heavy workloads
let cache: RwLock[HashMap[string, i32]] = RwLock.new(HashMap.new())
{
    let view: ReadGuard[HashMap[string, i32]] = cache.read()   // Many readers
}
{
    var edit: WriteGuard[HashMap[string, i32]] = cache.write() // Exclusive writer
}
```

---

## 11. Compile-Time Programming

Klar uses `comptime` instead of preprocessor macros.

### 11.1 Comptime Blocks

```klar
const TABLE_SIZE = comptime {
    // Computed at compile time
    calculate_optimal_size(1000)
}

const LOOKUP_TABLE: [u8; TABLE_SIZE] = comptime {
    generate_lookup_table()
}
```

### 11.2 Comptime Functions

**CT1**: Use comptime for values that can be computed at compile time.

```klar
comptime fn factorial(n: u64) -> u64 {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

const FACT_10: u64 = factorial(10)  // Computed at compile time
```

### 11.3 Conditional Compilation

```klar
const DEBUG = comptime { env("DEBUG") == "1" }

fn log(msg: string) {
    if DEBUG {
        println("[DEBUG] {msg}")
    }
}
```

### 11.4 When NOT to Use Comptime

**CT2**: Don't use comptime for runtime-dependent values.

**CT3**: Don't use comptime to obscure code logic.

---

## 12. Logging

### 12.1 Log Levels

| Level | Use For |
|-------|---------|
| `error` | Failures that prevent operation completion |
| `warn` | Unexpected but recoverable situations |
| `info` | Significant events (startup, shutdown, config changes) |
| `debug` | Detailed information for troubleshooting |
| `trace` | Very detailed execution flow |

### 12.2 Log Message Format

Include context in log messages:

```klar
// GOOD: Includes context
log.error("Failed to load config file: {path}, error: {err}")
log.info("Server started on port {port}")
log.debug("Processing request {request_id} from {client_ip}")

// BAD: No context
log.error("Load failed")
log.info("Started")
```

### 12.3 What NOT to Log

**L1**: Never log secrets (passwords, tokens, API keys, private keys).

**L2**: Never log full file contents or large data blobs.

**L3**: Never log personally identifiable information (PII) unless required and compliant.

**L4**: Avoid logging in tight loops (use sampling or aggregation).

### 12.4 Structured Logging

Prefer structured logging for machine-readable output:

```klar
log.info("request_complete", {
    request_id: req.id,
    duration_ms: elapsed,
    status: response.status,
    path: req.path
})
```

---

## 13. Portability

### 13.1 Integer Types

**P1**: Use fixed-width types for data structures: `i32`, `u64`, etc.

**P2**: Use `isize`/`usize` for sizes and indices.

**P3**: Be explicit about integer sizes in APIs.

### 13.2 Path Handling

**P4**: Use `/` as path separator (works on all platforms).

**P5**: Never hardcode absolute paths.

**P6**: Use path manipulation functions, not string concatenation.

```klar
// GOOD
let full_path = join_path(base_dir, filename)

// BAD
let full_path = base_dir + "/" + filename
```

### 13.3 Endianness

**P7**: Use explicit byte order for serialization.

```klar
// Writing to file/network
let bytes = value.to_le_bytes()  // Little-endian
let bytes = value.to_be_bytes()  // Big-endian

// Reading from file/network
let value = i32.from_le_bytes(bytes)
```

### 13.4 Platform-Specific Code

**P8**: Isolate platform-specific code in dedicated modules.

```klar
// platform/windows.kl
pub fn get_home_dir() -> string { ... }

// platform/unix.kl
pub fn get_home_dir() -> string { ... }

// platform/mod.kl
comptime {
    if TARGET_OS == "windows" {
        pub use platform.windows.*
    } else {
        pub use platform.unix.*
    }
}
```

---

## Quick Reference Checklist

Before committing code, verify:

- [ ] **Naming**: Types are `PascalCase`, functions are `snake_case`
- [ ] **Ownership**: Every value has a clear owner
- [ ] **Errors**: All fallible operations return `Result[T, E]`
- [ ] **Validation**: All external input is validated before use
- [ ] **Bounds**: Array accesses are bounds-checked
- [ ] **Documentation**: All public items are documented
- [ ] **Tests**: All public functions have tests
- [ ] **No secrets**: No passwords, tokens, or keys in code/logs

---

*Klar-Toolkit Standards v0.4.1 - Aligned with Klar Phase 4 (Language Completion)*
