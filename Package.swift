// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mobile-ios-VCSCommon",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "mobile-ios-VCSCommon",
            targets: [
                "VCSCommon",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/robbiehanson/KissXML.git", exact: "5.3.3"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", exact: "3.8.2"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.8.1"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.17"),
        .package(url: "https://github.com/realm/realm-cocoa.git", exact: "10.45.1"),
        .package(url: "https://github.com/scalessec/Toast-Swift.git", exact: "5.0.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "10.19.0"),
        
        .package(url: "https://github.com/Vectorworks/OAuth2.git", exact: "5.2.1"),
    ],
    targets: [
        .target(
            name: "VCSCommon",
            dependencies: [
                .product(name: "KissXML", package: "KissXML"),
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "Realm", package: "realm-cocoa"),
                .product(name: "RealmSwift", package: "realm-cocoa"),
                .product(name: "Toast", package: "Toast-Swift"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDynamicLinks", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                
                .product(name: "OAuth2", package: "OAuth2"),
            ],
            path: "VCSCommon",
            exclude: [
                "PromisedFuture/README.md",
                "Info.plist",
            ])
    ]
)
