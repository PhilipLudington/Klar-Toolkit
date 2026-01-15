# /klar-check

Run validation toolchain for Klar project.

## Usage

```
/klar-check
```

## What This Command Does

Runs the complete validation pipeline:
1. Build (compile check)
2. Format check
3. Tests
4. Reports results

## Instructions for Claude

When the user runs `/klar-check`:

1. **Detect build system**:
   - Look for `build.zig` (Zig build)
   - Look for `Makefile` (Make build)
   - If neither found, report error

2. **Run validation steps**:

### Step 1: Build Check

```bash
zig build
```

Report:
- Compilation errors with file:line
- Warnings
- Pass/fail status

### Step 2: Format Check

```bash
zig fmt --check src/
```

Report:
- Files that need formatting
- Suggest: `zig fmt src/` to fix

### Step 3: Run Tests

```bash
zig build test
```

Report:
- Test pass/fail count
- Failed test names and errors
- Test output

3. **Generate report**:

```
# CarbideKlar Check Report

## Build
✓ Compilation successful
  - 0 errors
  - 2 warnings (see details below)

## Format
✗ Format check failed
  - 3 files need formatting
  - Run `zig fmt src/` to fix

## Tests
✓ All tests passed
  - 15 tests run
  - 15 passed, 0 failed

## Overall: PASS (with warnings)

---

## Details

### Build Warnings
src/player.kl:42: unused variable 'temp'
src/config.kl:15: shadowed variable 'name'

### Files Needing Format
- src/player.kl
- src/config.kl
- src/utils.kl
```

4. **Suggest fixes**:

For each issue category:
- Build errors: Show the error and suggest fix
- Format issues: Provide command to auto-fix
- Test failures: Show failure details

5. **Return status**:

Report overall status:
- **PASS**: All checks passed
- **PASS (with warnings)**: Build succeeded, tests passed, minor issues
- **FAIL**: Build failed or tests failed

## Quick Mode

For CI integration, support quick output:

```
/klar-check --quiet
```

Output:
```
build: PASS
format: FAIL
tests: PASS
overall: FAIL
```

## Common Issues

### Build fails with "file not found"
- Check `build.zig` paths match actual file locations
- Ensure all imported modules exist

### Format check fails
- Run `zig fmt src/` to auto-format
- Consider adding pre-commit hook

### Tests fail
- Check test output for assertion details
- Ensure test isolation (tests shouldn't depend on each other)
