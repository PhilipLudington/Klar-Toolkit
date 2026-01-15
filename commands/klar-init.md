# /klar-init

Create a new CarbideKlar-compliant Klar project.

## Usage

```
/klar-init <project_name>
```

## What This Command Does

1. Creates project directory structure
2. Generates starter files following CarbideKlar standards
3. Sets up build configuration
4. Installs CarbideKlar rules and commands

## Generated Structure

```
<project_name>/
├── src/
│   ├── main.kl          # Entry point
│   └── lib.kl           # Library root (if library)
├── tests/
│   └── test_lib.kl      # Example test
├── build.zig            # Zig build configuration
├── README.md            # Project readme
├── .gitignore           # Git ignore patterns
└── .claude/
    ├── commands/        # CarbideKlar commands
    └── rules/           # CarbideKlar rules
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
/// zig build run
/// ```
module main

import std.io.println

pub fn main() -> Result[(), Error] {
    println("Hello from <name>!")
    Ok(())
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
    Ok(<Name> { config })
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
    let config = Config { }
    let result = create(config)
    assert(result.is_ok(), "Expected successful creation")
}

fn test_create_with_defaults() {
    // Test default configuration
}
```

5. **Generate build.zig**:
```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main executable
    const exe = b.addExecutable(.{
        .name = "<name>",
        .root_source_file = b.path("src/main.kl"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("tests/test_lib.kl"),
        .target = target,
        .optimize = optimize,
    });
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
```

6. **Generate README.md**:
```markdown
# <name>

[Brief description]

## Building

```bash
zig build
```

## Running

```bash
zig build run
```

## Testing

```bash
zig build test
```

## License

[License]
```

7. **Generate .gitignore**:
```
zig-cache/
zig-out/
.zig-cache/
*.o
*.a
```

8. **Copy CarbideKlar files**:
   - Copy all files from CarbideKlar/commands/ to .claude/commands/
   - Copy all files from CarbideKlar/rules/ to .claude/rules/

9. **Report completion**:
   - Show created file structure
   - Suggest next steps: `cd <name> && zig build`

## Naming Conventions Applied

- Project directory: `snake_case`
- Module names: `snake_case`
- Type names: `PascalCase`
- Function names: `snake_case`
