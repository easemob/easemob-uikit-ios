//
//  BundleExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

/**
 A type extension to provide a computed property for ChatroomResourceBundle.
 
 This extension provides a computed property `chatBundle` of type `Bundle` to access the ChatroomResourceBundle. If the ChatroomResourceBundle is already initialized, it returns the existing instance. Otherwise, it initializes the ChatroomResourceBundle with the path of the "ChatRoomResource.bundle" file in the main bundle. If the bundle is not found, it returns the main bundle.
 */
fileprivate var ChatResourceBundle: Bundle?

public extension Bundle {
    /**
     A computed property to access the ChatroomResourceBundle.
     
     This computed property returns the ChatroomResourceBundle. If the ChatroomResourceBundle is already initialized, it returns the existing instance. Otherwise, it initializes the ChatroomResourceBundle with the path of the "ChatRoomResource.bundle" file in the main bundle. If the bundle is not found, it returns the main bundle.
     */
    class var chatBundle: Bundle {
        if ChatResourceBundle != nil {
            return ChatResourceBundle!
        }
#if COCOAPODS
        return Bundle(for: Theme.self)
    .url(forResource: "EaseChatResource", withExtension: "bundle")
    .flatMap(Bundle.init(url:))!
#elseif SWIFT_PACKAGE
        return Bundle.module
#elseif STATIC_LIBRARY
        return Bundle.main
    .url(forResource: "EaseChatResource", withExtension: "bundle")
    .flatMap(Bundle.init(url:))!
#else
        return Bundle(for: Theme.self)
#endif
    }
}
