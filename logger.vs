package log

/// Logger produces structured log records and forwards them to a Handler.
public struct Logger {
    public var H: Handler

    public init(handler: Handler? = nil) {
        self.H = handler ?? defaultHandler
    }

    /// Returns a new Logger with the given attributes appended to every record.
    public func With(_ attrs: [Attr]) -> Logger {
        let newHandler = self.H.WithAttrs(attrs)
        return Logger(handler: newHandler)
    }

    /// Returns a new Logger with the given key-value dictionary appended to every record.
    public func With(_ fields: [string: string]) -> Logger {
        var attrs: [Attr] = []
        for (k, v) in fields {
            attrs.append(Attr(k, v))
        }
        return self.With(attrs)
    }

    public func Log(level: Level, message: string, attrs: [Attr] = []) {
        if !self.H.Enabled(level) {
            return
        }
        let record = Record(level: level, message: message, attrs: attrs)
        self.H.Handle(record)
    }

    public func Debug(_ message: string, _ attrs: [Attr] = []) {
        self.Log(level: .debug, message: message, attrs: attrs)
    }

    public func Debug(_ message: string, _ fields: [string: string]) {
        var attrs: [Attr] = []
        for (k, v) in fields { attrs.append(Attr(k, v)) }
        self.Debug(message, attrs)
    }

    public func Info(_ message: string, _ attrs: [Attr] = []) {
        self.Log(level: .info, message: message, attrs: attrs)
    }

    public func Info(_ message: string, _ fields: [string: string]) {
        var attrs: [Attr] = []
        for (k, v) in fields { attrs.append(Attr(k, v)) }
        self.Info(message, attrs)
    }

    public func Warn(_ message: string, _ attrs: [Attr] = []) {
        self.Log(level: .warn, message: message, attrs: attrs)
    }

    public func Warn(_ message: string, _ fields: [string: string]) {
        var attrs: [Attr] = []
        for (k, v) in fields { attrs.append(Attr(k, v)) }
        self.Warn(message, attrs)
    }

    public func Error(_ message: string, _ attrs: [Attr] = []) {
        self.Log(level: .error, message: message, attrs: attrs)
    }

    public func Error(_ message: string, _ fields: [string: string]) {
        var attrs: [Attr] = []
        for (k, v) in fields { attrs.append(Attr(k, v)) }
        self.Error(message, attrs)
    }
}

// Global default handler
var defaultHandler = Handler.Text()

public func SetHandler(_ handler: Handler) {
    defaultHandler = handler
}

public func SetLevel(_ level: Level) {
    defaultHandler.MinLevel = level
}

public func With(_ attrs: [Attr]) -> Logger {
    return Logger().With(attrs)
}

public func With(_ fields: [string: string]) -> Logger {
    return Logger().With(fields)
}

public func Debug(_ message: string, _ attrs: [Attr] = []) {
    Logger().Debug(message, attrs)
}

public func Debug(_ message: string, _ fields: [string: string]) {
    Logger().Debug(message, fields)
}

public func Info(_ message: string, _ attrs: [Attr] = []) {
    Logger().Info(message, attrs)
}

public func Info(_ message: string, _ fields: [string: string]) {
    Logger().Info(message, fields)
}

public func Warn(_ message: string, _ attrs: [Attr] = []) {
    Logger().Warn(message, attrs)
}

public func Warn(_ message: string, _ fields: [string: string]) {
    Logger().Warn(message, fields)
}

public func Error(_ message: string, _ attrs: [Attr] = []) {
    Logger().Error(message, attrs)
}

public func Error(_ message: string, _ fields: [string: string]) {
    Logger().Error(message, fields)
}

/// Factory functions for handlers matching slog/proposed syntax
public func Text(minLevel: Level? = nil, colors: bool? = nil, emit: ((string) -> Void)? = nil) -> Handler {
    return Handler.Text(minLevel: minLevel, colors: colors, emit: emit)
}

public func JSON(minLevel: Level? = nil, emit: ((string) -> Void)? = nil) -> Handler {
    return Handler.JSON(minLevel: minLevel, emit: emit)
}
