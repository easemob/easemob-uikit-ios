// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "EaseChatUIKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "EaseChatUIKit",
            targets: ["EaseChatUIKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flipboard/FLAnimatedImage.git",
            from: "1.0.0"
        ),
        // Official SPM distribution of the Easemob IM SDK.
        // CocoaPods continues to use the `HyphenateChat` pod (see EaseChatUIKit.podspec).
        .package(
            url: "https://github.com/easemob/HyphenateChat_iOS.git",
            from: "5.0.0"
        ),
    ],
    targets: [
        // Combined AMR codec (opencore-amr-nb, opencore-amr-wb, vo-amrwbenc).
        // ios-arm64 (device) and ios-x86_64-arm64-simulator.
        .binaryTarget(
            name: "AMRCodec",
            path: "Frameworks/AMRCodec.xcframework"
        ),
        .target(
            name: "EaseChatUIKit",
            dependencies: [
                "AMRCodec",
                .product(name: "FLAnimatedImage", package: "FLAnimatedImage"),
                .product(name: "HyphenateChat", package: "HyphenateChat_iOS"),
            ],
            path: "Sources/EaseChatUIKit/Classes",
            exclude: [
                // C static libraries are compiled into AMRCodec.xcframework for SPM.
                // Headers and .a files here are only used by the CocoaPods build.
                "UI/Core/Foundation/third-party",
                // CocoaPods umbrella/prefix header — not needed for SPM.
                "UI/Core/Foundation/EaseChatUIKit-Bridge.h",
                // Dead code: imports missing headers (amrFileCodec.h, wav.h).
                "UI/Core/UIKit/FrameWorks/VoiceConvert.m",
            ],
            resources: [
                // Preserve the .bundle so images and lproj stay grouped.
                // Loaded in BundleExtension.swift via:
                //   Bundle.module.url(forResource: "EaseChatResource", withExtension: "bundle")
                .copy("UI/Resources/EaseChatResource.bundle"),
                .process("UI/Resources/PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
