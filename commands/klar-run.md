# /klar-run

Execute a Klar program directly without creating a persistent binary.

## Usage

```
/klar-run <file.kl> [flags] [-- args...]
```

## What This Command Does

Compiles and executes a Klar program in one step. This is the fastest way to test code during development.

## Instructions for Claude

When the user runs `/klar-run`:

1. **Execute the program**:

```bash
klar run <file.kl> [flags] [args...]
```

### Available Flags

| Flag | Description |
|------|-------------|
| (default) | Native compilation via LLVM (fastest) |
| `--vm` | Use bytecode VM |
| `--interpret` | Use tree-walking interpreter |
| `--` | Pass remaining args to the program |

### Passing Arguments to Programs

Programs with `fn main(args: [String])` receive command-line arguments:

```bash
klar run program.kl arg1 arg2        # args = [program.kl, arg1, arg2]
klar run program.kl -- --flag -v     # Pass flags to program, not klar
```

2. **Report output**:

- Show all printed output from the program
- Report the exit code if non-zero
- Show compilation errors with file:line if any

3. **Handle errors**:

If compilation fails:
```
Compilation Error:
  src/main.kl:42:15 - Type mismatch: expected i32, got string
```

If runtime error:
```
Runtime Error:
  Panic at src/main.kl:58 - Index out of bounds
```

## Examples

```
/klar-run examples/hello.kl
/klar-run program.kl --vm
/klar-run program.kl --interpret
/klar-run program.kl arg1 arg2
/klar-run program.kl -- --help
```

## When to Use

Use `/klar-run` for:
- Quick iteration during development
- Running examples and demos
- Testing code changes

Use `/klar-build` instead when you need:
- A persistent executable
- Optimized builds
- Debug symbols or LLVM IR output
