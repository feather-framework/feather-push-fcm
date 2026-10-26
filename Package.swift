// swift-tools-version:6.3
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .strictMemorySafety(),
    .treatAllWarnings(as: .error),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
    .enableExperimentalFeature("SuppressedAssociatedTypes"),
    .enableExperimentalFeature("LifetimeDependence"),
    .enableExperimentalFeature("Lifetimes"),
    .enableUpcomingFeature("StrictConcurrency"),
]

let package = Package(
    name: "feather-push-fcm",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "FeatherPushFCM", targets: ["FeatherPushFCM"]),
        .library(name: "FCM", targets: ["FCM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.25.2"),
        .package(url: "https://github.com/vapor/jwt-kit", from: "5.1.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.14.0"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.62.0"),
        .package(url: "https://github.com/feather-framework/feather-push", exact: "1.0.0-rc.1"),
    ],
    targets: [
        .target(
            name: "FCM",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOCore", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "FeatherPushFCM",
            dependencies: [
                .product(name: "FeatherPush", package: "feather-push"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIOCore", package: "swift-nio"),
                .target(name: "FCM"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FCMTests",
            dependencies: [.target(name: "FCM")],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FeatherPushFCMTests",
            dependencies: [
                .product(name: "FeatherPush", package: "feather-push"),
                .target(name: "FeatherPushFCM"),
            ],
            resources: [.copy("Resources")],
            swiftSettings: swiftSettings
        ),
    ]
)
