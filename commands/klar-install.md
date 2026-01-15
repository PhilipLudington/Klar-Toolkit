# /klar-install

Install CarbideKlar into an existing project.

## Usage

```
/klar-install
```

Run from the root of your existing Klar project.

## What This Command Does

1. Detects project structure
2. Creates `.claude/` directories if needed
3. Copies CarbideKlar rules and commands
4. Optionally adds reference to CLAUDE.md

## Instructions for Claude

When the user runs `/klar-install`:

1. **Verify project location**:
   - Check for `src/` directory or `.kl` files
   - If not found, warn: "This doesn't appear to be a Klar project. Continue anyway?"

2. **Create directories**:
```bash
mkdir -p .claude/commands
mkdir -p .claude/rules
```

3. **Copy CarbideKlar files**:

From CarbideKlar repository, copy:
- `commands/*.md` → `.claude/commands/`
- `rules/*.md` → `.claude/rules/`

4. **Create or update CLAUDE.md**:

If `.claude/CLAUDE.md` doesn't exist, create it:
```markdown
# Project Instructions

This project follows CarbideKlar standards for Klar development.

## Standards

See [CarbideKlar STANDARDS.md](https://github.com/mrphil/CarbideKlar/blob/main/STANDARDS.md) for complete standards.

## Quick Reference

- Types: `PascalCase`
- Functions: `snake_case`
- All fallible operations return `Result[T, E]`
- Validate external input before use
- Document all public items

## Commands

- `/klar-review` - Review code against standards
- `/klar-safety` - Security-focused review
- `/klar-check` - Run build and tests
```

If it exists, append CarbideKlar reference if not present.

5. **Verify installation**:
   - List installed files
   - Confirm rules will be auto-loaded

6. **Report completion**:
```
CarbideKlar installed successfully!

Installed:
  .claude/commands/ - 6 slash commands
  .claude/rules/    - 10 rule files

Available commands:
  /klar-review  - Review code against standards
  /klar-safety  - Security-focused review
  /klar-check   - Run build and tests
  /klar-update  - Update CarbideKlar
```

## Notes

- Does NOT modify existing source files
- Does NOT change build configuration
- Safe to run multiple times (overwrites with latest)
- Works with any directory structure
