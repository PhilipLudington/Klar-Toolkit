---
globs: ["**/*.kl"]
---

# Security Rules

> Full reference: [deps/Klar-Reference/REFERENCE.md#16-security-guidelines](deps/Klar-Reference/REFERENCE.md#16-security-guidelines)

## Input Validation

**S1**: Validate ALL external input before use:
- User input (CLI, stdin, GUI)
- File contents
- Network data
- Environment variables

```klar
fn process_input(input: string) -> Result[Command, InputError] {
    // Validate length
    if input.len() > MAX_INPUT_LENGTH {
        return Err(InputError.TooLong)
    }
    // Validate format
    if not is_valid_format(input) {
        return Err(InputError.InvalidFormat)
    }
    parse_command(input)
}
```

## Bounds Checking

Klar performs automatic bounds checking. For performance-critical validated code:

```klar
// SAFETY: index validated to be < len on line N
unsafe { arr.get_unchecked(index) }
```

**Never** use `get_unchecked` on untrusted indices.

## Integer Safety

Use appropriate overflow handling:

```klar
a + b      // Traps on overflow
a +% b     // Wrapping (overflow wraps)
a +| b     // Saturating (clamps to max)
a.checked_add(b)  // Returns ?i32
```

For sizes from external input, use saturating or checked arithmetic.

## Unsafe Blocks

Minimize `unsafe` usage. When required:

1. Keep unsafe blocks as small as possible
2. Document WHY it's safe with `// SAFETY:` comment
3. Never use unsafe to bypass ownership/borrowing

```klar
// SAFETY: pointer is valid and aligned, checked above
unsafe {
    ptr.read()
}
```

## Path Safety

Validate file paths to prevent directory traversal:

```klar
fn safe_path(base: string, user_path: string) -> Result[string, PathError] {
    if user_path.contains("..") {
        return Err(PathError.TraversalAttempt)
    }
    let full = join_path(base, user_path)
    let canonical = canonicalize(full)?
    if not canonical.starts_with(base) {
        return Err(PathError.OutsideBase)
    }
    Ok(canonical)
}
```

## Command Execution

Never pass untrusted input to shell commands:

```klar
// BAD: Command injection
system("process " + user_input)

// GOOD: Use argument arrays
exec("process", [validated_filename])
```

## Secrets

Never log or expose:
- Passwords, tokens, API keys
- Private keys, certificates
- PII without explicit requirement
