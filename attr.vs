package log

/// Attr represents a structured key-value attribute attached to a log record.
public struct Attr {
    public var Key: string
    public var Value: string
    public var IsQuoted: bool // true for string, false for numbers and booleans in JSON

    public init(key: string, value: string) {
        self.Key = key
        self.Value = value
        self.IsQuoted = true
    }

    public init(key: string, value: int) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(key: string, value: int64) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(key: string, value: int32) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(key: string, value: float64) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(key: string, value: float32) {
        self.Key = key
        self.Value = "\(value)"
        self.IsQuoted = false
    }

    public init(key: string, value: bool) {
        self.Key = key
        self.Value = value ? "true" : "false"
        self.IsQuoted = false
    }

    public static func String(key: string, value: string) -> Attr {
        return Attr(key, value)
    }

    public static func Int(key: string, value: int64) -> Attr {
        return Attr(key, value)
    }

    public static func Float(key: string, value: float64) -> Attr {
        return Attr(key, value)
    }

    public static func Bool(key: string, value: bool) -> Attr {
        return Attr(key, value)
    }
}
