# /klar-init

Create a new Klar-Toolkit-compliant Klar project.

## Usage

```
/klar-init <project_name>
```

## What This Command Does

1. Creates project directory structure
2. Generates starter files following Klar-Toolkit standards
3. Installs Klar-Toolkit rules and commands

## Generated Structure

```
<project_name>/
├── src/
│   ├── main.kl          # Entry point
│   └── lib.kl           # Library root (if library)
├── tests/
│   └── test_lib.kl      # Example test
├── README.md            # Project readme
├── .gitignore           # Git ignore patterns
└── .claude/
    ├── commands/        # Klar-Toolkit commands
    └── rules/           # Klar-Toolkit rules
```

## Instructions for Claude

When the user runs `/klar-init <name>`:

1. **Create directory structure**:
   - `src/` for source files
   - `tests/` for test files
   - `.claude/commands/` and `.claude/rules/`

2. **Generate src/main.kl**:
```klar
/// Main entry point for <name>.
///
/// # Example
/// ```
/// klar build -o <name> && ./<name>
/// ```
module main

import std.io.println

pub fn main() -> Result[(), Error] {
    println("Hello from <name>!")
    return Ok(())
}
```

3. **Generate src/lib.kl** (for library projects):
```klar
/// <name> library.
///
/// Provides [describe functionality].
module <name>

// Public API
pub struct Config {
    // Configuration fields
}

pub fn create(config: Config) -> Result[<Name>, Error] {
    // Implementation
    return Ok(<Name> { config: config })
}

// Private implementation
struct <Name> {
    config: Config
}
```

4. **Generate tests/test_lib.kl**:
```klar
/// Tests for <name> library.
module test_<name>

import <name>.{Config, create}

fn test_create_success() {
    let config: Config = Config { }
    let result: Result[<Name>, Error] = create(config)
    assert(result.is_ok(), "Expected successful creation")
}

fn test_create_with_defaults() {
    // Test default configuration
}
```

5. **Generate README.md**:
```markdown
# <name>

[Brief description]

## Building

```bash
klar build src/main.kl -o <name>
```

## Running

```bash
./<name>
```

## Testing

```bash
klar test tests/
```

## License

[License]
```

6. **Generate .gitignore**:
```
# Build artifacts
build/
out/
*.o
*.a
*.ll
*.s

# Editor/IDE
.vscode/
.idea/
*.swp
```

7. **Copy Klar-Toolkit files**:
   - Copy all files from Klar-Toolkit/commands/ to .claude/commands/
   - Copy all files from Klar-Toolkit/rules/ to .claude/rules/

8. **Report completion**:
   - Show created file structure
   - Suggest next steps: `cd <name> && klar build src/main.kl -o <name>`

## Naming Conventions Applied

- Project directory: `snake_case`
- Module names: `snake_case`
- Type names: `PascalCase`
- Function names: `snake_case`

## Klar Syntax Requirements

All generated code follows Phase 4 syntax:
- **Explicit types**: `let x: i32 = 42`
- **Explicit return**: `return Ok(value)` (not implicit last expression)
- **Statement-based control flow**: assign inside blocks
- **Closures with full types**: `|x: i32| -> i32 { return x * 2 }`
