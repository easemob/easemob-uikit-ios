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
    case contact
    case conversation
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
    
    /// The cache of user information on the side of the message in the chat page. The key is the user ID and the value is an object that complies with the ``EaseProfileProtocol`` protocol.
    public var chatCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    /// The cache of user information on contact page. The key is the user ID and the value is an object that complies with the ``EaseProfileProtocol`` protocol.
    public var contactsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    /// The cache of user information on conversatoins page. The key is the user ID and the value is an object that complies with the ``EaseProfileProtocol`` protocol.
    public var conversationsCache: Dictionary<String,EaseProfileProtocol>? = [:]
    
    /// Cache object of group member's display properties
    public var groupMemberAttributeCache: GroupMemberAttributesCache? = GroupMemberAttributesCache()
    
    /// The first parameter is the group id and the second parameter is the group name.
    public var onGroupNameUpdated: ((String,String) -> Void)?
    
    
    /// Clean the cache of ``EaseChatUIKitCacheType`` type
    /// - Parameter type: ``EaseChatUIKitCacheType``
    @objc(cleanCacheWithType:)
    public func cleanCache(type: EaseChatUIKitCacheType) {
        switch type {
        case .all:
            self.chatCache = nil
            self.contactsCache = nil
            self.conversationsCache = nil
            self.groupMemberAttributeCache = nil
        case .chat:
            self.chatCache = nil
        case .contact: self.contactsCache = nil
        case .conversation: self.conversationsCache = nil
        case .groupMemberAttribute: self.groupMemberAttributeCache = nil
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
        case .contact:
            self.contactsCache?[profile.id] = profile
        case .conversation:
            self.conversationsCache?[profile.id] = profile
        default:
            break
        }
    }
}
