package main

import "log"

var checkCount: int32 = 0
var failureCount: int32 = 0

func assert(_ condition: bool, _ message: string) {
    checkCount += 1
    if condition {
        print("ok    \(message)")
    } else {
        failureCount += 1
        print("FAIL  \(message)")
    }
}

func main() -> int32 {
    print("=== Testing log package ===")

    // 1. Level values and names
    assert(log.Level.debug.Value() == 0, "Level.debug value is 0")
    assert(log.Level.info.Value() == 1, "Level.info value is 1")
    assert(log.Level.warn.Value() == 2, "Level.warn value is 2")
    assert(log.Level.error.Value() == 3, "Level.error value is 3")

    assert(log.Level.debug.Name() == "DEBUG", "Level.debug name is DEBUG")
    assert(log.Level.info.Name() == "INFO", "Level.info name is INFO")
    assert(log.Level.warn.Name() == "WARN", "Level.warn name is WARN")
    assert(log.Level.error.Name() == "ERROR", "Level.error name is ERROR")

    // 2. Level comparison / filtering
    assert(log.Level.info.IsEnabled(minLevel: .debug), "info is enabled at debug level")
    assert(log.Level.info.IsEnabled(minLevel: .info), "info is enabled at info level")
    assert(!log.Level.info.IsEnabled(minLevel: .warn), "info is disabled at warn level")
    assert(!log.Level.info.IsEnabled(minLevel: .error), "info is disabled at error level")
    assert(log.Level.error.IsEnabled(minLevel: .warn), "error is enabled at warn level")

    // 3. Level parsing
    if let l = log.Level.Parse("debug") { assert(l.Value() == log.Level.debug.Value(), "parse 'debug'") } else { assert(false, "parse 'debug'") }
    if let l = log.Level.Parse("DEBUG") { assert(l.Value() == log.Level.debug.Value(), "parse 'DEBUG'") } else { assert(false, "parse 'DEBUG'") }
    if let l = log.Level.Parse("info") { assert(l.Value() == log.Level.info.Value(), "parse 'info'") } else { assert(false, "parse 'info'") }
    if let l = log.Level.Parse("warn") { assert(l.Value() == log.Level.warn.Value(), "parse 'warn'") } else { assert(false, "parse 'warn'") }
    if let l = log.Level.Parse("warning") { assert(l.Value() == log.Level.warn.Value(), "parse 'warning'") } else { assert(false, "parse 'warning'") }
    if let l = log.Level.Parse("error") { assert(l.Value() == log.Level.error.Value(), "parse 'error'") } else { assert(false, "parse 'error'") }
    assert(log.Level.Parse("unknown") == nil, "parse 'unknown' returns nil")

    // 4. Attr attributes construction
    let aStr = log.Attr("user", "Alice")
    assert(aStr.Key == "user" && aStr.Value == "Alice" && aStr.IsQuoted, "Attr string")

    let aInt = log.Attr("port", 8080)
    assert(aInt.Key == "port" && aInt.Value == "8080" && !aInt.IsQuoted, "Attr int")

    let aInt64 = log.Attr.Int("bytes", 1048576)
    assert(aInt64.Key == "bytes" && aInt64.Value == "1048576" && !aInt64.IsQuoted, "Attr int64")

    let aFloat = log.Attr("duration", 12.5)
    assert(aFloat.Key == "duration" && aFloat.Value == "12.5" && !aFloat.IsQuoted, "Attr float")

    let aBool = log.Attr("tls", true)
    assert(aBool.Key == "tls" && aBool.Value == "true" && !aBool.IsQuoted, "Attr bool")

    // 5. Record formatting with Text Handler
    var captured: [string] = []
    let textHandler = log.Handler.Text(minLevel: .debug, colors: false, emit: { s in
        captured.append(s)
    })

    let rec1 = log.Record(level: .info, message: "server started", attrs: [
        log.Attr("addr", "127.0.0.1"),
        log.Attr("port", 8080)
    ], time: "2026-09-25T12:00:00Z")

    let formatted1 = textHandler.FormatRecord(rec1)
    assert(formatted1 == "2026-09-25T12:00:00Z INFO server started addr=127.0.0.1 port=8080", "Text format basic")

    // 6. Text formatting with quotes when spaces in value
    let rec2 = log.Record(level: .warn, message: "slow request", attrs: [
        log.Attr("path", "/api/v1 items"),
        log.Attr("ms", 450)
    ], time: "2026-09-25T12:00:01Z")

    let formatted2 = textHandler.FormatRecord(rec2)
    assert(formatted2 == "2026-09-25T12:00:01Z WARN slow request path=\"/api/v1 items\" ms=450", "Text format with quoted spaces")

    // 7. JSON formatting
    let jsonHandler = log.Handler.JSON(minLevel: .debug, emit: { s in
        captured.append(s)
    })

    let jsonFormatted = jsonHandler.FormatRecord(rec1)
    let expectedJson = "{\"time\":\"2026-09-25T12:00:00Z\",\"level\":\"INFO\",\"msg\":\"server started\",\"addr\":\"127.0.0.1\",\"port\":8080}"
    assert(jsonFormatted == expectedJson, "JSON format exact structure")

    // 8. JSON formatting with special character escaping
    let recSpecial = log.Record(level: .error, message: "parse \"failed\"\nline 2", attrs: [
        log.Attr("raw", "tab\there")
    ], time: "2026-09-25T12:00:02Z")
    let jsonSpecial = jsonHandler.FormatRecord(recSpecial)
    let expectedSpecial = "{\"time\":\"2026-09-25T12:00:02Z\",\"level\":\"ERROR\",\"msg\":\"parse \\\"failed\\\"\\nline 2\",\"raw\":\"tab\\there\"}"
    assert(jsonSpecial == expectedSpecial, "JSON escaping quotes, newlines, tabs")

    // 9. Handler level filtering
    captured = []
    let filteredHandler = log.Handler.Text(minLevel: .warn, colors: false, emit: { s in
        captured.append(s)
    })
    filteredHandler.Handle(log.Record(level: .debug, message: "should be ignored"))
    filteredHandler.Handle(log.Record(level: .info, message: "should be ignored"))
    filteredHandler.Handle(log.Record(level: .warn, message: "should be kept", time: "2026-09-25T12:00:03Z"))
    filteredHandler.Handle(log.Record(level: .error, message: "should also be kept", time: "2026-09-25T12:00:04Z"))

    assert(captured.count == 2, "Filtered handler received only records >= WARN (count=2)")
    assert(captured[0] == "2026-09-25T12:00:03Z WARN should be kept", "Kept warn record")
    assert(captured[1] == "2026-09-25T12:00:04Z ERROR should also be kept", "Kept error record")

    // 10. Logger With contextual attributes
    captured = []
    let baseLogger = log.Logger(handler: log.Handler.Text(minLevel: .debug, colors: false, emit: { s in
        captured.append(s)
    }))

    let reqLogger = baseLogger.With([log.Attr("request_id", "req-abc-123")])
    reqLogger.Info("handling request", [log.Attr("endpoint", "/status")])

    assert(captured.count == 1, "Contextual logger emitted 1 record")
    assert(captured[0].contains("request_id=req-abc-123"), "Record contains parent context request_id")
    assert(captured[0].contains("endpoint=/status"), "Record contains call-site attribute")

    // 11. Logger With dictionary map
    captured = []
    let dictLogger = baseLogger.With(["service": "auth", "env": "prod"])
    dictLogger.Warn("rate limited", ["ip": "10.0.0.1"])
    assert(captured.count == 1, "Dict logger emitted 1 record")
    assert(captured[0].contains("service=auth"), "Record contains dict service=auth")
    assert(captured[0].contains("env=prod"), "Record contains dict env=prod")
    assert(captured[0].contains("ip=10.0.0.1"), "Record contains call-site ip=10.0.0.1")

    // 12. Global Logger and SetHandler
    captured = []
    log.SetHandler(log.Handler.Text(minLevel: .debug, colors: false, emit: { s in
        captured.append(s)
    }))

    log.Debug("global debug")
    log.Info("global info", [log.Attr("user", "bob")])
    log.Warn("global warn", ["code": "404"])
    log.Error("global error")

    assert(captured.count == 4, "Global logging emitted all 4 records")

    // 13. Global With()
    captured = []
    let scoped = log.With(["component": "scheduler"])
    scoped.Info("job dispatched", [log.Attr("job_id", 42)])
    assert(captured.count == 1, "Scoped global logger emitted")
    assert(captured[0].contains("component=scheduler"), "Scoped logger has component=scheduler")
    assert(captured[0].contains("job_id=42"), "Scoped logger has job_id=42")

    // 14. Global SetHandler to JSON
    captured = []
    log.SetHandler(log.Handler.JSON(minLevel: .info, emit: { s in
        captured.append(s)
    }))

    log.Debug("should not appear in json")
    log.Info("json success", [log.Attr("ok", true), log.Attr("count", 100)])

    assert(captured.count == 1, "Global JSON logger filtered debug and kept info")
    assert(captured[0].contains("\"msg\":\"json success\""), "JSON output has msg field")
    assert(captured[0].contains("\"ok\":true"), "JSON output has boolean field ok:true")
    assert(captured[0].contains("\"count\":100"), "JSON output has numeric field count:100")

    print("\n-----------------------------------------")
    print("Checks passed: \(checkCount - failureCount)/\(checkCount)")
    if failureCount > 0 {
        print("FAILED: \(failureCount) checks failed")
        return 1
    }
    print("ALL LOG PACKAGE CHECKS PASSED!")
    return 0
}
