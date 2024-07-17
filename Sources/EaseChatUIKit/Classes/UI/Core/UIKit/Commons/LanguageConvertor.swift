//
//  LanguaConvertor.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit


/// https://learn.microsoft.com/en-us/azure/ai-services/translator/language-support#translation 
public enum LanguageType: String {
    case Chinese = "zh-Hans", Chinese_traditional = "zh-Hant", English = "en", Russian = "ru", German = "de", French = "fr", Japanese = "ja", Korean = "ko", Auto = "auto"
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
        
        let path = Bundle.chatBundle.path(forResource: lang, ofType: "lproj") ?? ""
        let pathBundle = Bundle(path: path) ?? .main
        let value = pathBundle.localizedString(forKey: key, value: nil, table: nil)
        return value
    }

    static func chineseLanguage() -> Bool {
        if Appearance.ease_chat_language.rawValue.contains("zh") {
            return true
        } else {
            return false
        }
    }
}
