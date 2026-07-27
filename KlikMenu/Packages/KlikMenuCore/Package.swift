// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KlikMenuCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "KlikMenuCore",
            targets: ["KlikMenuCore"]
        )
    ],
    targets: [
        .target(
            name: "KlikMenuCore"
        ),
        .testTarget(
            name: "KlikMenuCoreTests",
            dependencies: ["KlikMenuCore"]
        )
    ]
)
