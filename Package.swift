// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "todos-ios",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "todos-ios",
            targets: ["TodosApp"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.0"
        )
    ],
    targets: [
        .target(
            name: "TodosApp",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TodosAppTests",
            dependencies: [
                "TodosApp",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Tests"
        )
    ]
)
