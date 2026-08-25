// swift-tools-version:6.1
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
var defaultSwiftSettings: [SwiftSetting] = [
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0441-formalize-language-mode-terminology.md
    .swiftLanguageMode(.v6),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    // https://github.com/swiftlang/swift/pull/65218
    .enableExperimentalFeature("AvailabilityMacro=featherPushFCM:macOS 15, iOS 18, watchOS 11, tvOS 18, visionOS 2"),
]

#if compiler(>=6.2)
defaultSwiftSettings.append(
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
)
#endif

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
        .package(url: "https://github.com/feather-framework/feather-push", exact: "1.0.0-beta.2"),
        // [docc-plugin-placeholder]
    ],
    targets: [
        .target(
            name: "FCM",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .target(
            name: "FeatherPushFCM",
            dependencies: [
                .product(name: "FeatherPush", package: "feather-push"),
                .target(name: "FCM"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FCMTests",
            dependencies: [.target(name: "FCM")],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "FeatherPushFCMTests",
            dependencies: [
                .product(name: "FeatherPush", package: "feather-push"),
                .target(name: "FeatherPushFCM"),
            ],
            resources: [.copy("Resources")],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
