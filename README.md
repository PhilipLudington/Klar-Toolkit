# Klar-Toolkit

Claude Code integration for Klar development. Rules, commands, and workflows for AI-assisted Klar programming.

## Installation

```bash
git clone --recurse-submodules https://github.com/PhilipLudington/Klar-Toolkit.git
mkdir -p .claude
cp -r Klar-Toolkit/rules Klar-Toolkit/commands .claude/
```

Then add this to your project's `CLAUDE.md`:

```markdown
## Klar Development

See `Klar-Toolkit/deps/Klar-Reference/REFERENCE.md` for the complete language reference.
```

## Updating

```bash
cd Klar-Toolkit && git pull && git submodule update --remote && cd ..
cp -r Klar-Toolkit/rules Klar-Toolkit/commands .claude/
```

## Commands

After installation, these commands are available in Claude Code:

| Command | Description |
|---------|-------------|
| `/klar-run` | Execute a Klar program |
| `/klar-build` | Compile to native executable |
| `/klar-test` | Run test files |
| `/klar-check` | Run build, tests, and validation |
| `/klar-init` | Create a new Klar project |
| `/klar-review` | Review code against standards |
| `/klar-safety` | Security-focused code review |

## Documentation

- **Language Reference**: `Klar-Toolkit/deps/Klar-Reference/REFERENCE.md`
- **Quick Reference**: `Klar-Toolkit/KLARTOOLKIT.md`

## Related Projects

| Project | Purpose |
|---------|---------|
| [Klar-Reference](https://github.com/PhilipLudington/Klar-Reference) | Model-agnostic language reference |
| [MCP-Klar](https://github.com/PhilipLudington/MCP-Klar) | Model Context Protocol server for Klar |

## Rules

Rules are automatically loaded when working with `.kl` files:

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

## License

MIT
