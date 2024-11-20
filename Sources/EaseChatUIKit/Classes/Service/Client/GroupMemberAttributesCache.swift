//
//  GroupMemberAttributesCache.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/19.
//

import UIKit

@objc public final class GroupMemberAttributesCache: NSObject {
    
    @objc public private(set) var attributes: Dictionary<String,Dictionary<String,Dictionary<String,String>>> = [:]
    
    @objc public var profiles: Dictionary<String,Dictionary<String,ChatUserProfileProtocol>> = [:]
    
    /// Cache a group member attribute for key.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user
    ///   - key: Attribute key
    ///   - value:  Attribute value
    @objc(cacheWithGroupId:userId:key:value:)
    public func cache(groupId: String, userId: String, key: String, value: String) {
        var usesAttributes = self.attributes[groupId] ?? [:]
        var attributes = usesAttributes[userId] ?? [:]
        attributes[key] = value
        usesAttributes[userId] = attributes
        self.attributes[groupId] = usesAttributes
    }
    
    /// Cache a conform ``ChatUserProfileProtocol`` object.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - profile: ``ChatUserProfileProtocol``
    @objc public func cacheProfile(groupId: String,profile: ChatUserProfileProtocol) {
        self.profiles[groupId]?[profile.id] = profile
    }
    
    /// Remove a cache of the group member attribute.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userId: ID of the user.
    @objc public func removeCache(groupId: String,userId: String = "") {
        if userId.isEmpty {
            self.attributes.removeValue(forKey: groupId)
        } else {
            self.attributes[groupId]?.removeValue(forKey: userId)
        }
    }
    
    /// Remove  a conform ``ChatUserProfileProtocol`` cache object..
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - profile: ``ChatUserProfileProtocol``
    @objc(removeProfileCacheWithGroupId:profile:)
    public func removeCacheProfile(groupId: String,profile: ChatUserProfileProtocol) {
        self.profiles[groupId]?.removeValue(forKey: profile.id)
    }
    
    /// Fetch attributes of the group member.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userIds: Array of the user's id.
    ///   - key: Attribute key
    ///   - completion: callback,result contain error&attribute value.
    @objc(fetchCacheValueWithGroupId:userIds:key:completion:)
    public func fetchCacheValue(groupId: String, userIds: [String], key: String, completion: @escaping (ChatError?,[String]?) -> Void) {
        var values = [String]()
        for id in userIds {
            if let value = self.attributes[groupId]?[id]?[key] {
                values.append(value)
                ChatUIKitContext.shared?.chatCache?[id]?.remark = value
            }
        }

    }
    
}
