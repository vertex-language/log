package log

@_silgen_name("getenv")
func c_getenv(_ name: UnsafePointer<int8>) -> UnsafePointer<int8>?

func getEnvVar(_ name: string) -> string? {
    return name.withCString { ptr in
        if let res = c_getenv(ptr) {
            return string(cString: res)
        }
        return nil
    }
}

/// Level represents the severity of a log record.
public enum Level {
    case debug
    case info
    case warn
    case error

    /// Numeric weight for level comparison (debug: 0, info: 1, warn: 2, error: 3).
    public func Value() -> int32 {
        switch self {
        case .debug: return 0
        case .info:  return 1
        case .warn:  return 2
        case .error: return 3
        }
    }

    /// Returns standard uppercase name (DEBUG, INFO, WARN, ERROR).
    public func Name() -> string {
        switch self {
        case .debug: return "DEBUG"
        case .info:  return "INFO"
        case .warn:  return "WARN"
        case .error: return "ERROR"
        }
    }

    /// ANSI color escape sequence for terminal output.
    public func AnsiColor() -> string {
        switch self {
        case .debug: return "\u{001B}[90m" // Gray
        case .info:  return "\u{001B}[32m" // Green
        case .warn:  return "\u{001B}[33m" // Yellow
        case .error: return "\u{001B}[31m" // Red
        }
    }

    /// Returns true if this level meets or exceeds the minimum level.
    public func IsEnabled(minLevel: Level) -> bool {
        return self.Value() >= minLevel.Value()
    }

    /// Parses level from string (e.g. "debug", "info", "warn", "error").
    public static func Parse(_ str: string) -> Level? {
        var lower = ""
        for b in str.utf8 {
            if b >= 0x41 && b <= 0x5A { // A-Z
                lower.append(Character(UnicodeScalar(b + 32)))
            } else {
                lower.append(Character(UnicodeScalar(b)))
            }
        }
        if lower == "debug" { return .debug }
        if lower == "info" { return .info }
        if lower == "warn" || lower == "warning" { return .warn }
        if lower == "error" { return .error }
        return nil
    }
}

func parseDefaultLevelFromEnv() -> Level {
    if let envStr = getEnvVar("VERTEX_LOG") {
        if let lvl = Level.Parse(envStr) {
            return lvl
        }
        var current = ""
        for b in envStr.utf8 {
            if b == 0x2C { // ,
                if let lvl = Level.Parse(current) { return lvl }
                current = ""
            } else {
                current.append(Character(UnicodeScalar(b)))
            }
        }
        if let lvl = Level.Parse(current) { return lvl }
    }
    return .info
}
