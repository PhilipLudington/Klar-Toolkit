---
globs: ["**/*.kl"]
---

# Naming Conventions

> Full reference: [deps/Klar-Reference/REFERENCE.md#2-syntax-fundamentals](deps/Klar-Reference/REFERENCE.md#2-syntax-fundamentals)

## Case Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Types | `PascalCase` | `PlayerState`, `HttpClient` |
| Functions | `snake_case` | `create_player`, `read_file` |
| Variables | `snake_case` | `player_count`, `is_valid` |
| Struct fields | `snake_case` | `health`, `max_speed` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_PLAYERS`, `PI` |
| Enum variants | `PascalCase` | `Some`, `None`, `NotFound` |
| Modules | `snake_case` | `std.collections` |
| Type parameters | `T`, `PascalCase` | `T`, `Key`, `Value` |

## Function Naming Patterns

| Pattern | Meaning |
|---------|---------|
| `create` / `destroy` | Allocate/free owned resource |
| `new` | Create value (no allocation) |
| `from_*` / `to_*` | Type conversion |
| `as_*` | Cheap reference conversion |
| `into_*` | Consuming conversion |
| `get_*` / `set_*` | Accessor/mutator |
| `is_*` / `has_*` / `can_*` | Boolean query |
| `try_*` | May fail (returns Result) |
| `*_or` | Fallback variant |
| `*_unchecked` | Skips validation |

## Boolean Naming

Booleans MUST read as true/false statements:

```klar
// GOOD
let is_valid = true
let has_children = node.children.len() > 0
fn is_empty(self: &List) -> bool

// BAD
let valid = true      // Ambiguous
let children = true   // Noun
fn empty() -> bool    // Verb or adjective?
```

Prefixes: `is_`, `has_`, `can_`, `should_`, `was_`, `will_`

## Acronyms

Treat acronyms as words:

```klar
// GOOD
struct HttpClient
fn parse_json()
let html_content

// BAD
struct HTTPClient
fn parseJSON()
```

## Abbreviations

Acceptable: `len`, `str`, `num`, `max`, `min`, `err`, `msg`, `buf`, `ctx`

Avoid: cryptic abbreviations, single letters (except `i`, `j`, `n` for loops)
