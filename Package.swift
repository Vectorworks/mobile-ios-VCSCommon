// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mobile-ios-VCSCommon",
    platforms: [
        .iOS(.v13),
//        .macOS(.v10_13),
//        .tvOS(.v12),
//        .watchOS(.v5),
        
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "mobile-ios-VCSCommon",
            targets: [
                "VCSCommon",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/KissXML.git", .exact("5.3.3")),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", .exact("3.7.4")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("5.6.1")),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .exact("0.9.14")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .exact("10.25.2")),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", .exact("5.0.1")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("9.0.0")),
        
        .package(url: "https://github.com/Vectorworks/OAuth2.git", .exact("5.2.1")),
    ],
    targets: [
        .target(
            name: "VCSCommon",
            dependencies: [
                .product(name: "KissXML", package: "KissXML"),
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "OAuth2", package: "OAuth2"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "Realm", package: "realm-cocoa"),
                .product(name: "RealmSwift", package: "realm-cocoa"),
            ],
            path: "VCSCommon",
            exclude: [
                "PromisedFuture/README.md",
                "Info.plist",
            ]),
//        .testTarget(
//            name: "mobile-ios-VCSCommonTests",
//            dependencies: [
//                "VCSCommon",
//                .product(name: "KissXML", package: "KissXML"),
//                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
//                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
//                .product(name: "Toast", package: "Toast"),
//                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
//                .product(name: "FirebaseAnalytics", package: "Firebase"),
//                .product(name: "FirebaseCrashlytics", package: "Firebase"),
//                .product(name: "FirebaseDynamicLinks", package: "Firebase"),],
//            path: "VCSCommonTests",
//            exclude: ["VCSNetworkTests/Info.plist"]
//        ),
    ]
)
