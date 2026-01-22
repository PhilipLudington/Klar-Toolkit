---
globs: ["**/*.kl"]
---

# Logging Rules

> Full reference: [deps/Klar-Reference/REFERENCE.md#16-security-guidelines](deps/Klar-Reference/REFERENCE.md#16-security-guidelines)

## Log Levels

| Level | Use For |
|-------|---------|
| `error` | Failures preventing operation |
| `warn` | Unexpected but recoverable |
| `info` | Significant events (startup, config) |
| `debug` | Troubleshooting details |
| `trace` | Detailed execution flow |

## Message Format

**L1**: Include context in messages:

```klar
// GOOD
log.error("Failed to load config: path={path}, error={err}")
log.info("Server started: port={port}, workers={n}")
log.debug("Processing request: id={id}, client={ip}")

// BAD
log.error("Load failed")
log.info("Started")
```

## What NOT to Log

**L2**: Never log secrets:
- Passwords, tokens, API keys
- Private keys, certificates
- Session identifiers

**L3**: Never log PII without explicit requirement

**L4**: Never log in tight loops (use sampling):

```klar
// BAD
for item in items {
    log.debug("Processing {item}")  // Millions of logs
}

// GOOD
log.debug("Processing {items.len()} items")
for item in items {
    process(item)
}
```

**L5**: Never log large data blobs

## Structured Logging

Prefer structured format for machine parsing:

```klar
log.info("request_complete", {
    request_id: req.id,
    duration_ms: elapsed,
    status: response.status,
    path: req.path
})
```

## Error Logging

Always log errors with context:

```klar
result match {
    Ok(v) => v
    Err(e) => {
        log.error("Operation failed: op={op}, input={input}, error={e}")
        return Err(e)
    }
}
```

## Log Correlation

Include identifiers for tracing:

```klar
fn handle_request(req: Request) {
    let id = req.id
    log.info("Request started: id={id}")
    // ... processing ...
    log.info("Request complete: id={id}, status={status}")
}
```
