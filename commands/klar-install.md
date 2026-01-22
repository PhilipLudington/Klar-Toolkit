# /klar-install

Install the Klar-Toolkit Klar development framework into the current project.

## Usage

```
/klar-install
```

## What This Command Does

1. Clones Klar-Toolkit repository
2. Initializes Klar-Reference submodule
3. Copies rules and commands to `.claude/`
4. Sets up version tracking
5. Updates CLAUDE.md with framework reference

## Instructions for Claude

When the user runs `/klar-install`:

### 1. Clone Klar-Toolkit

Clone the repository into the project:

```bash
git clone https://github.com/PhilipLudington/Klar-Toolkit.git klar-toolkit
```

### 2. Initialize Klar-Reference submodule

```bash
cd klar-toolkit && git submodule update --init --recursive && cd ..
```

### 3. Copy Claude Code integration

Create directories and copy files:

```bash
# Create directories
mkdir -p .claude/commands .claude/rules

# Copy commands
cp klar-toolkit/commands/*.md .claude/commands/

# Copy rules
cp klar-toolkit/rules/*.md .claude/rules/
```

### 4. Set version tracking

Create version file:

```bash
echo "0.4.1" > .claude/klar-toolkit-version
```

### 5. Add Klar-Toolkit reference to CLAUDE.md

If `./CLAUDE.md` doesn't exist, create it. Add the following:

```markdown
## Klar Development

This project uses the Klar-Toolkit framework (v0.4.1) for Klar development standards.

### Language Reference

See `klar-toolkit/deps/Klar-Reference/REFERENCE.md` for complete language documentation.

### Quick Reference

See `klar-toolkit/KLARTOOLKIT.md` for Claude Code-specific quick reference.

### Key Syntax Requirements (Phase 4)
- **Explicit types**: `let x: i32 = 42`
- **Explicit return**: `return value` (not implicit last expression)
- **Statement-based control flow**: assign inside blocks
- **Closures with full types**: `|x: i32| -> i32 { return x * 2 }`
```

### 6. Verify installation

Check that all files were copied:

```bash
ls .claude/commands/
ls .claude/rules/
cat .claude/klar-toolkit-version
ls klar-toolkit/deps/Klar-Reference/
```

Expected files:
- `.claude/commands/`: klar-init.md, klar-install.md, klar-review.md, klar-safety.md, klar-check.md, klar-update.md
- `.claude/rules/`: klar-api-design.md, klar-comptime.md, klar-concurrency.md, klar-errors.md, klar-logging.md, klar-naming.md, klar-ownership.md, klar-portability.md, klar-security.md, klar-testing.md, klar-traits.md
- `klar-toolkit/deps/Klar-Reference/`: REFERENCE.md, README.md

### 7. Report completion

```markdown
# Klar-Toolkit Installation Complete

**Version:** 0.4.1 (Phase 4 - Language Completion)

## Installed Components

### Commands (6)
- `/klar-init` - Create new Klar-Toolkit project
- `/klar-install` - Install Klar-Toolkit (this command)
- `/klar-review` - Review code against standards
- `/klar-safety` - Security-focused review
- `/klar-check` - Run validation tooling
- `/klar-update` - Update to latest version

### Rules (11)
- klar-api-design, klar-comptime, klar-concurrency, klar-errors, klar-logging
- klar-naming, klar-ownership, klar-portability, klar-security, klar-testing, klar-traits

### Documentation
- Language Reference: `klar-toolkit/deps/Klar-Reference/REFERENCE.md`
- Quick Reference: `klar-toolkit/KLARTOOLKIT.md`

## Next Steps

1. Review `klar-toolkit/deps/Klar-Reference/REFERENCE.md` for complete language reference
2. Use `/klar-review` to check existing code
3. Use `/klar-init` to create new compliant projects

## Phase 4 Features

- Generic functions, structs, enums with trait bounds
- Builtin traits: Eq, Ordered, Clone, Drop
- Async/await, spawn, channels, select
- Explicit types and return statements required
```

## After Installation

The following commands are now available:

| Command | Purpose |
|---------|---------|
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused review |
| `/klar-check` | Run validation tooling |
| `/klar-update` | Update to latest version |

## Updating

To update Klar-Toolkit to the latest version:

```
/klar-update
```
