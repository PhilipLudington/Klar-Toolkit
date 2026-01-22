---
globs: ["**/*.kl"]
---

# Portability Rules

> Full reference: [deps/Klar-Reference/REFERENCE.md#3-types](deps/Klar-Reference/REFERENCE.md#3-types)

## Integer Types

**P1**: Use fixed-width types for data structures:

```klar
struct Header {
    version: u32    // Not int
    flags: u16
    length: u64
}
```

**P2**: Use `isize`/`usize` for sizes and indices

**P3**: Be explicit about sizes in APIs

## Path Handling

**P4**: Use `/` as path separator (works everywhere):

```klar
let path = "config/settings.toml"
```

**P5**: Never hardcode absolute paths:

```klar
// BAD
let config = "/home/user/.config"

// GOOD
let config = get_config_dir()
```

**P6**: Use path functions, not string ops:

```klar
// GOOD
let full = join_path(base, filename)

// BAD
let full = base + "/" + filename
```

## Endianness

**P7**: Use explicit byte order for serialization:

```klar
// Writing
let bytes = value.to_le_bytes()  // Little-endian
let bytes = value.to_be_bytes()  // Big-endian

// Reading
let value = i32.from_le_bytes(bytes)
```

## Platform-Specific Code

**P8**: Isolate platform code in modules:

```klar
// platform/windows.kl
pub fn get_home() -> string { ... }

// platform/unix.kl
pub fn get_home() -> string { ... }

// platform/mod.kl
comptime {
    if TARGET_OS == "windows" {
        pub use platform.windows.*
    } else {
        pub use platform.unix.*
    }
}
```

## FFI Considerations

When interfacing with C:

```klar
// Use C-compatible types
extern "C" fn callback(data: *void, len: usize) -> i32

// Document ABI expectations
/// # Safety
/// Pointer must be valid for len bytes
unsafe fn process_buffer(ptr: *u8, len: usize)
```

## Newlines

Use `\n` in code; let I/O layer handle platform conversion.
