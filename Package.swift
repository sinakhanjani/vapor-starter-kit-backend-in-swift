// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "app",
    products: [
        .library(name: "app", targets: ["App"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.4.0"),
        .package(url: "https://github.com/vapor/vapor.git",from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git",from: "1.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/MihaelIsaev/SwifQL.git", from:"1.0.0"),
        .package(url: "https://github.com/MihaelIsaev/SwifQLVapor.git", from:"1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication",
                                            "SwifQLVapor",
                                            "SwifQL",
                                            "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
