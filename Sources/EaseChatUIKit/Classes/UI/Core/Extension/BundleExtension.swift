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
        let bundlePath = Bundle.main.path(forResource: "EaseChatResource", ofType: "bundle") ?? ""
        ChatResourceBundle = Bundle(path:  bundlePath) ?? .main
        return ChatResourceBundle!
    }
}
