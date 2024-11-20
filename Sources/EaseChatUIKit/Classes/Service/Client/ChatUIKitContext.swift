//
//  ChatUIKitContext.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public enum EaseChatUIKitCacheType: UInt {
    case all
    case chat
    case user
    case group
}

@objcMembers public class ChatUIKitContext: NSObject {
    
    @objc public static let shared: ChatUIKitContext? = ChatUIKitContext()

    public var currentUser: ChatUserProfileProtocol? {
        willSet {
            self.chatCache?[self.currentUserId] = newValue
        }
    }
    
    public var currentUserId: String {
        ChatClient.shared().currentUsername ?? ""
    }
    
    /// The cache of user information on the side of the message in the chat page. The key is the user ID and the value is an object that complies with the ``ChatUserProfileProtocol`` protocol.Display the info on chat page.
    public var chatCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    /// The cache of user information on user. Display the info on contact-list&single-chat-conversation-item&user-profile page .
    public var userCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    /// The cache of user information on group-conversation-item. The key is the user ID and the value is an object that complies with the ``ChatUserProfileProtocol`` protocol.
    public var groupCache: Dictionary<String,ChatUserProfileProtocol>? = Dictionary<String,ChatUserProfileProtocol>()
    
    public var pinnedCache: Dictionary<String,Bool>? = Dictionary<String,Bool>()
    
    public var userProfileProvider: ChatUserProfileProvider?
    
    public var userProfileProviderOC: ChatUserProfileProviderOC?
    
    public var groupProfileProvider: ChatGroupProfileProvider?
    
    public var groupProfileProviderOC: ChatGroupProfileProviderOC?
    
    /// The first parameter is the group id and the second parameter is the group name.
    public var onGroupNameUpdated: ((String,String) -> Void)?
    
    
    /// Clean the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameter type: ``EaseChatUIKitCacheType``
    @objc(cleanCacheWithType:)
    public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.chatCache?.removeAll()
            self.userCache?.removeAll()
            self.groupCache?.removeAll()
        case .chat://不需要对外暴露
            self.chatCache?.removeAll()
        case .user: self.userCache?.removeAll()
        case .group: self.groupCache?.removeAll()
        default: break
        }
    }
    
    
    /// Update the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameters:
    ///   - type: ``EaseChatUIKitCacheType``
    ///   - profile: The object conform to ``ChatUserProfileProtocol``.
    @objc(updateCacheWithType:profile:)
    public func updateCache(type: EaseChatUIKitCacheType,profile: ChatUserProfileProtocol) {
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: cache_update_notification), object: nil, userInfo: nil)
    }
    
    public func updateCaches(type: EaseChatUIKitCacheType,profiles: [ChatUserProfileProtocol]) {
        switch type {
        case .chat:
            profiles.forEach { profile in
                self.chatCache?[profile.id] = profile
            }
        case .user:
            profiles.forEach { profile in
                self.userCache?[profile.id] = profile
            }
        case .group:
            profiles.forEach { profile in
                self.groupCache?[profile.id] = profile
            }
        default:
            break
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: cache_update_notification), object: nil, userInfo: nil)
    }
}
