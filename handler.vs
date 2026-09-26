package log

import "os/term"

func shouldColorizeStderr() -> bool {
    if let noColor = getEnvVar("NO_COLOR") {
        if !noColor.isEmpty { return false }
    }
    if let force = getEnvVar("CLICOLOR_FORCE") {
        if force == "1" { return true }
    }
    return term.IsTerminal(.stderr)
}

func escapeJsonString(_ s: string) -> string {
    var out = ""
    for b in s.utf8 {
        if b == 0x22 {
            out += "\\\""
        } else if b == 0x5C {
            out += "\\\\"
        } else if b == 0x0A {
            out += "\\n"
        } else if b == 0x0D {
            out += "\\r"
        } else if b == 0x09 {
            out += "\\t"
        } else {
            out.append(Character(UnicodeScalar(b)))
        }
    }
    return out
}

func defaultStderrEmit(_ line: string) {
    print(line)
}

public enum Format {
    case text
    case json
}

/// Handler formats and delivers log records to an output destination.
public struct Handler {
    public var OutputFormat: Format
    public var MinLevel: Level
    public var UseColors: bool
    public var BaseAttrs: [Attr]
    public var Emit: ((string) -> Void)?

    public init(format: Format, minLevel: Level, useColors: bool = false, baseAttrs: [Attr] = [], emit: ((string) -> Void)? = nil) {
        self.OutputFormat = format
        self.MinLevel = minLevel
        self.UseColors = useColors
        self.BaseAttrs = baseAttrs
        self.Emit = emit
    }

    /// Creates a human-readable text handler.
    public static func Text(minLevel: Level? = nil, colors: bool? = nil, emit: ((string) -> Void)? = nil) -> Handler {
        let lvl = minLevel ?? parseDefaultLevelFromEnv()
        let clr = colors ?? shouldColorizeStderr()
        return Handler(format: .text, minLevel: lvl, useColors: clr, emit: emit)
    }

    /// Creates a machine-readable structured JSON handler.
    public static func JSON(minLevel: Level? = nil, emit: ((string) -> Void)? = nil) -> Handler {
        let lvl = minLevel ?? parseDefaultLevelFromEnv()
        return Handler(format: .json, minLevel: lvl, useColors: false, emit: emit)
    }

    public func Enabled(_ level: Level) -> bool {
        return level.IsEnabled(minLevel: self.MinLevel)
    }

    public func WithAttrs(_ attrs: [Attr]) -> Handler {
        var merged = self.BaseAttrs
        for a in attrs {
            merged.append(a)
        }
        return Handler(format: self.OutputFormat, minLevel: self.MinLevel, useColors: self.UseColors, baseAttrs: merged, emit: self.Emit)
    }

    public func FormatRecord(_ record: Record) -> string {
        var allAttrs = self.BaseAttrs
        for a in record.Attrs {
            allAttrs.append(a)
        }

        switch self.OutputFormat {
        case .text:
            return self.formatText(record: record, attrs: allAttrs)
        case .json:
            return self.formatJSON(record: record, attrs: allAttrs)
        }
    }

    func formatText(record: Record, attrs: [Attr]) -> string {
        let reset = "\u{001B}[0m"
        var levelStr = record.Level.Name()
        if self.UseColors {
            levelStr = "\(record.Level.AnsiColor())\(levelStr)\(reset)"
        }

        var line = "\(record.Time) \(levelStr) \(record.Message)"
        for attr in attrs {
            var val = attr.Value
            if attr.IsQuoted && (val.contains(" ") || val.contains("\"")) {
                val = "\"\(escapeJsonString(val))\""
            }
            if self.UseColors {
                line += " \u{001B}[36m\(attr.Key)\(reset)=\(val)"
            } else {
                line += " \(attr.Key)=\(val)"
            }
        }
        return line
    }

    func formatJSON(record: Record, attrs: [Attr]) -> string {
        var json = "{\"time\":\"\(record.Time)\",\"level\":\"\(record.Level.Name())\",\"msg\":\"\(escapeJsonString(record.Message))\""
        for attr in attrs {
            json += ",\"\(escapeJsonString(attr.Key))\":"
            if attr.IsQuoted {
                json += "\"\(escapeJsonString(attr.Value))\""
            } else {
                json += attr.Value
            }
        }
        json += "}"
        return json
    }

    public func Handle(_ record: Record) {
        if !self.Enabled(record.Level) {
            return
        }
        let line = self.FormatRecord(record)
        if let customEmit = self.Emit {
            customEmit(line)
        } else {
            defaultStderrEmit(line)
        }
    }
}
