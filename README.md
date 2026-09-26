# log

[![package: vs-package](https://img.shields.io/badge/package-vs--package-f4f4f5?style=flat-square&labelColor=e4e4e7&color=18181b)](https://github.com/vertex-language)
[![format: text | json](https://img.shields.io/badge/format-text%20%7C%20json-f4f4f5?style=flat-square&labelColor=e4e4e7&color=18181b)](https://github.com/vertex-language/log)
[![levels: debug | info | warn | error](https://img.shields.io/badge/levels-debug%20%7C%20info%20%7C%20warn%20%7C%20error-f4f4f5?style=flat-square&labelColor=e4e4e7&color=18181b)](https://github.com/vertex-language/log)

Structured, levelled logging: key-value attributes, contextual loggers, severity filtering, and formatters for human text and machine-readable JSON.

---

## Features

- **Standard Severity Levels**: `Debug`, `Info`, `Warn`, and `Error` with numeric ordering and comparison.
- **Structured Attributes**: Strongly typed key-value pairs (`Attr`) for strings, integers, floats, and booleans, with support for dictionary maps.
- **Contextual Loggers**: `logger.With(...)` creates scoped loggers carrying persistent request or component attributes across calls.
- **Configurable Formatters**:
  - `log.Handler.Text()`: Terminal-friendly output with ANSI colors, ISO 8601 UTC timestamps, and automatic quoting for values with whitespace.
  - `log.Handler.JSON()`: Fast single-line JSON records preserving unquoted numeric and boolean literals and escaping strings.
- **Environment Integration**: Honors `VERTEX_LOG` for minimum log level configuration, and `NO_COLOR` / `CLICOLOR_FORCE` / TTY detection for terminal colors.
- **Pluggable Destinations**: Custom emission sinks for capturing, testing, or routing logs to network services and in-memory buffers.

---

## Quick Start

Run the test suite in `cmd/` directly with `vsc run`:

```bash
vsc run check
```

### Basic Logging

```swift
package main

import "log"

func main() -> int32 {
    // Basic log lines
    log.Info("server starting", [log.Attr("addr", "127.0.0.1"), log.Attr("port", 8080)])
    log.Warn("deprecated configuration key used", ["key": "legacy_auth"])
    log.Error("connection timed out", [log.Attr("retries", 3), log.Attr("elapsed_ms", 1500.5)])

    // Contextual logger with shared metadata
    let reqLog = log.With(["request_id": "req-9872", "client_ip": "10.0.0.12"])
    reqLog.Info("authenticating user", ["username": "alex"])
    reqLog.Warn("rate limit quota near capacity", [log.Attr("remaining", 5)])

    return 0
}
```

### Switching to JSON Handler

```swift
package main

import "log"

func main() -> int32 {
    // Switch global output to JSON
    log.SetHandler(log.Handler.JSON(minLevel: .info))

    log.Info("user logged in", [
        log.Attr("user_id", 42),
        log.Attr("email", "user@example.com"),
        log.Attr("verified", true)
    ])
    // Emits:
    // {"time":"2026-09-25T17:10:39Z","level":"INFO","msg":"user logged in","user_id":42,"email":"user@example.com","verified":true}

    return 0
}
```

---

## API Reference

### Levels

| Level | Weight | Default ANSI Color | Typical Usage |
| --- | --- | --- | --- |
| `Level.debug` | 0 | Gray | Fine-grained diagnostic information |
| `Level.info` | 1 | Green | General operational notifications |
| `Level.warn` | 2 | Yellow | Non-fatal warnings and unexpected occurrences |
| `Level.error` | 3 | Red | Failures and actionable error events |

### Configuration via Environment

- `VERTEX_LOG`: Sets the default minimum log level (`debug`, `info`, `warn`, `error`).
- `NO_COLOR`: Disables ANSI color codes in text format if set to any non-empty string.
- `CLICOLOR_FORCE`: Forces ANSI color codes even when stderr is redirected or not a TTY.

---

## Verification & Testing

Execute the comprehensive test suite with `vsc`:

```bash
vsc run check
```

---

## License

[MIT](LICENSE)
