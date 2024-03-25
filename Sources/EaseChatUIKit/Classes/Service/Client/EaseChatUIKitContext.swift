//
//  EaseChatUIKitContext.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public enum EaseChatUIKitCacheType: UInt {
    case all
    case chat
    case user
    case group
    case groupMemberAttribute
}

@objcMembers public class EaseChatUIKitContext: NSObject {
    
    @objc public static let shared: EaseChatUIKitContext? = EaseChatUIKitContext()

    public var currentUser: EaseProfileProtocol? {
        willSet {
            self.chatCache?[self.currentUserId] = newValue
        }
    }
    
    public var currentUserId: String {
        ChatClient.shared().currentUsername ?? ""
    }
    
    /// The cache of user information on the side of the message in the chat page. The key is the user ID and the value is an object that complies with the ``EaseProfileProtocol`` protocol.Display the info on chat page.
    public var chatCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    /// The cache of user information on user. Display the info on contact-list&single-chat-conversation-item&user-profile page .
    public var userCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    /// The cache of user information on group-conversation-item. The key is the user ID and the value is an object that complies with the ``EaseProfileProtocol`` protocol.
    public var groupCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    public var userProfileProvider: EaseProfileProvider?
    
    public var userProfileProviderOC: EaseProfileProviderOC?
    
    public var groupProfileProvider: EaseGroupProfileProvider?
    
    public var groupProfileProviderOC: EaseGroupProfileProviderOC?
    
    /// The first parameter is the group id and the second parameter is the group name.
    public var onGroupNameUpdated: ((String,String) -> Void)?
    
    
    /// Clean the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameter type: ``EaseChatUIKitCacheType``
    @objc(cleanCacheWithType:)
    public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.chatCache = nil
            self.userCache = nil
            self.groupCache = nil
        case .chat:
            self.chatCache = nil
        case .user: self.userCache = nil
        case .group: self.groupCache = nil
        default: break
        }
    }
    
    
    /// Update the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameters:
    ///   - type: ``EaseChatUIKitCacheType``
    ///   - profile: The object conform to ``EaseProfileProtocol``.
    @objc(updateCacheWithType:profile:)
    public func updateCache(type: EaseChatUIKitCacheType,profile: EaseProfileProtocol) {
        switch type {
        case .chat:
            self.chatCache?[profile.id] = profile
        case .user:
            self.userCache?[profile.id] = profile
        case .group:
            self.groupCache?[profile.id] = profile
        default:
            break
        }
    }
}
