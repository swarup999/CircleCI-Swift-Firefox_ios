// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "BrowserKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Account", targets: ["Account"]),
        .library(name: "Objc", targets: ["Objc"]),
        .library(name: "Storage", targets: ["Storage"]),
        .library(name: "Sync",
                 targets: ["Sync"]),
        .library(name: "Shared",
                 targets: ["Shared"]),
        .library(
            name: "SiteImageView",
            targets: ["SiteImageView"]),
        .library(
            name: "Common",
            targets: ["Common"]),
        .library(
            name: "TabDataStore",
            targets: ["TabDataStore"]),
        .library(
            name: "Redux",
            targets: ["Redux"]),
        .library(
            name: "ComponentLibrary",
            targets: ["ComponentLibrary"]),
        .library(
            name: "WebEngine",
            targets: ["WebEngine"]),
        .library(
            name: "ToolbarKit",
            targets: ["ToolbarKit"]),
        .library(
            name: "MenuKit",
            targets: ["MenuKit"]),
        .library(
            name: "ContentBlockingGenerator",
            targets: ["ContentBlockingGenerator"]),
        .executable(
            name: "ExecutableContentBlockingGenerator",
            targets: ["ExecutableContentBlockingGenerator"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/nbhasin2/Fuzi.git",
            branch: "master"),
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            exact: "7.12.0"),
        .package(
            url: "https://github.com/AliSoftware/Dip.git",
            exact: "7.1.1"),
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",
            exact: "2.0.0"),
        .package(
            url: "https://github.com/getsentry/sentry-cocoa.git",
            exact: "8.26.0"),
        .package(
            url: "https://github.com/nbhasin2/GCDWebServer.git",
            branch: "master"),
        .package(
            url: "https://github.com/swhitty/SwiftDraw",
            exact: "0.17.0")
    ],
    targets: [
        .target(name: "Account",
                dependencies: ["Shared", "Storage", "Objc"]),
        .target(name: "Objc"),
        .target(name: "Storage",
                dependencies: ["Common", "WebEngine", "Objc", "Shared"]),
        .target(name: "Sync", dependencies: ["Common", "Shared"]),
        .target(name: "Shared",
                dependencies: ["Common", "WebEngine"],
                resources: [.process("Resources")]),
        .target(
            name: "ComponentLibrary",
            dependencies: ["Common", "SiteImageView"],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "ComponentLibraryTests",
            dependencies: ["ComponentLibrary"]),
        .target(
            name: "SiteImageView",
            dependencies: ["Fuzi", "Kingfisher", "Common", "SwiftDraw"],
            exclude: ["README.md"],
            resources: [.process("BundledTopSitesFavicons.xcassets")],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "SiteImageViewTests",
            dependencies: ["SiteImageView", .product(name: "GCDWebServers", package: "GCDWebServer")],
            resources: [
                .copy("Resources/mozilla.ico"),
                .copy("Resources/hackernews.svg")
            ]
        ),
        .target(
            name: "Common",
            dependencies: ["Dip",
                           "SwiftyBeaver",
                           .product(name: "Sentry", package: "sentry-cocoa")],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "CommonTests",
            dependencies: ["Common"]),
        .target(
            name: "TabDataStore",
            dependencies: ["Common"],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "TabDataStoreTests",
            dependencies: ["TabDataStore"]),
        .target(
            name: "Redux",
            dependencies: ["Common"],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "ReduxTests",
            dependencies: ["Redux"]),
        .target(
            name: "WebEngine",
            dependencies: ["Common",
                           .product(name: "GCDWebServers", package: "GCDWebServer")],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "WebEngineTests",
            dependencies: ["WebEngine"]),
        .target(
            name: "ToolbarKit",
            dependencies: ["Common"],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "ToolbarKitTests",
            dependencies: ["ToolbarKit"]),
        .target(
            name: "MenuKit",
            dependencies: ["Common", "ComponentLibrary"],
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "MenuKitTests",
            dependencies: ["MenuKit"]),
        .target(
            name: "ContentBlockingGenerator",
            swiftSettings: [.unsafeFlags(["-enable-testing"])]),
        .testTarget(
            name: "ContentBlockingGeneratorTests",
            dependencies: ["ContentBlockingGenerator"]),
        .executableTarget(
            name: "ExecutableContentBlockingGenerator",
            dependencies: ["ContentBlockingGenerator"]),
    ]
)
