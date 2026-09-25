package log

@_silgen_name("time")
func c_time(_ t: UnsafeMutablePointer<int64>?) -> int64

func pad2(_ n: int64) -> string {
    if n < 10 && n >= 0 { return "0\(n)" }
    return "\(n)"
}

func currentTimestamp() -> string {
    let now = c_time(nil)
    var secs = now
    var days = secs / 86400
    secs = secs % 86400
    if secs < 0 {
        secs += 86400
        days -= 1
    }
    let h = secs / 3600
    let m = (secs % 3600) / 60
    let s = secs % 60

    let z = days + 719468
    let era = (z >= 0 ? z : z - 146096) / 146097
    let doe = z - era * 146097
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
    let y = yoe + era * 400
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
    let mp = (5 * doy + 2) / 153
    let d = doy - (153 * mp + 2) / 5 + 1
    let month = mp < 10 ? mp + 3 : mp - 9
    let year = month <= 2 ? y + 1 : y

    return "\(year)-\(pad2(month))-\(pad2(d))T\(pad2(h)):\(pad2(m)):\(pad2(s))Z"
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
