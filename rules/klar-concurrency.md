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
let channel_pair: (Sender[Message], Receiver[Message]) = channel[Message]()
let tx: Sender[Message] = channel_pair.0
let rx: Receiver[Message] = channel_pair.1

// Spawn with explicit closure type
let worker: fn() -> void = || -> void {
    loop {
        let msg: Message = rx.recv()
        process(msg)
    }
}
spawn worker

tx.send(Message.DoWork(data))
```

**C3**: When sharing state, use `Arc[Mutex[T]]`:

```klar
let shared: Arc[Mutex[Data]] = Arc.new(Mutex.new(data))
let shared_clone: Arc[Mutex[Data]] = shared.clone()

let modifier: fn() -> void = || -> void {
    let guard: MutexGuard[Data] = shared_clone.lock()
    guard.modify()
}
spawn modifier
```

## Async/Await

**C4**: Use async for I/O-bound operations:

```klar
async fn fetch_data(url: string) -> Result[Data, HttpError] {
    let response: Response = http.get(url).await?
    let body: string = response.read_body().await?
    return Ok(parse(body))
}

async fn main() {
    let data: Data = fetch_data("https://api.example.com").await?
    process(data)
}
```

**C5**: Don't block in async functions - use async I/O.

## Concurrent Operations

**C6**: Use `await_all` for concurrent async operations:

```klar
async fn fetch_multiple() -> (Data, Data, Data) {
    let results: (Data, Data, Data) = await_all(
        fetch("/api/a"),
        fetch("/api/b"),
        fetch("/api/c")
    )
    return results
}

// First to complete
let first: Data = await_first(
    fetch("/primary"),
    fetch("/backup")
)
```

## Spawn and Tasks

**C7**: Use spawn for concurrent tasks:

```klar
// Fire and forget
spawn handle_connection(conn)

// Await result
let task: Task[Data] = spawn fetch_data(url)
let result: Data = task.await
```

## Channels and Select

**C8**: Use select for multiplexing channels:

```klar
loop {
    select {
        msg from inbox => { handle_message(msg) }
        tick from timer => { handle_tick() }
        _ from shutdown => { break }
    }
}
```

## Synchronization Primitives

**C9**: Use appropriate synchronization for shared state:

```klar
// Mutex for exclusive access
let data: Mutex[HashMap[string, i32]] = Mutex.new(HashMap.new())
{
    var guard: MutexGuard[HashMap[string, i32]] = data.lock()
    guard.insert("key", value)
}

// RwLock for read-heavy workloads
let cache: RwLock[HashMap[string, i32]] = RwLock.new(HashMap.new())
{
    let view: ReadGuard[HashMap[string, i32]] = cache.read()   // Many readers
}
{
    var edit: WriteGuard[HashMap[string, i32]] = cache.write() // Exclusive writer
}

// Atomics for simple counters
let counter: Atomic[i64] = Atomic[i64].new(0)
counter.fetch_add(1)
```

## Thread Safety Markers

**C10**: Understand Send and Sync semantics:

| Type | Send | Sync | Notes |
|------|------|------|-------|
| `Rc[T]` | No | No | Single-threaded only |
| `Arc[T]` | Yes | Yes | Thread-safe reference counting |
| `Mutex[T]` | Yes | Yes | Exclusive access |
| `RefCell[T]` | Yes | No | Runtime borrow checking |

## Deadlock Prevention

- Establish global lock ordering
- Keep critical sections minimal
- Avoid holding locks while calling unknown code
- Use timeout-based lock acquisition when appropriate

## Data Race Prevention

- Never access shared data without synchronization
- Use atomic types for simple counters/flags
- Initialize shared data before spawning threads
