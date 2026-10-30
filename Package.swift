// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "EaseChatUIKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EaseChatUIKit", targets: ["EaseChatUIKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/easemob/HyphenateChat_iOS.git", "4.22.1"..<"5.0.0"),
        .package(url: "https://github.com/Flipboard/FLAnimatedImage.git", from: "1.0.16")
    ],
    targets: [
        .target(
            name: "EaseChatUIKit",
            dependencies: [
                .product(name: "HyphenateChat", package: "HyphenateChat_iOS"),
                .product(name: "FLAnimatedImage", package: "FLAnimatedImage"),
                "AMRCodec"
            ],
            path: "Sources/EaseChatUIKit/Classes",
            exclude: [
                "UI/Core/Foundation/EaseChatUIKit-Bridge.h",
                "UI/Core/Foundation/third-party",
                "UI/Core/UIKit/FrameWorks/VoiceConvert.m"
            ],
            resources: [
                // Keep the existing bundle layout, including localized strings and image scales.
                .copy("UI/Resources/EaseChatResource.bundle"),
                .process("UI/Resources/PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("UIKit"),
                .linkedFramework("Foundation"),
                .linkedFramework("Combine"),
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AVFAudio"),
                .linkedFramework("Photos")
            ]
        ),
        .binaryTarget(
            name: "AMRCodec",
            path: "Sources/EaseChatUIKit/Classes/UI/Core/Foundation/third-party/AMRCodec.xcframework"
        ),
        .testTarget(
            name: "EaseChatUIKitTests",
            dependencies: ["EaseChatUIKit"],
            path: "Tests/EaseChatUIKitTests",
            exclude: ["HostResources"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
