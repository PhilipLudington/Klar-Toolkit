# Resource Lifecycle Patterns

Patterns for managing resources (files, connections, memory) in Klar.

## The Resource Model

In Klar, resources are tied to ownership:
- When a value is created, resources are acquired
- When a value is dropped, resources are released
- Ownership ensures resources are freed exactly once

## Pattern 1: Create/Destroy Pairs

For resources that need explicit management:

```klar
struct Connection {
    handle: ConnectionHandle
    config: Config
}

impl Connection {
    /// Creates a new connection.
    /// The caller owns the connection and must ensure it's properly dropped.
    fn create(config: Config) -> Result[Connection, ConnError] {
        let handle = connect_to_server(&config)?
        Ok(Connection { handle, config })
    }
}

// Automatic cleanup when dropped
impl Drop for Connection {
    fn drop(self: &mut Connection) {
        disconnect(self.handle)
    }
}

// Usage
fn use_connection() -> Result[(), Error] {
    let conn = Connection.create(config)?
    conn.send(data)?
    // conn automatically disconnected when function returns
    Ok(())
}
```

## Pattern 2: Scoped Resources

Use closures to ensure cleanup:

```klar
/// Opens a file and passes it to a closure, ensuring it's closed after.
fn with_file[T](path: string, f: fn(&mut File) -> T) -> Result[T, IoError] {
    let file = File.open(path)?
    let result = f(&mut file)
    // file automatically closed when dropped
    Ok(result)
}

// Usage
let contents = with_file("data.txt", fn(f) {
    f.read_to_string()
})?
```

## Pattern 3: Resource Pools

Reuse expensive resources:

```klar
struct ConnectionPool {
    connections: List[Connection]
    max_size: usize
    config: Config
}

impl ConnectionPool {
    fn new(config: Config, max_size: usize) -> ConnectionPool {
        ConnectionPool {
            connections: List.new(),
            max_size: max_size,
            config: config
        }
    }

    /// Gets a connection from the pool, creating one if needed.
    fn get(self: &mut ConnectionPool) -> Result[PooledConnection, Error] {
        let conn = if self.connections.is_empty() {
            Connection.create(self.config.clone())?
        } else {
            self.connections.pop().unwrap()
        };

        Ok(PooledConnection {
            connection: Some(conn),
            pool: self
        })
    }

    /// Returns a connection to the pool.
    fn return_connection(self: &mut ConnectionPool, conn: Connection) {
        if self.connections.len() < self.max_size {
            self.connections.push(conn)
        }
        // else: connection is dropped
    }
}

/// A connection borrowed from a pool.
/// Returns to pool when dropped.
struct PooledConnection {
    connection: ?Connection
    pool: &mut ConnectionPool
}

impl Drop for PooledConnection {
    fn drop(self: &mut PooledConnection) {
        if let Some(conn) = self.connection.take() {
            self.pool.return_connection(conn)
        }
    }
}
```

## Pattern 4: Handle-Based Resources

Use handles (indices/IDs) instead of direct references:

```klar
struct ResourceManager {
    textures: List[Texture]
    free_slots: List[usize]
}

struct TextureHandle {
    index: usize
    generation: u32  // Detect stale handles
}

impl ResourceManager {
    fn load_texture(self: &mut ResourceManager, path: string) -> Result[TextureHandle, Error] {
        let texture = Texture.load(path)?

        let index = if self.free_slots.is_empty() {
            let idx = self.textures.len()
            self.textures.push(texture)
            idx
        } else {
            let idx = self.free_slots.pop().unwrap()
            self.textures[idx] = texture
            idx
        };

        Ok(TextureHandle {
            index: index,
            generation: self.textures[index].generation
        })
    }

    fn get_texture(self: &ResourceManager, handle: TextureHandle) -> ?&Texture {
        if handle.index >= self.textures.len() {
            return None
        }
        let texture = &self.textures[handle.index]
        if texture.generation != handle.generation {
            return None  // Stale handle
        }
        Some(texture)
    }

    fn unload_texture(self: &mut ResourceManager, handle: TextureHandle) {
        if handle.index < self.textures.len() {
            self.textures[handle.index].generation += 1
            self.free_slots.push(handle.index)
        }
    }
}
```

## Pattern 5: Lazy Initialization

Initialize resources only when needed:

