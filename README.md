# Klar-Toolkit

Claude Code integration for Klar development. Rules, commands, and workflows for AI-assisted Klar programming.

## What is Klar-Toolkit?

Klar-Toolkit provides:
- **Claude Code rules** that guide AI-assisted development
- **Slash commands** for code review, project setup, and validation
- **Quick reference** for Klar coding standards

For the complete language reference, see [Klar-Reference](https://github.com/PhilipLudington/Klar-Reference).

## Quick Start

### 1. Install Klar-Toolkit

Run these two commands in your project directory:

```bash
mkdir -p .claude/commands
curl -o .claude/commands/klar-install.md https://raw.githubusercontent.com/PhilipLudington/Klar-Toolkit/main/commands/klar-install.md
```

Then in Claude Code, run:
```
/klar-install
```

This installs Klar-Toolkit with all rules, commands, and the Klar-Reference submodule.

### 2. Use the Commands

After installation, these commands are available:

```
/klar-review src/main.kl    # Review code against standards
/klar-safety src/main.kl    # Security-focused review
/klar-check                 # Run build, tests, and validation
/klar-init my_project       # Create a new Klar-Toolkit project
```

### 3. Update Existing Installation

To update Klar-Toolkit to the latest version:

```
/klar-update
```

This fetches the latest version and updates all rules and commands while optionally backing up your current installation.

### Creating New Projects

To create a new project with Klar-Toolkit already configured:

```
/klar-init my_project
```

This creates:
- Standard directory structure (`src/`, `tests/`)
- Klar-Toolkit rules and commands pre-installed

### Note: Submodules

If your project includes submodules that also use Klar-Toolkit, there's no conflict. Claude Code uses the `.claude/` directory at the **git root**, so only the parent project's commands and rules are active.

## Commands

| Command | Description |
|---------|-------------|
| `/klar-init` | Create a new Klar-Toolkit project |
| `/klar-install` | Add Klar-Toolkit to existing project |
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused code review |
| `/klar-check` | Run build, tests, and validation |
| `/klar-update` | Update to latest Klar-Toolkit |

## Project Structure

```
Klar-Toolkit/
├── KLARTOOLKIT.md            # Quick reference for Claude Code
├── commands/                 # Slash command definitions
├── rules/                    # Claude Code rules (auto-loaded)
├── templates/                # Project templates
└── deps/
    └── Klar-Reference/       # Complete language reference (submodule)
        └── REFERENCE.md
```

## Related Projects

| Project | Purpose |
|---------|---------|
| [Klar-Reference](https://github.com/PhilipLudington/Klar-Reference) | Model-agnostic language reference |
| [MCP-Klar](https://github.com/PhilipLudington/MCP-Klar) | Model Context Protocol server for Klar |

## Rules (11)

Rules are automatically loaded when working in a Klar-Toolkit project:

| Rule | Focus |
|------|-------|
| klar-naming | Case conventions, prefixes |
| klar-ownership | Borrowing, smart pointers |
| klar-errors | Result/Option patterns |
| klar-security | Input validation, unsafe |
| klar-api-design | Functions, traits, generics |
| klar-testing | Test organization, coverage |
| klar-concurrency | Async, threads, channels |
| klar-traits | Trait implementation |
| klar-comptime | Compile-time programming |
| klar-logging | Log levels, structured logs |
| klar-portability | Cross-platform concerns |

## Why Klar-Toolkit?

Klar is designed to be safe by default, but standards help ensure:

1. **Consistency** - All code follows the same patterns
2. **Reviewability** - Clear conventions make code easier to review
3. **AI-friendliness** - Unambiguous rules that AI can follow
4. **Best practices** - Guidance beyond what the compiler enforces

## License

MIT License - see [LICENSE](LICENSE)

---

*Klar-Toolkit v0.4.1 - For Klar Phase 4 (Language Completion)*
