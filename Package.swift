// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "WinFunktionMathe",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "WinFunktionMathe",
            path: "Sources/WinFunktionMathe"
        )
    ]
)