```klar
struct LazyConnection {
    config: Config
    connection: Cell[?Connection]
}

impl LazyConnection {
    fn new(config: Config) -> LazyConnection {
        LazyConnection {
            config: config,
            connection: Cell.new(None)
        }
    }

    fn get(self: &LazyConnection) -> Result[&Connection, Error] {
        if self.connection.get().is_none() {
            let conn = Connection.create(self.config.clone())?
            self.connection.set(Some(conn))
        }
        Ok(self.connection.get().as_ref().unwrap())
    }
}
```

## Pattern 6: Reference Counting

Share resources between multiple owners:

```klar
struct SharedBuffer {
    data: Rc[RefCell[Vec[u8]]]
}

impl SharedBuffer {
    fn new() -> SharedBuffer {
        SharedBuffer {
            data: Rc.new(RefCell.new(Vec.new()))
        }
    }

    fn clone(self: &SharedBuffer) -> SharedBuffer {
        SharedBuffer {
            data: self.data.clone()
        }
    }

    fn write(self: &SharedBuffer, bytes: &[u8]) {
        let mut data = self.data.borrow_mut()
        data.extend_from_slice(bytes)
    }

    fn read(self: &SharedBuffer) -> Vec[u8] {
        self.data.borrow().clone()
    }
}
```

**Warning:** Avoid cycles. Use `Weak` for back-references:

```klar
struct TreeNode {
    parent: Weak[TreeNode]      // Doesn't keep parent alive
    children: List[Rc[TreeNode]]  // Keeps children alive
}
```

## Pattern 7: Arena Allocation

Allocate many items together, free together:

```klar
struct Arena[T] {
    chunks: List[Vec[T]]
    current_chunk: Vec[T]
    chunk_size: usize
}

impl Arena[T] {
    fn new(chunk_size: usize) -> Arena[T] {
        Arena {
            chunks: List.new(),
            current_chunk: Vec.with_capacity(chunk_size),
            chunk_size: chunk_size
        }
    }

    fn alloc(self: &mut Arena[T], value: T) -> &mut T {
        if self.current_chunk.len() >= self.chunk_size {
            let full_chunk = std.mem.replace(
                &mut self.current_chunk,
                Vec.with_capacity(self.chunk_size)
            )
            self.chunks.push(full_chunk)
        }

        self.current_chunk.push(value)
        self.current_chunk.last_mut().unwrap()
    }

    fn clear(self: &mut Arena[T]) {
        self.chunks.clear()
        self.current_chunk.clear()
    }
}

// Usage - all allocations freed together
let arena = Arena.new(1024)
for item in items {
    let node = arena.alloc(Node.from(item))
    process(node)
}
arena.clear()  // All nodes freed at once
```

## Pattern 8: Guard Objects

Ensure cleanup with guard objects:

```klar
struct MutexGuard[T] {
    mutex: &Mutex[T]
    data: &mut T
}

impl Mutex[T] {
    fn lock(self: &Mutex[T]) -> MutexGuard[T] {
        self.acquire()
        MutexGuard {
            mutex: self,
            data: unsafe { self.get_data_mut() }
        }
    }
}

impl Drop for MutexGuard[T] {
    fn drop(self: &mut MutexGuard[T]) {
        self.mutex.release()
    }
}

// Usage - automatically unlocks
fn use_shared_data(mutex: &Mutex[Data]) {
    let guard = mutex.lock()
    guard.data.modify()
    // mutex automatically unlocked when guard is dropped
}
```

## Anti-Patterns to Avoid

### 1. Forgetting Cleanup
```klar
// BAD: Resource leak
fn process() {
    let file = File.open("data.txt")?
    if error_condition {
        return Err(error)  // File not closed!
    }
    // ...
}

// GOOD: Ownership handles cleanup
fn process() -> Result[(), Error] {
    let file = File.open("data.txt")?
    if error_condition {
        return Err(error)  // file dropped, closed automatically
    }
    // ...
    Ok(())  // file dropped, closed automatically
}
```

### 2. Use After Drop
```klar
// BAD: Using dropped resource (Klar prevents this at compile time)
let conn = Connection.create()?
drop(conn)
conn.send(data)  // Compile error: use after move

// GOOD: Keep resource alive while using
let conn = Connection.create()?
conn.send(data)?
// conn dropped automatically at end of scope
```

### 3. Resource Cycles
```klar
// BAD: Memory leak through cycle
struct Node {
    next: Rc[Node]  // Creates cycle if nodes point to each other
}

// GOOD: Break cycle with Weak
struct Node {
    next: Weak[Node]  // Doesn't prevent deallocation
}
```
