---
globs: ["**/*.kl"]
---

# Concurrency Rules

## Thread Safety Documentation

**C1**: Document thread safety of every public type:

```klar
/// A thread-safe counter.
/// Safe to share between threads via Arc.
pub struct AtomicCounter { ... }

/// NOT thread-safe. Use Mutex for concurrent access.
pub struct Player { ... }
```

## Shared State

**C2**: Prefer message passing over shared state:

```klar
// PREFERRED: Message passing
let (tx, rx) = channel[Message]()

spawn fn() {
    loop {
        let msg = rx.recv()
        process(msg)
    }
}

tx.send(Message.DoWork(data))
```

**C3**: When sharing state, use `Arc[Mutex[T]]`:

```klar
let shared = Arc.new(Mutex.new(data))
let shared_clone = shared.clone()

spawn fn() {
    let guard = shared_clone.lock()
    guard.modify()
}
```

## Async/Await

**C4**: Use async for I/O-bound operations:

```klar
async fn fetch_all(urls: [string]) -> [Response] {
    let futures = urls.map(fn(url) { fetch(url) })
    await_all(futures)
}
```

**C5**: Don't block in async functions - use async I/O.

## Spawn

**C6**: Use spawn for CPU-bound parallel work:

```klar
fn parallel_process(items: [Item]) -> [Result] {
    let handles = items.map(fn(item) {
        spawn fn() { process(item) }
    })
    handles.map(fn(h) { h.join() })
}
```

## Deadlock Prevention

- Establish global lock ordering
- Keep critical sections minimal
- Avoid holding locks while calling unknown code
- Use timeout-based lock acquisition when appropriate

## Data Race Prevention

- Never access shared data without synchronization
- Use atomic types for simple counters/flags
- Initialize shared data before spawning threads
