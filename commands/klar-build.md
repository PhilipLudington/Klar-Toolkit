# /klar-build

Compile a Klar program to a native executable.

## Usage

```
/klar-build <file.kl> -o <output> [flags]
```

## What This Command Does

Compiles a Klar source file to a native binary using LLVM. The output can be run directly without the Klar compiler.

## Instructions for Claude

When the user runs `/klar-build`:

1. **Build the executable**:

```bash
klar build <file.kl> -o <output> [flags]
```

### Required Options

| Option | Description |
|--------|-------------|
| `-o <path>` | Output path for the executable |

### Optional Flags

| Flag | Description |
|------|-------------|
| `-O2` | Enable optimizations |
| `-g` | Include debug symbols |
| `--emit-llvm` | Output LLVM IR (.ll file) |
| `--emit-asm` | Output assembly (.s file) |
| `--emit-ir` | Output internal IR representation |

2. **Report results**:

On success:
```
Built <output>
```

On failure, show compilation errors with file:line:
```
Compilation Error:
  src/main.kl:42:15 - Type mismatch: expected i32, got string
```

3. **Default output directory**:

When `-o` specifies just a filename (not a path), the executable is placed in the `build/` directory:

```bash
klar build src/main.kl -o myapp    # Creates build/myapp
```

## Examples

```
/klar-build src/main.kl -o myprogram
/klar-build src/main.kl -o release -O2
/klar-build src/main.kl -o debug -g
/klar-build src/main.kl -o program --emit-llvm
```

## When to Use

Use `/klar-build` when you need:
- A persistent executable to run multiple times
- Cross-compilation or deployment
- Optimized release builds
- Debug symbols for debugging tools
- Inspect generated LLVM IR or assembly

Use `/klar-run` instead for quick testing during development.
