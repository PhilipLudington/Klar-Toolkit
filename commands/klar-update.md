# /klar-update

Update CarbideKlar to the latest version.

## Usage

```
/klar-update
```

## What This Command Does

1. Fetches latest CarbideKlar from repository
2. Updates rules and commands
3. Preserves any local customizations (optional)

## Instructions for Claude

When the user runs `/klar-update`:

1. **Check current installation**:
   - Verify `.claude/rules/` exists
   - Verify `.claude/commands/` exists
   - If not installed, suggest `/klar-install` instead

2. **Backup current files** (optional):

Ask user:
```
Found existing CarbideKlar installation.
Do you want to backup current rules before updating? [Y/n]
```

If yes:
```bash
cp -r .claude/rules .claude/rules.backup
cp -r .claude/commands .claude/commands.backup
```

3. **Fetch latest version**:

From CarbideKlar repository:
- Download latest `rules/*.md`
- Download latest `commands/*.md`

4. **Update files**:

Replace:
- `.claude/rules/*.md` with new versions
- `.claude/commands/*.md` with new versions

5. **Show changes**:

```
# CarbideKlar Update Report

## Updated Files

### Rules
- ownership.md: Updated (new smart pointer guidance)
- errors.md: Updated (clarified ? usage)
- security.md: No changes
- naming.md: No changes
- api-design.md: Updated (added trait section)
- testing.md: No changes
- concurrency.md: Updated (new async patterns)
- comptime.md: No changes
- logging.md: No changes
- portability.md: No changes

### Commands
- klar-init.md: Updated (new template)
- klar-review.md: No changes
- klar-safety.md: Updated (new checks)
- klar-check.md: No changes
- klar-install.md: No changes
- klar-update.md: No changes

## Summary
- Rules updated: 4
- Commands updated: 2
- Backup saved to: .claude/rules.backup/

## What's New
- Improved smart pointer guidance in ownership rules
- New async/await patterns for concurrency
- Enhanced project template in klar-init
```

6. **Verify installation**:

```bash
ls .claude/rules/
ls .claude/commands/
```

Confirm all files present.

## Rollback

If update causes issues:

```
/klar-update --rollback
```

Restores from backup:
```bash
rm -rf .claude/rules
mv .claude/rules.backup .claude/rules
rm -rf .claude/commands
mv .claude/commands.backup .claude/commands
```

## Version Tracking

Consider adding version file:

`.claude/carbideklar-version`:
```
0.1.0
```

Update command checks this to show:
- Current version
- Available version
- Changelog summary
