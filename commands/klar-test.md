# /klar-test

Run Klar source files for testing.

## Usage

```
/klar-test <file.kl>
/klar-test <pattern>
```

## What This Command Does

Compiles and runs Klar test files, reporting pass/fail based on exit codes. Uses `klar run` internally for native compilation.

## Instructions for Claude

When the user runs `/klar-test`:

1. **Resolve files**:

If a glob pattern is provided (e.g., `test/*.kl`), expand it first using the Glob tool.

2. **Run each test file**:

```bash
klar run <file.kl>
```

### Execution Modes

| Mode | Command |
|------|---------|
| Native (default) | `klar run file.kl` |
| Bytecode VM | `klar run file.kl --vm` |
| Interpreter | `klar run file.kl --interpret` |

3. **Interpret results**:

| Exit Code | Result |
|-----------|--------|
| 0 | PASS |
| Non-zero | FAIL |

4. **Report output**:

```
Running tests...

✓ test/hello.kl (exit: 0)
✓ test/math.kl (exit: 42)
✗ test/broken.kl (exit: 1)
  Output: assertion failed at line 15

Results: 2 passed, 1 failed
```

5. **Show test output**:

- Always show printed output from tests
- On failure, show any error messages or panic info

## Examples

```
/klar-test test/native/hello.kl
/klar-test test/native/generics_basic.kl
/klar-test test/native/*.kl
```

## Test File Conventions

Test files typically:
- Return 0 for success, non-zero for failure
- Use `assert()` or `assert_eq()` for checks
- Print diagnostic info on failure

```klar
fn main() -> i32 {
    let result: i32 = calculate()
    assert_eq(result, 42)
    return 0  // Success
}
```

## When to Use

Use `/klar-test` for:
- Running individual test files
- Verifying code changes work
- Quick validation during development

For full test suites, use the project's test runner script (e.g., `./run-tests.sh`).
