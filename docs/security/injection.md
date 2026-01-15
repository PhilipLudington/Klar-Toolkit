# Injection Prevention

Preventing command injection, path traversal, and other injection attacks.

## Overview

Injection vulnerabilities occur when untrusted input is interpreted as code or commands. Klar's type system helps, but validation is still required.

## Command Injection

### The Vulnerability

Passing user input to shell commands:

```klar
// VULNERABLE: User controls shell command
fn convert_file(user_filename: string) {
    system("convert " + user_filename + " output.png")
}

// Attack: user_filename = "; rm -rf /"
// Executes: convert ; rm -rf / output.png
```

### Prevention

**Rule 1:** Never use `system()` with user input.

```klar
// SAFE: Use exec with argument array
fn convert_file(filename: string) -> Result[(), Error] {
    // Validate filename first
    if not is_safe_filename(&filename) {
        return Err(Error.InvalidFilename)
    }

    // Arguments are passed directly, not through shell
    exec("convert", [filename, "output.png"])
}

fn is_safe_filename(name: &string) -> bool {
    // Allow only alphanumeric, dash, underscore, dot
    name.chars().all(fn(c) {
        c.is_alphanumeric() or c == '-' or c == '_' or c == '.'
    })
}
```

**Rule 2:** Whitelist allowed commands.

```klar
enum AllowedCommand {
    Convert
    Resize
    Compress
}

fn run_image_command(cmd: AllowedCommand, input: string, output: string) -> Result[(), Error] {
    let program = cmd match {
        Convert => "convert"
        Resize => "resize"
        Compress => "compress"
    }

    // Only run whitelisted programs
    exec(program, [input, output])
}
```

## Path Traversal

### The Vulnerability

User-controlled file paths accessing unintended locations:

```klar
// VULNERABLE: User controls path
fn read_user_file(filename: string) -> Result[string, Error] {
    read_file("uploads/" + filename)
}

// Attack: filename = "../../../etc/passwd"
// Reads: uploads/../../../etc/passwd = /etc/passwd
```

### Prevention

**Rule 1:** Reject path traversal sequences.

```klar
fn validate_filename(name: &string) -> Result[(), PathError] {
    if name.contains("..") {
        return Err(PathError.TraversalAttempt)
    }
    if name.contains("/") or name.contains("\\") {
        return Err(PathError.PathSeparator)
    }
    if name.starts_with(".") {
        return Err(PathError.HiddenFile)
    }
    Ok(())
}
```

**Rule 2:** Canonicalize and verify containment.

```klar
fn safe_read_file(base_dir: string, user_path: string) -> Result[string, PathError] {
    // Basic validation
    validate_filename(&user_path)?

    // Build full path
    let full_path = join_path(&base_dir, &user_path)

    // Canonicalize (resolves symlinks, .., etc.)
    let canonical = canonicalize(&full_path)?
    let canonical_base = canonicalize(&base_dir)?

    // Verify still within allowed directory
    if not canonical.starts_with(&canonical_base) {
        return Err(PathError.OutsideAllowedDirectory)
    }

    read_file(&canonical)
}
```

**Rule 3:** Use allowlists for sensitive operations.

```klar
const ALLOWED_EXTENSIONS = [".txt", ".json", ".csv"]

fn validate_upload(filename: &string) -> Result[(), UploadError] {
    let extension = get_extension(filename).to_lowercase()

    if not ALLOWED_EXTENSIONS.contains(&extension) {
        return Err(UploadError.DisallowedType)
    }

    Ok(())
}
```

## SQL Injection

### The Vulnerability

String concatenation in SQL queries:

```klar
// VULNERABLE: User input in query string
fn find_user(username: string) -> Result[User, Error] {
    let query = "SELECT * FROM users WHERE name = '" + username + "'"
    db.execute(query)
}

// Attack: username = "'; DROP TABLE users; --"
```

### Prevention

**Rule 1:** Always use parameterized queries.

```klar
fn find_user(db: &Database, username: string) -> Result[User, Error] {
    db.query("SELECT * FROM users WHERE name = ?", [username])
}

fn insert_user(db: &Database, name: string, email: string) -> Result[(), Error] {
    db.execute(
        "INSERT INTO users (name, email) VALUES (?, ?)",
        [name, email]
    )
}
```

**Rule 2:** Validate and sanitize even with parameterized queries.

```klar
fn search_users(db: &Database, search: string) -> Result[List[User], Error] {
    // Validate search term
    if search.len() > 100 {
        return Err(Error.SearchTooLong)
    }

    // Escape LIKE wildcards if needed
    let escaped = search
        .replace("%", "\\%")
        .replace("_", "\\_")

    db.query(
        "SELECT * FROM users WHERE name LIKE ?",
        ["%{escaped}%"]
    )
}
```

## Format String Injection

Klar's type system largely prevents this, but be careful with dynamic formatting:

```klar
// SAFE: Klar's string interpolation is type-safe
let msg = "Hello, {username}"

// BE CAREFUL: Dynamic format strings (if your logging library supports them)
fn log_message(format: string, args: [string]) {
    // If format comes from user input, this could be dangerous
    // depending on the logging implementation
}
```

## General Prevention Strategies

### 1. Input Validation Layer

Create a validation layer for all external input:

```klar
struct UserInput {
    raw: string
}

impl UserInput {
    fn new(raw: string) -> Result[UserInput, InputError] {
        // Length check
        if raw.len() > MAX_INPUT_LENGTH {
            return Err(InputError.TooLong)
        }

        // Character check
        if raw.chars().any(fn(c) { c.is_control() }) {
            return Err(InputError.ControlCharacters)
        }

        Ok(UserInput { raw })
    }

    fn as_str(self: &UserInput) -> &string {
        &self.raw
    }

    fn as_filename(self: &UserInput) -> Result[Filename, InputError] {
        Filename.from_string(&self.raw)
    }
}
```

### 2. Type-Safe Wrappers

Use types to enforce validation:

```klar
/// A validated filename (no path separators, no traversal)
struct Filename {
    name: string
}

impl Filename {
    fn from_string(s: &string) -> Result[Filename, FilenameError] {
        if s.contains('/') or s.contains('\\') {
            return Err(FilenameError.PathSeparator)
        }
        if s.contains("..") {
            return Err(FilenameError.Traversal)
        }
        if s.is_empty() or s.len() > 255 {
            return Err(FilenameError.InvalidLength)
        }
        Ok(Filename { name: s.clone() })
    }

    fn as_str(self: &Filename) -> &string {
        &self.name
    }
}

// Functions that need filenames take Filename, not string
fn save_upload(dir: &string, filename: Filename, data: &[u8]) -> Result[(), Error] {
    let path = join_path(dir, filename.as_str())
    write_file(&path, data)
}
```

### 3. Output Encoding

Encode output for the target context:

```klar
fn html_encode(s: &string) -> string {
    s.replace("&", "&amp;")
     .replace("<", "&lt;")
     .replace(">", "&gt;")
     .replace("\"", "&quot;")
     .replace("'", "&#x27;")
}

fn url_encode(s: &string) -> string {
    // Encode special characters for URLs
    // ...
}

fn shell_escape(s: &string) -> string {
    // Escape for shell arguments (if you must use shell)
    // ...
}
```

## Security Checklist

- [ ] User input never directly used in shell commands
- [ ] All file paths validated and canonicalized
- [ ] SQL queries use parameterized statements
- [ ] Input length limits enforced
- [ ] Dangerous characters rejected or escaped
- [ ] Output encoded for target context
