package log

/// Attr represents a structured key-value attribute attached to a log record.
public struct Attr {
    public var Key: string
    public var Value: string
    public var IsQuoted: bool // true for string, false for numbers and booleans in JSON

    public init(_ key: string, _ value: string) {
        self.Key = key
        self.Value = value
        self.IsQuoted = true
    }

    public init(_ key: string, _ value: int) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(_ key: string, _ value: int64) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(_ key: string, _ value: int32) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(_ key: string, _ value: float64) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(_ key: string, _ value: float32) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(_ key: string, _ value: bool) {
        self.Key = key
        self.Value = value ? "true" : "false"
        self.IsQuoted = false
    }

    public static func String(_ key: string, _ value: string) -> Attr {
        return Attr(key, value)
    }

    public static func Int(_ key: string, _ value: int64) -> Attr {
        return Attr(key, value)
    }

    public static func Float(_ key: string, _ value: float64) -> Attr {
        return Attr(key, value)
    }

    public static func Bool(_ key: string, _ value: bool) -> Attr {
        return Attr(key, value)
    }
}
