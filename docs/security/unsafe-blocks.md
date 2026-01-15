# Unsafe Block Guidelines

When and how to use `unsafe` blocks in Klar.

## What is Unsafe?

Klar is safe by default. The `unsafe` keyword allows bypassing certain safety checks for:
- FFI (Foreign Function Interface) calls
- Raw pointer operations
- Unchecked array access
- Inline assembly

## The Golden Rule

> Every `unsafe` block must have a `// SAFETY:` comment explaining why it's safe.

```klar
// SAFETY: index verified < len on line 42
unsafe {
    arr.get_unchecked(index)
}
```

## When to Use Unsafe

### 1. FFI Calls

Calling C functions requires unsafe:

```klar
extern "C" {
    fn c_library_function(data: *u8, len: usize) -> i32
}

fn call_c_library(data: &[u8]) -> Result[i32, Error] {
    // SAFETY: data.as_ptr() is valid for data.len() bytes
    // The C function only reads the data and doesn't store the pointer
    let result = unsafe {
        c_library_function(data.as_ptr(), data.len())
    }
    if result < 0 {
        Err(Error.from_errno(result))
    } else {
        Ok(result)
    }
}
```

### 2. Performance-Critical Unchecked Access

When bounds have already been validated:

```klar
fn sum_slice(data: &[i32], start: usize, end: usize) -> i32 {
    assert(start <= end && end <= data.len())

    let mut sum = 0
    for i in start..end {
        // SAFETY: loop bounds verified by assertion above
        unsafe {
            sum += data.get_unchecked(i)
        }
    }
    sum
}
```

### 3. Low-Level Memory Operations

```klar
fn transmute_bytes(bytes: [u8; 4]) -> i32 {
    // SAFETY: i32 has same size as [u8; 4], both are valid bit patterns
    unsafe {
        std.mem.transmute(bytes)
    }
}
```

## When NOT to Use Unsafe

### 1. To "Shut Up the Compiler"

If the compiler rejects your code, there's usually a good reason. Unsafe is not the answer.

```klar
// BAD: Using unsafe to bypass borrow checker
fn bad_example(data: &mut Data) {
    let ptr = data as *mut Data
    unsafe {
        // This is undefined behavior!
        (*ptr).field1 = 1
        (*ptr).field2 = 2
    }
}

// GOOD: Work with the borrow checker
fn good_example(data: &mut Data) {
    data.field1 = 1
    data.field2 = 2
}
```

### 2. For Convenience

Unsafe should never be used just to make code shorter:

```klar
// BAD: Unsafe for convenience
fn get_first(list: &List[i32]) -> i32 {
    unsafe { list.get_unchecked(0) }  // Crashes if empty!
}

// GOOD: Safe handling
fn get_first(list: &List[i32]) -> ?i32 {
    list.first()
}
```

### 3. Without Understanding the Invariants

If you can't explain why it's safe, don't use unsafe:

```klar
// BAD: No understanding of safety requirements
unsafe {
    some_pointer.read()  // Is the pointer valid? Aligned? Non-null?
}

// GOOD: Document the invariants
// SAFETY: pointer was obtained from Box.into_raw() in this function,
// has not been freed, and is properly aligned for T
unsafe {
    some_pointer.read()
}
```

## Safety Documentation Pattern

Always document:
1. **What** invariants must hold
2. **Why** those invariants are guaranteed
3. **Where** the guarantee comes from

```klar
/// Copies bytes from src to dst without bounds checks.
///
/// # Safety
///
/// The caller must ensure:
/// - `src` is valid for reads of `count` bytes
/// - `dst` is valid for writes of `count` bytes
/// - `src` and `dst` do not overlap
/// - Both pointers are properly aligned
unsafe fn copy_nonoverlapping(src: *u8, dst: *mut u8, count: usize) {
    // ...
}
```

## Minimizing Unsafe

### Pattern 1: Encapsulate Unsafe

Wrap unsafe operations in safe abstractions:

```klar
struct SafeBuffer {
    data: *mut u8
    len: usize
    cap: usize
}

impl SafeBuffer {
    fn new(capacity: usize) -> SafeBuffer {
        // Unsafe allocation encapsulated here
        let data = unsafe { alloc(capacity) };
        SafeBuffer { data, len: 0, cap: capacity }
    }

    // Safe public API
    fn push(self: &mut SafeBuffer, byte: u8) -> Result[(), Error] {
        if self.len >= self.cap {
            return Err(Error.BufferFull)
        }
        // SAFETY: len < cap verified above
        unsafe {
            self.data.add(self.len).write(byte)
        }
        self.len += 1
        Ok(())
    }

    fn get(self: &SafeBuffer, index: usize) -> ?u8 {
        if index >= self.len {
            return None
        }
        // SAFETY: index < len verified above
        Some(unsafe { self.data.add(index).read() })
    }
}

impl Drop for SafeBuffer {
    fn drop(self: &mut SafeBuffer) {
        // SAFETY: data was allocated in new(), has not been freed
        unsafe { dealloc(self.data, self.cap) }
    }
}
```

### Pattern 2: Validate at Boundaries

Do all validation before entering unsafe:

```klar
fn process_buffer(data: *u8, len: usize) -> Result[(), Error] {
    // Validate BEFORE unsafe
    if data.is_null() {
        return Err(Error.NullPointer)
    }
    if len == 0 {
        return Err(Error.EmptyBuffer)
    }

    // SAFETY: data is non-null, len > 0, validated above
    unsafe {
        do_unsafe_processing(data, len)
    }

    Ok(())
}
```

### Pattern 3: Use Type System

Let types enforce invariants:

```klar
/// A non-null pointer.
struct NonNull[T] {
    ptr: *T  // Invariant: never null
}

impl NonNull[T] {
    fn new(ptr: *T) -> ?NonNull[T] {
        if ptr.is_null() {
            None
        } else {
            Some(NonNull { ptr })
        }
    }

    fn as_ptr(self: NonNull[T]) -> *T {
        self.ptr  // Guaranteed non-null by construction
    }
}
```

## Audit Checklist

Before merging code with `unsafe`:

- [ ] Every unsafe block has a `// SAFETY:` comment
- [ ] The safety justification is accurate and complete
- [ ] Unsafe is minimized (smallest possible scope)
- [ ] Safe alternatives were considered
- [ ] Edge cases are handled (null, overflow, alignment)
- [ ] Tests cover the unsafe code paths
- [ ] Code review specifically examined unsafe sections
