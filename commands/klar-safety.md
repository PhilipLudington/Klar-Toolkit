# /klar-safety

Security-focused review of Klar code.

## Usage

```
/klar-safety [path]
```

- No argument: Review all `.kl` files
- With path: Review specific file or directory

## What This Command Does

Analyzes code for security vulnerabilities, focusing on:
1. Input validation
2. Unsafe block usage
3. Integer overflow risks
4. Path traversal vulnerabilities
5. Command injection risks
6. Secret exposure

## Instructions for Claude

When the user runs `/klar-safety`:

1. **Find files to review**:
   - Same file discovery as `/klar-review`
   - Pay extra attention to: network code, file I/O, user input handlers

2. **Check each security category**:

### Input Validation (S1)
Look for external input usage without validation:
- [ ] User input validated before use
- [ ] File contents validated after reading
- [ ] Network data validated before processing
- [ ] Environment variables validated
- [ ] Length limits enforced

```klar
// BAD: Unvalidated input
fn process(input: string) {
    parse(input)  // No validation!
}

// GOOD: Validated input
fn process(input: string) -> Result[(), InputError] {
    if input.len() > MAX_LEN { return Err(InputError.TooLong) }
    if not is_valid_format(input) { return Err(InputError.Invalid) }
    parse(input)
}
```

### Unsafe Block Audit (S2)
- [ ] Each `unsafe` block has `// SAFETY:` comment
- [ ] Unsafe used only when necessary
- [ ] Unsafe not used to bypass ownership

```klar
// GOOD: Documented safety
// SAFETY: index verified < len on line 42
unsafe { arr.get_unchecked(index) }

// BAD: Undocumented
unsafe { ptr.read() }  // Why is this safe?
```

### Integer Safety (S3)
Look for overflow risks in:
- [ ] Size calculations from external input
- [ ] Array index calculations
- [ ] Loop bounds from user data

```klar
// RISKY: Could overflow
let total = count * item_size

// SAFE: Checked arithmetic
let total = count.checked_mul(item_size)?
```

### Path Traversal (S4)
- [ ] User-provided paths validated
- [ ] `..` sequences rejected or handled
- [ ] Paths canonicalized before use
- [ ] Paths verified to be within allowed directory

```klar
// BAD: Path traversal risk
fn read_user_file(name: string) {
    read_file("data/" + name)  // Could read ../../etc/passwd
}

// GOOD: Validated path
fn read_user_file(name: string) -> Result[string, PathError] {
    if name.contains("..") { return Err(PathError.Invalid) }
    let path = canonicalize(join_path("data", name))?
    if not path.starts_with("data/") { return Err(PathError.Outside) }
    read_file(path)
}
```

### Command Injection (S5)
- [ ] No shell commands with user input
- [ ] Arguments passed as arrays, not strings
- [ ] Input sanitized before external processes

```klar
// BAD: Command injection
system("convert " + user_filename)

// GOOD: Argument array
exec("convert", [validated_filename])
```

### Secret Exposure (S6)
- [ ] No secrets in source code
- [ ] No secrets in log messages
- [ ] Sensitive data cleared after use

3. **Generate security report**:

```
# CarbideKlar Security Review

## Summary
- Files reviewed: N
- Security issues: N (X critical, Y high, Z medium)

## Critical Issues
[Exploitable vulnerabilities]

### Path Traversal in src/files.kl:42
User input passed directly to file path without validation.
Risk: Attacker could read arbitrary files.
Fix: Validate path and check it remains within allowed directory.

## High Severity
[Serious issues that could become vulnerabilities]

## Medium Severity
[Issues that weaken security posture]

## Recommendations
1. Add input validation layer for all external data
2. Audit and document all unsafe blocks
3. Use checked arithmetic for size calculations
```

## Severity Levels

- **Critical**: Exploitable vulnerability
- **High**: Likely vulnerability or serious weakness
- **Medium**: Security weakness or missing defense
- **Low**: Minor issue or hardening opportunity
