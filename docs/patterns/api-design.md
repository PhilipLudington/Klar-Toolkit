# API Design Patterns

Patterns for designing clean, usable APIs in Klar.

## Principle: Explicit Over Implicit

Klar APIs should be:
- Clear about ownership (who owns what)
- Clear about mutability (what gets modified)
- Clear about failure (what can go wrong)

## Pattern 1: Config Structs

Replace many parameters with a config struct:

```klar
// BAD: Too many parameters
fn create_server(host: string, port: i32, max_conn: i32,
                 timeout_ms: i32, tls: bool, cert_path: ?string)

// GOOD: Config struct with defaults
struct ServerConfig {
    host: string
    port: i32
    max_connections: i32
    timeout_ms: i32
    tls_enabled: bool
    cert_path: ?string
}

const SERVER_CONFIG_DEFAULT = ServerConfig {
    host: "localhost",
    port: 8080,
    max_connections: 100,
    timeout_ms: 30000,
    tls_enabled: false,
    cert_path: none
}

fn create_server(config: ServerConfig) -> Result[Server, ServerError]

// Usage with defaults
let server = create_server(ServerConfig {
    port: 9000,
    ..SERVER_CONFIG_DEFAULT
})?
```

## Pattern 2: Method Receivers

Choose the right receiver for methods:

```klar
impl Connection {
    // &self - read-only access
    fn is_connected(self: &Connection) -> bool {
        self.state == ConnectionState.Connected
    }

    // &mut self - modification
    fn send(self: &mut Connection, data: &[u8]) -> Result[usize, IoError] {
        // Modifies internal buffer/state
    }

    // self - consumes the connection
    fn close(self: Connection) -> Result[(), IoError] {
        // Connection cannot be used after this
    }
}
```

**Guidelines:**
- `&self` for queries/getters
- `&mut self` for modifications
- `self` for consuming operations (close, into_*, build)

## Pattern 3: Return Types

Be consistent about what's returned:

```klar
// Factory functions return owned values
fn create_connection(config: Config) -> Result[Connection, Error]

// Getters return references to internal state
fn get_name(self: &User) -> &string {
    &self.name
}

// Computations return owned values
fn calculate_hash(data: &[u8]) -> [u8; 32]

// Transformations consume and return owned
fn into_string(self: StringBuilder) -> string
```

## Pattern 4: Trait Design

Keep traits focused on one capability:

```klar
// GOOD: Single-responsibility traits
trait Read {
    fn read(self: &mut Self, buf: &mut [u8]) -> Result[usize, IoError]
}

trait Write {
    fn write(self: &mut Self, data: &[u8]) -> Result[usize, IoError]
}

trait Seek {
    fn seek(self: &mut Self, pos: SeekFrom) -> Result[usize, IoError]
}

// Combine via bounds when needed
fn copy[R: Read, W: Write](reader: &mut R, writer: &mut W) -> Result[usize, IoError]
```

Provide default implementations where sensible:

```klar
trait Read {
    fn read(self: &mut Self, buf: &mut [u8]) -> Result[usize, IoError]

    // Default implementation using read()
    fn read_exact(self: &mut Self, buf: &mut [u8]) -> Result[(), IoError] {
        let mut total = 0
        while total < buf.len() {
            let n = self.read(&mut buf[total..])?
            if n == 0 {
                return Err(IoError.UnexpectedEof)
            }
            total += n
        }
        Ok(())
    }
}
```

## Pattern 5: Constructor Hierarchy

Use different constructors for different scenarios:

```klar
impl HttpClient {
    /// Create with default configuration.
    fn new() -> HttpClient {
        HttpClient.with_config(HttpConfig.default())
    }

    /// Create with custom configuration.
    fn with_config(config: HttpConfig) -> HttpClient {
        HttpClient {
            config: config,
            // ...
        }
    }

    /// Create from environment variables.
    fn from_env() -> Result[HttpClient, ConfigError] {
        let config = HttpConfig.from_env()?
        Ok(HttpClient.with_config(config))
    }
}
```

## Pattern 6: Accessor Naming

Be consistent with accessor names:

