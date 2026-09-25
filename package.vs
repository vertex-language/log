// The 'log' repository: structured, levelled logging for Vertex.
import PackageDescription

let package = Package(
    name: "log",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "log", targets: ["log"]),
        .executable(name: "check", targets: ["check"]),
    ],
    targets: [
        // Core structured logging library.
        .target(
            name: "log",
            path: "log"
        ),
        // Comprehensive test suite.
        .executableTarget(
            name: "check",
            dependencies: ["log"],
            path: "tests/check"
        ),
    ]
)
