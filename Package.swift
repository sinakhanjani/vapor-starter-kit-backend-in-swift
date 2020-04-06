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
//        .package(url: "https://github.com/MihaelIsaev/SwifQL.git", from:"1.0.0"),
//        .package(url: "https://github.com/MihaelIsaev/SwifQLVapor.git", from:"1.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "3.0.0"),
//        .package(url: "https://github.com/tid-kijyun/Kanna.git", from: "5.2.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
//        .package(url: "https://github.com/mongodb/mongo-swift-driver.git", from: "0.1.3"),
//        .package(url: "https://github.com/asensei/vapor-fluent-mongo.git", from: "3.0.0"),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", from: "1.1.2"),
        .package(url: "https://github.com/dduan/Just.git", from: "0.8.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.1.0"))

    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication",
                                            "JWT",
                                            "Redis",
                                            "SwiftSoup",
                                            "Jobs",
                                            "Just",
                                            "Alamofire"]),//"MongoSwift" "FluentMongo"
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
