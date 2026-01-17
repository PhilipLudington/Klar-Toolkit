# /klar-review

Review Klar code against Klar-Toolkit standards.

## Usage

```
/klar-review [path]
```

- No argument: Review all `.kl` files in project
- With path: Review specific file or directory

## What This Command Does

Analyzes code for compliance with STANDARDS.md, checking:
1. Naming conventions
2. Error handling patterns
3. Ownership and borrowing
4. API design
5. Documentation
6. Code organization

## Instructions for Claude

When the user runs `/klar-review`:

1. **Find files to review**:
   - If path specified, review that file/directory
   - Otherwise, find all `.kl` files in `src/` and project root
   - Exclude `tests/`, `build/`, `target/`

2. **Check each category**:

### Naming Conventions
- [ ] Types are `PascalCase`
- [ ] Functions are `snake_case`
- [ ] Variables are `snake_case`
- [ ] Constants are `UPPER_SNAKE_CASE`
- [ ] Enum variants are `PascalCase`
- [ ] Boolean names start with `is_`, `has_`, `can_`, etc.
- [ ] Acronyms treated as words (Http, not HTTP)

### Error Handling
- [ ] Fallible functions return `Result[T, E]`
- [ ] `?` used for error propagation where appropriate
- [ ] Custom error types include context
- [ ] Errors are not silently swallowed
- [ ] Option used for absent values, not errors

### Ownership and Borrowing
- [ ] Ownership transfer is explicit
- [ ] Borrows used when ownership not needed
- [ ] No unnecessary cloning
- [ ] Smart pointers used appropriately

### API Design
- [ ] Functions have ≤4 parameters (or use config structs)
- [ ] Methods use appropriate receiver (`&self`, `&mut self`)
- [ ] Return types are appropriate (owned vs borrowed)
- [ ] Visibility is minimal (private by default)

### Documentation
- [ ] Public functions have doc comments
- [ ] Parameters documented when non-obvious
- [ ] Return values and errors documented
- [ ] Module has doc comment

### Code Organization
- [ ] Files under 500 lines
- [ ] Functions under 50 lines
- [ ] Imports organized (std, third-party, project)
- [ ] Related code grouped with section comments

3. **Generate report**:

```
# Klar-Toolkit Review Report

## Summary
- Files reviewed: N
- Issues found: N (X critical, Y warnings, Z suggestions)
- Compliance: XX%

## Critical Issues
[Issues that likely cause bugs or security problems]

## Warnings
[Standard violations that should be fixed]

## Suggestions
[Best practice improvements]

## Per-File Details

### src/player.kl
- Line 42: Function `getData` should be `get_data` (naming)
- Line 67: Missing error propagation, error silently ignored (error handling)
- Line 89: Public function missing documentation (documentation)

### src/config.kl
- Line 15: Function has 6 parameters, use config struct (api-design)
```

4. **Provide fix suggestions**:

For each issue, suggest the fix:
```
Line 42: `fn getData()` → `fn get_data()`
Line 67: Add `?` or explicit error handling
Line 89: Add `/// Doc comment explaining function`
```

## Severity Levels

- **Critical**: Likely bugs, security issues, or major standard violations
- **Warning**: Standard violations that should be addressed
- **Suggestion**: Best practice improvements, style issues
