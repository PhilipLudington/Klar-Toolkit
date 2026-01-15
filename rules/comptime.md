---
globs: ["**/*.kl"]
---

# Compile-Time Programming Rules

Klar uses `comptime` instead of preprocessor macros.

## Comptime Blocks

Use for values computed at compile time:

```klar
const TABLE_SIZE = comptime {
    calculate_optimal_size(1000)
}

const LOOKUP_TABLE: [u8; TABLE_SIZE] = comptime {
    generate_lookup_table()
}
```

## Comptime Functions

**CT1**: Use comptime for values that CAN be computed at compile time:

```klar
comptime fn factorial(n: u64) -> u64 {
    if n <= 1 { 1 } else { n * factorial(n - 1) }
}

const FACT_10 = factorial(10)  // Computed at compile time
```

## Conditional Compilation

```klar
const DEBUG = comptime { env("DEBUG") == "1" }

fn log(msg: string) {
    if DEBUG {
        println("[DEBUG] {msg}")
    }
}

// Platform-specific code
comptime {
    if TARGET_OS == "windows" {
        pub use platform.windows.*
    } else {
        pub use platform.unix.*
    }
}
```

## When NOT to Use Comptime

**CT2**: Don't use comptime for runtime-dependent values:

```klar
// BAD: This depends on runtime input
const SIZE = comptime { get_user_preference() }  // Error

// GOOD: Use runtime variable
let size = get_user_preference()
```

**CT3**: Don't use comptime to obscure logic:

```klar
// BAD: Confusing metaprogramming
comptime {
    for field in Type.fields {
        generate_getter(field)
    }
}

// GOOD: Explicit, readable code
fn get_name(self: &T) -> string { self.name }
fn get_age(self: &T) -> i32 { self.age }
```

## Type-Level Computation

Use comptime for type-level operations:

```klar
comptime fn ArrayType(T: type, N: usize) -> type {
    [T; N]
}

let arr: ArrayType(i32, 10) = [0; 10]
```

## Build Configuration

```klar
const VERSION = comptime { env("VERSION") ?? "dev" }
const BUILD_TIME = comptime { now() }
const GIT_HASH = comptime { exec("git rev-parse --short HEAD") }
```
