# Klar-Toolkit

Hardened Klar development standards and patterns for safe, consistent, and maintainable code. Designed to work with Claude Code/AI and agentic development.

## What is Klar-Toolkit?

Klar-Toolkit provides:
- **Coding standards** for writing safe, idiomatic Klar code
- **Claude Code rules** that guide AI-assisted development
- **Slash commands** for code review, project setup, and validation
- **Pattern documentation** for common problems

Think of it as a development framework that helps you (and AI assistants) write better Klar code.

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

This installs Klar-Toolkit with all rules, commands, and documentation.

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

## Standards Overview

Klar-Toolkit enforces standards in these areas:

| Category | Key Points |
|----------|------------|
| **Naming** | `PascalCase` types, `snake_case` functions |
| **Ownership** | Clear ownership, explicit borrowing |
| **Errors** | `Result[T, E]` for fallible operations |
| **Generics** | Trait bounds, monomorphization |
| **Traits** | Builtin traits (Eq, Ordered, Clone, Drop) |
| **Security** | Input validation, bounds checking |
| **Testing** | Tests for all public functions |
| **Documentation** | Document all public APIs |

See [STANDARDS.md](STANDARDS.md) for complete standards.

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
├── STANDARDS.md          # Complete coding standards
├── KLARTOOLKIT.md        # Quick reference
├── commands/             # Slash command definitions
├── rules/                # Claude Code rules (auto-loaded)
├── templates/            # Project templates
└── docs/
    ├── patterns/         # Design pattern guides
    └── security/         # Security guidance
```

## Why Klar-Toolkit?

Klar is designed to be safe by default, but standards help ensure:

1. **Consistency** - All code follows the same patterns
2. **Reviewability** - Clear conventions make code easier to review
3. **AI-friendliness** - Unambiguous rules that AI can follow
4. **Best practices** - Guidance beyond what the compiler enforces

## For Claude Code Users

Klar-Toolkit rules are automatically loaded when working in a Klar-Toolkit project. The rules guide Claude to:

- Follow Klar naming conventions
- Use proper error handling patterns
- Write secure, validated code
- Create comprehensive tests
- Document public APIs

## Alignment with Klar

Klar-Toolkit is designed to complement Klar's built-in safety:

| Klar Provides | Klar-Toolkit Adds |
|---------------|------------------|
| Ownership system | Ownership patterns and idioms |
| Result/Option types | Error handling conventions |
| Generics with monomorphization | Generic programming patterns |
| Trait system (Eq, Ordered, Clone, Drop) | Trait implementation patterns |
| Bounds checking | Input validation discipline |
| No undefined behavior | Security best practices |
| Module system | API design patterns |
| Async/await | Concurrency patterns |

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Klar-Toolkit is designed to evolve with Klar. Contributions welcome for:
- Additional patterns and examples
- Improved command functionality
- Bug fixes and clarifications

---

*Klar-Toolkit v0.4.1 - For Klar Phase 4 (Language Completion)*
