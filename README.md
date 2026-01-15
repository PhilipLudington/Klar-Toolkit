# CarbideKlar

Hardened Klar development standards and patterns for safe, consistent, and maintainable code. Designed to work with Claude Code/AI and agentic development.

## What is CarbideKlar?

CarbideKlar provides:
- **Coding standards** for writing safe, idiomatic Klar code
- **Claude Code rules** that guide AI-assisted development
- **Slash commands** for code review, project setup, and validation
- **Pattern documentation** for common problems

Think of it as a development framework that helps you (and AI assistants) write better Klar code.

## Quick Start

### Using CarbideKlar Commands (No Setup Required)

These commands work on any Klar code:

```
/klar-review path/to/file.kl    # Review code against CarbideKlar standards
/klar-safety path/to/file.kl    # Security-focused review
```

### Creating a New Project

```bash
# In Claude Code, run:
/klar-init my_project
```

This creates a new project with:
- Standard directory structure
- Build configuration (build.zig)
- CarbideKlar rules and commands

### Adding to an Existing Project

1. **Copy the install command** to your project:
   ```bash
   mkdir -p .claude/commands
   curl -o .claude/commands/klar-install.md https://raw.githubusercontent.com/PhilipLudington/CarbideKlar/main/commands/klar-install.md
   ```

2. **Run the install command** in Claude Code:
   ```
   /klar-install
   ```

This will copy CarbideKlar's rules and commands into your project's `.claude/` directory.

## Standards Overview

CarbideKlar enforces standards in these areas:

| Category | Key Points |
|----------|------------|
| **Naming** | `PascalCase` types, `snake_case` functions |
| **Ownership** | Clear ownership, explicit borrowing |
| **Errors** | `Result[T, E]` for fallible operations |
| **Security** | Input validation, bounds checking |
| **Testing** | Tests for all public functions |
| **Documentation** | Document all public APIs |

See [STANDARDS.md](STANDARDS.md) for complete standards.

## Commands

| Command | Description |
|---------|-------------|
| `/klar-init` | Create a new CarbideKlar project |
| `/klar-install` | Add CarbideKlar to existing project |
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused code review |
| `/klar-check` | Run build, tests, and validation |
| `/klar-update` | Update to latest CarbideKlar |

## Project Structure

```
CarbideKlar/
├── STANDARDS.md          # Complete coding standards
├── CARBIDEKLAR.md        # Quick reference
├── commands/             # Slash command definitions
├── rules/                # Claude Code rules (auto-loaded)
├── templates/            # Project templates
└── docs/
    ├── patterns/         # Design pattern guides
    └── security/         # Security guidance
```

## Why CarbideKlar?

Klar is designed to be safe by default, but standards help ensure:

1. **Consistency** - All code follows the same patterns
2. **Reviewability** - Clear conventions make code easier to review
3. **AI-friendliness** - Unambiguous rules that AI can follow
4. **Best practices** - Guidance beyond what the compiler enforces

## For Claude Code Users

CarbideKlar rules are automatically loaded when working in a CarbideKlar project. The rules guide Claude to:

- Follow Klar naming conventions
- Use proper error handling patterns
- Write secure, validated code
- Create comprehensive tests
- Document public APIs

## Alignment with Klar

CarbideKlar is designed to complement Klar's built-in safety:

| Klar Provides | CarbideKlar Adds |
|---------------|------------------|
| Ownership system | Ownership patterns and idioms |
| Result/Option types | Error handling conventions |
| Bounds checking | Input validation discipline |
| No undefined behavior | Security best practices |
| Module system | API design patterns |

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

CarbideKlar is designed to evolve with Klar. Contributions welcome for:
- Additional patterns and examples
- Improved command functionality
- Bug fixes and clarifications

---

*CarbideKlar v0.2.0 - For Klar Phase 1 Complete*
