# /klar-update

Update Klar-Toolkit to the latest version.

## Usage

```
/klar-update
```

## What This Command Does

1. Fetches latest Klar-Toolkit from repository
2. Updates rules and commands
3. Preserves any local customizations (optional backup)

## Instructions for Claude

When the user runs `/klar-update`:

### 1. Check current installation

Verify Klar-Toolkit is installed:

```bash
ls .claude/rules/ .claude/commands/
```

If directories don't exist, suggest `/klar-install` instead:
```
Klar-Toolkit is not installed. Run /klar-install first.
```

### 2. Offer backup (ask user)

```
Found existing Klar-Toolkit installation.
Do you want to backup current rules before updating? [Y/n]
```

If yes, create backups:
```bash
cp -r .claude/rules .claude/rules.backup.$(date +%Y%m%d)
cp -r .claude/commands .claude/commands.backup.$(date +%Y%m%d)
```

### 3. Fetch latest Klar-Toolkit

Remove old version and clone fresh:

```bash
rm -rf klar-toolkit
git clone https://github.com/PhilipLudington/Klar-Toolkit.git klar-toolkit
rm -rf klar-toolkit/.git
```

### 4. Copy updated files

Copy all Klar-Toolkit integration files:

```bash
# Commands
cp klar-toolkit/commands/*.md .claude/commands/

# Rules
cp klar-toolkit/rules/*.md .claude/rules/
```

### 5. Update version tracking

Create/update version file:

```bash
echo "0.4.1" > .claude/klar-toolkit-version
```

### 6. Show update report

```markdown
# Klar-Toolkit Update Complete

**Updated to:** v0.4.1 (Phase 4 - Language Completion)

## Updated Files

### Rules
- klar-api-design.md: Updated (generics, trait implementation)
- klar-concurrency.md: Updated (async/await, channels, select)
- klar-errors.md: Updated (try blocks, error conversion)
- klar-ownership.md: Updated (Drop trait, smart pointers)
- klar-traits.md: NEW (trait patterns and builtin traits)
- klar-naming.md, klar-security.md, klar-testing.md, klar-comptime.md, klar-logging.md, klar-portability.md

### Commands
- klar-init.md: Updated (Phase 4 syntax)
- klar-install.md, klar-review.md, klar-safety.md, klar-check.md, klar-update.md

### Documentation (in klar-toolkit/docs/)
- patterns/generics.md: NEW (generic programming patterns)
- patterns/ownership.md, api-design.md, errors.md, resources.md
- security/unsafe-blocks.md, injection.md, validation.md

## What's New in v0.4.1

- **Generics**: Generic functions, structs, enums with trait bounds
- **Traits**: Builtin traits (Eq, Ordered, Clone, Drop), custom implementations
- **Async/Await**: Full async patterns, spawn, channels, select
- **Syntax**: Explicit types, explicit return, statement-based control flow
- **Phase 4 Alignment**: Full native compilation support via LLVM
```

### 7. Verify installation

```bash
ls .claude/rules/
ls .claude/commands/
cat .claude/klar-toolkit-version
```

Confirm all files present and version is correct.

## Rollback

If update causes issues:

```
/klar-update --rollback
```

Instructions for Claude:

```bash
# Find most recent backup
BACKUP=$(ls -d .claude/rules.backup.* 2>/dev/null | tail -1)

if [ -n "$BACKUP" ]; then
    rm -rf .claude/rules
    mv "$BACKUP" .claude/rules

    COMMANDS_BACKUP=$(ls -d .claude/commands.backup.* 2>/dev/null | tail -1)
    if [ -n "$COMMANDS_BACKUP" ]; then
        rm -rf .claude/commands
        mv "$COMMANDS_BACKUP" .claude/commands
    fi

    echo "Rolled back to previous version"
else
    echo "No backup found. Cannot rollback."
fi
```

## Version History

| Version | Klar Phase | Key Features |
|---------|------------|--------------|
| 0.4.1 | Phase 4 | Renamed to Klar-Toolkit, use native klar commands |
| 0.4.0 | Phase 4 | Generics, traits, async/await, explicit syntax |
| 0.2.0 | Phase 1 | Initial release, ownership, errors, security |
