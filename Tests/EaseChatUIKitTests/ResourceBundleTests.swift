import UIKit
import XCTest
@testable import EaseChatUIKit

/// Both package managers compile this suite. HostResources must be copied into the
/// application, not the test bundle, to exercise Bundle.main overrides.
final class ResourceBundleTests: XCTestCase {
    private static let appearanceLock = NSRecursiveLock()
    private var originalBundle: Bundle?
    private var originalLanguage = LanguageType.Chinese
    private var temporaryDirectories: [URL] = []

    override func setUp() {
        super.setUp()
        Self.appearanceLock.lock()
        originalBundle = Appearance.resourceBundle
        originalLanguage = Appearance.ease_chat_language
        Appearance.resourceBundle = nil
    }

    override func tearDown() {
        Appearance.resourceBundle = originalBundle
        Appearance.ease_chat_language = originalLanguage
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(at: directory)
        }
        temporaryDirectories = []
        Self.appearanceLock.unlock()
        super.tearDown()
    }

    func testDefaultBundleContainsEveryPNGAndBothLocalizations() throws {
        let bundle = Bundle.chatBundle
        XCTAssertEqual(bundle.bundleURL.lastPathComponent, "EaseChatResource.bundle")
        let urls = try FileManager.default.contentsOfDirectory(
            at: bundle.bundleURL, includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "png" }
        XCTAssertEqual(urls.count, 330, "The package must preserve the complete resource bundle")
        for url in urls {
            XCTAssertNotNil(UIImage(contentsOfFile: url.path), url.lastPathComponent)
        }
        for language in ["en", "zh-Hans"] {
            let directory = try XCTUnwrap(bundle.url(forResource: language, withExtension: "lproj"))
            XCTAssertTrue(FileManager.default.fileExists(
                atPath: directory.appendingPathComponent("Localizable.strings").path
            ))
        }
    }

    func testNamedUnicodeThemeAndAudioImagesLoadAtBothScales() throws {
        var names = ["🎂", "delete_emoji_dark", "delete_emoji_light"]
        for side in ["left", "right"] {
            for style in ["light", "dark"] {
                for frame in 1...3 {
                    names.append("audio_play_\(side)_\(style)0\(frame)")
                }
            }
        }
        for name in names {
            XCTAssertNotNil(UIImage(chatNamed: name), name)
            for scale: CGFloat in [2, 3] {
                let traits = UITraitCollection(displayScale: scale)
                let image = try XCTUnwrap(UIImage(named: name, in: .chatBundle, compatibleWith: traits), name)
                XCTAssertEqual(image.scale, scale, name)
                XCTAssertNotNil(Bundle.chatBundle.url(
                    forResource: "\(name)@\(Int(scale))x", withExtension: "png"
                ), name)
            }
        }
    }

    func testCustomBundleIsHonoredAfterDefaultLookupAndResetRestoresDefault() throws {
        let defaultURL = Bundle.chatBundle.bundleURL
        let first = try makeCustomBundle()
        Appearance.resourceBundle = first.bundle
        XCTAssertEqual(Bundle.chatBundle.bundleURL, first.bundle.bundleURL)
        let image = try XCTUnwrap(UIImage(chatNamed: first.imageName))
        XCTAssertEqual(image.size, CGSize(width: 7, height: 5))
        Appearance.ease_chat_language = .English
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "Custom send")
        Appearance.ease_chat_language = .Chinese
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "自定义发送")

        let second = try makeCustomBundle()
        Appearance.resourceBundle = second.bundle
        XCTAssertEqual(Bundle.chatBundle.bundleURL, second.bundle.bundleURL)
        XCTAssertNotNil(UIImage(chatNamed: second.imageName))

        Appearance.resourceBundle = nil
        XCTAssertEqual(Bundle.chatBundle.bundleURL, defaultURL)
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "发送")
        XCTAssertNotNil(UIImage(chatNamed: "🎂"))
    }

    func testEnglishChineseAndExplicitAutomaticLanguage() {
        Appearance.ease_chat_language = .English
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "Send")
        Appearance.ease_chat_language = .Chinese
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "发送")
        Appearance.ease_chat_language = .Auto("en")
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "Send")
        Appearance.ease_chat_language = .Auto("zh-Hans")
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), "发送")
    }

    func testMissingLocalizationKeyReturnsKey() {
        let key = "EaseChatUIKit.MissingLocalization.\(UUID().uuidString)"
        for language: LanguageType in [.English, .Chinese] {
            Appearance.ease_chat_language = language
            XCTAssertEqual(LanguageConvertor.localValue(key: key), key)
        }
    }

    func testUnsupportedAndRegionLanguagesKeepMainBundleFallback() {
        // Preserve the existing exact-directory behavior: this packaging change
        // must not introduce en-US -> en or zh-Hans-CN -> zh-Hans normalization.
        let key = "Send"
        let expected = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        for language: LanguageType in [.Japanese, .Auto("en-US"), .Auto("zh-Hans-CN")] {
            XCTAssertNil(Bundle.chatBundle.path(forResource: language.rawValue, ofType: "lproj"))
            Appearance.ease_chat_language = language
            XCTAssertEqual(LanguageConvertor.localValue(key: key), expected)
        }
    }

    func testEmptyAutomaticLanguageUsesSystemPreferredLanguage() throws {
        let preferred = try XCTUnwrap(NSLocale.preferredLanguages.first)
        Appearance.ease_chat_language = .Auto("")
        let expected: String
        switch preferred {
        case "en": expected = "Send"
        case "zh-Hans": expected = "发送"
        default: expected = Bundle.main.localizedString(forKey: "Send", value: nil, table: nil)
        }
        XCTAssertEqual(LanguageConvertor.localValue(key: "Send"), expected)
    }

    func testHostImageOverridesDefaultAndCustomBundleImages() throws {
        try requireHostResources()
        let hostImage = try XCTUnwrap(UIImage(named: "copy"))
        XCTAssertEqual(hostImage.size, CGSize(width: 3, height: 2))
        let defaultImage = try XCTUnwrap(UIImage(named: "copy", in: .chatBundle, compatibleWith: nil))
        XCTAssertNotEqual(defaultImage.size, hostImage.size)
        XCTAssertEqual(try XCTUnwrap(UIImage(chatNamed: "copy")).size, hostImage.size)

        let custom = try makeCustomBundle(imageName: "copy")
        Appearance.resourceBundle = custom.bundle
        XCTAssertEqual(try XCTUnwrap(UIImage(chatNamed: "copy")).size, hostImage.size)
    }

    func testHostLocalizedStringsOverrideDefaultAndCustomBundles() throws {
        try requireHostResources()
        let custom = try makeCustomBundle()
        for bundle in [nil, custom.bundle] {
            Appearance.resourceBundle = bundle
            Appearance.ease_chat_language = .English
            XCTAssertEqual(LanguageConvertor.localValue(key: "barrage_long_press_menu_copy"), "Host Copy")
            Appearance.ease_chat_language = .Chinese
            XCTAssertEqual(LanguageConvertor.localValue(key: "barrage_long_press_menu_copy"), "宿主复制")
        }
    }

    private func requireHostResources() throws {
#if SWIFT_PACKAGE
        guard Bundle.main.url(forResource: "EaseChatUIKitTestHost", withExtension: "plist") != nil else {
            throw XCTSkip("Run the hosted integration scheme to verify Bundle.main overrides")
        }
#else
        _ = try XCTUnwrap(
            Bundle.main.url(forResource: "EaseChatUIKitTestHost", withExtension: "plist"),
            "The hosted integration target must copy HostResources into the application bundle"
        )
#endif
    }

    private func makeCustomBundle(imageName: String = UUID().uuidString) throws -> (bundle: Bundle, imageName: String) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("EaseChatUIKitTests-\(UUID().uuidString).bundle", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        temporaryDirectories.append(directory)
        let info: [String: Any] = [
            "CFBundleIdentifier": "com.easemob.tests.\(UUID().uuidString)",
            "CFBundleName": "CustomResources",
            "CFBundlePackageType": "BNDL",
            "CFBundleDevelopmentRegion": "en"
        ]
        try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
            .write(to: directory.appendingPathComponent("Info.plist"))
        for (language, strings) in [
            ("en", "\"Send\" = \"Custom send\";\n\"barrage_long_press_menu_copy\" = \"Custom copy\";\n"),
            ("zh-Hans", "\"Send\" = \"自定义发送\";\n\"barrage_long_press_menu_copy\" = \"自定义复制\";\n")
        ] {
            let localization = directory.appendingPathComponent("\(language).lproj", isDirectory: true)
            try FileManager.default.createDirectory(at: localization, withIntermediateDirectories: true)
            try strings.write(to: localization.appendingPathComponent("Localizable.strings"), atomically: true, encoding: .utf8)
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 7, height: 5), format: format).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 7, height: 5))
        }
        try XCTUnwrap(image.pngData()).write(to: directory.appendingPathComponent("\(imageName).png"))
        return (try XCTUnwrap(Bundle(url: directory)), imageName)
    }
}
