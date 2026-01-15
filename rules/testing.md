---
globs: ["**/*.kl", "**/tests/**"]
---

# Testing Rules

## Test Organization

**T1**: One test file per module: `tests/test_<module>.kl`

**T2**: Test naming: `test_<function>_<scenario>`

```klar
fn test_create_player_success() { ... }
fn test_create_player_empty_name() { ... }
fn test_create_player_name_too_long() { ... }
```

## Required Test Categories

Every module needs tests for:

1. **Happy path** - Normal successful operation
2. **Edge cases** - Empty, zero, max values, boundaries
3. **Error conditions** - Invalid input, missing resources
4. **State transitions** - Objects behave correctly in different states

## Test Structure

Use Arrange-Act-Assert:

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

## Assertions

**T3**: One logical assertion per test

**T4**: Use descriptive messages:

```klar
assert(result.is_ok(), "Expected successful parse")
assert(value == expected, "Health should be {expected}, got {value}")
```

## Coverage Requirements

**T5**: All public API functions MUST have tests

**T6**: Error paths MUST be tested:

```klar
fn test_read_file_not_found() {
    let result = read_file("/nonexistent")
    assert(result.is_err())
    result.unwrap_err() match {
        IoError.NotFound(_) => {}
        _ => panic("Expected NotFound error")
    }
}
```

## Test Isolation

- Tests should not depend on each other
- Clean up any created resources
- Use unique names/paths to avoid conflicts

## Property Testing

For complex logic, consider property-based tests:

```klar
fn test_sort_preserves_length() {
    for _ in 0..100 {
        let list = random_list()
        let sorted = sort(list.clone())
        assert(sorted.len() == list.len())
    }
}
```