```klar
impl User {
    // Simple getter
    fn name(self: &User) -> &string {
        &self.name
    }

    // Getter with computation
    fn full_name(self: &User) -> string {
        "{self.first_name} {self.last_name}"
    }

    // Boolean query
    fn is_active(self: &User) -> bool {
        self.status == Status.Active
    }

    // Setter
    fn set_name(self: &mut User, name: string) {
        self.name = name
    }

    // Setter with validation
    fn set_email(self: &mut User, email: string) -> Result[(), ValidationError] {
        if not is_valid_email(&email) {
            return Err(ValidationError.InvalidEmail)
        }
        self.email = email
        Ok(())
    }
}
```

## Pattern 7: Module Organization

Organize public API at module level:

```klar
/// HTTP client for making web requests.
module http

// Re-export main types
pub use client.{Client, ClientBuilder}
pub use request.{Request, RequestBuilder}
pub use response.Response
pub use error.{HttpError, StatusCode}

// Internal modules
mod client
mod request
mod response
mod error
mod connection  // Not exported - internal
```

Usage:
```klar
import http.{Client, Request}

let client = Client.new()
let response = client.get("https://example.com")?
```

## Pattern 8: Extension Through Traits

Allow users to extend behavior:

```klar
/// Trait for types that can be serialized to JSON.
pub trait ToJson {
    fn to_json(self: &Self) -> string
}

// Implement for standard types
impl ToJson for i32 {
    fn to_json(self: &i32) -> string {
        self.to_string()
    }
}

// Users can implement for their types
impl ToJson for MyStruct {
    fn to_json(self: &MyStruct) -> string {
        // ...
    }
}
```

## Pattern 9: Progressive Disclosure

Simple things simple, complex things possible:

```klar
// Level 1: One-liner for common case
let response = http.get("https://api.example.com")?

// Level 2: Builder for customization
let response = http.Client.new()
    .timeout(Duration.seconds(30))
    .header("Authorization", "Bearer {token}")
    .get("https://api.example.com")?

// Level 3: Full control
let client = http.Client.with_config(HttpConfig {
    pool_size: 10,
    retry_policy: RetryPolicy.exponential(3),
    // ...
})
let request = Request.builder()
    .method("POST")
    .url("https://api.example.com")
    .json(payload)?
    .build()
let response = client.execute(request)?
```

## Pattern 10: Documentation

Document every public item:

```klar
/// Creates a new user with the given name.
///
/// The name must be between 1 and 100 characters. Unicode is supported
/// but the name will be normalized to NFC form.
///
/// # Arguments
///
/// * `name` - The user's display name
///
/// # Returns
///
/// Returns the created user, or an error if:
/// * Name is empty or too long
/// * Name contains invalid characters
///
/// # Example
///
/// ```
/// let user = create_user("Alice")?
/// assert(user.name() == "Alice")
/// ```
pub fn create_user(name: string) -> Result[User, UserError]
```

## Anti-Patterns to Avoid

### 1. Leaking Implementation Details
```klar
// BAD: Exposes internal structure
pub struct Parser {
    pub buffer: Vec[u8],      // Implementation detail!
    pub position: usize,      // Implementation detail!
}

// GOOD: Hide internals
pub struct Parser {
    buffer: Vec[u8],
    position: usize,
}

impl Parser {
    pub fn remaining(self: &Parser) -> usize {
        self.buffer.len() - self.position
    }
}
```

### 2. Inconsistent Naming
```klar
// BAD: Inconsistent patterns
fn getUserName()     // camelCase
fn get_user_age()    // snake_case
fn fetchUserData()   // different verb

// GOOD: Consistent
fn get_user_name()
fn get_user_age()
fn get_user_data()
```

### 3. God Objects
```klar
// BAD: Too many responsibilities
struct Application {
    fn start()
    fn stop()
    fn handle_request()
    fn connect_database()
    fn send_email()
    fn generate_report()
    // ... 50 more methods
}

// GOOD: Separate concerns
struct Server { fn start(); fn stop(); fn handle() }
struct Database { fn connect(); fn query() }
struct Mailer { fn send() }
struct Reporter { fn generate() }
```
