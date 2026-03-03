// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WW1ArtilleryDemo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WW1ArtilleryDemo", targets: ["WW1ArtilleryDemo"])
    ],
    targets: [
        .executableTarget(
            name: "WW1ArtilleryDemo",
            path: "Sources"
        )
    ]
)
