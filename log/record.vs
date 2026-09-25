package log

import "time"

func currentTimestamp() -> string {
    return time.Timestamp.Now().description
}

/// Record holds a single log entry.
public struct Record {
    public var Time: string
    public var Level: Level
    public var Message: string
    public var Attrs: [Attr]

    public init(level: Level, message: string, attrs: [Attr] = [], time: string? = nil) {
        self.Time = time ?? currentTimestamp()
        self.Level = level
        self.Message = message
        self.Attrs = attrs
    }
}
