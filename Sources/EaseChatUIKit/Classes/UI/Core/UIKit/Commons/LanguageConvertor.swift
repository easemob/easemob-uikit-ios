//
//  LanguaConvertor.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit


/// https://learn.microsoft.com/en-us/azure/ai-services/translator/language-support#translation 
public enum LanguageType: Equatable {
    case Chinese
    case Chinese_traditional
    case English
    case Russian
    case German
    case French
    case Japanese
    case Korean
    case Auto(String)

    public var rawValue: String {
        switch self {
        case .Chinese: return "zh-Hans"
        case .Chinese_traditional: return "zh-Hant"
        case .English: return "en"
        case .Russian: return "ru"
        case .German: return "de"
        case .French: return "fr"
        case .Japanese: return "ja"
        case .Korean: return "ko"
        case .Auto(let value): return value
        }
    }

    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "zh-hans":
            self = .Chinese
        case "zh-hant":
            self = .Chinese_traditional
        case "en":
            self = .English
        case "ru":
            self = .Russian
        case "de":
            self = .German
        case "fr":
            self = .French
        case "ja":
            self = .Japanese
        case "ko":
            self = .Korean
        default:
            self = .Auto(rawValue)
        }
    }

    public static func == (lhs: LanguageType, rhs: LanguageType) -> Bool {
        switch (lhs, rhs) {
        case (.Auto(let lhsValue), .Auto(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return lhs.rawValue == rhs.rawValue
        }
    }
}


/**
 A utility class for converting language keys to localized strings.
 */
@objc public final class LanguageConvertor: NSObject {

    public static func localValue(key: String) -> String {
        LanguageConvertor.shared.localValue(key)
    }

    public static let shared = LanguageConvertor()

    override private init() {}

    var currentLocal: Locale {
        Locale.current
    }

    /**
     Returns a localized string for the given key.
     
     - Parameter key: The key for the localized string.
     - Returns: The localized string for the given key.
     */
    private func localValue(_ key: String) -> String {
        guard var lang = NSLocale.preferredLanguages.first else { return Bundle.main.bundlePath }
        if !Appearance.ease_chat_language.rawValue.isEmpty {
            lang = Appearance.ease_chat_language.rawValue
        }
//        if let value = self.string(forKey: key, language: lang, in: .main),!value.isEmpty,value != key {
//            return value
//        }
        let path = Bundle.chatBundle.path(forResource: lang, ofType: "lproj") ?? ""
        let pathBundle = Bundle(path: path) ?? .main
        let value = pathBundle.localizedString(forKey: key, value: nil, table: nil)
        return value
    }
    
    // 辅助方法：在指定 Bundle 中查找特定语言的字符串
    private func string(forKey key: String, language: String, in bundle: Bundle) -> String? {
        // 寻找 .lproj 路径
        guard let path = bundle.path(forResource: language, ofType: "lproj"),
              let bundleWithLang = Bundle(path: path) else {
            return nil
        }
        
        // value 传 nil，如果没找到 key，系统默认返回 key 本身
        let result = bundleWithLang.localizedString(forKey: key, value: nil, table: nil)
        return result
    }

    static func chineseLanguage() -> Bool {
        if Appearance.ease_chat_language.rawValue.contains("zh") {
            return true
        } else {
            return false
        }
    }
}
