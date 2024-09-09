// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KYSwiftUI",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "KYSwiftUI", targets: ["KYSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kyle-Ye/KYFoundation.git", from: "0.0.2"),
        .package(url: "https://github.com/Kyle-Ye/KYUIKit.git", from: "0.0.1"),
        .package(url: "https://github.com/siteline/swiftui-introspect.git", from: "1.3.0"),
    ],
    targets: [
        .target(name: "KYSwiftUI", dependencies: [
            .product(name: "KYFoundation", package: "KYFoundation"),
            .product(name: "KYUIKit", package: "KYUIKit"),
            .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
        ]),
    ]
)
