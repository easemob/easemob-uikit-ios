//
//  GroupMemberAttributesCache.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/12/19.
//

import UIKit

@objc public final class GroupMemberAttributesCache: NSObject {
    
    @objc public weak var providerOC: EaseGroupMemberProfileProviderOC?
    
    public var provider: EaseGroupMemberProfileProvider?
    
    @objc public private(set) var attributes: Dictionary<String,Dictionary<String,Dictionary<String,String>>> = [:]
    
    @objc public var profiles: Dictionary<String,Dictionary<String,EaseProfileProtocol>> = [:]
    
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
    
    /// Cache a conform ``EaseProfileProtocol`` object.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - profile: ``EaseProfileProtocol``
    @objc public func cacheProfile(groupId: String,profile: EaseProfileProtocol) {
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
    
    /// Remove  a conform ``EaseProfileProtocol`` cache object..
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - profile: ``EaseProfileProtocol``
    @objc(removeProfileCacheWithGroupId:profile:)
    public func removeCacheProfile(groupId: String,profile: EaseProfileProtocol) {
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
            }
        }
        if values.count > 0 {
            completion(nil,values)
        } else {
            if self.provider == nil,self.providerOC == nil {
                GroupServiceImplement().fetchMembersAttribute(groupId: groupId, userIds: userIds, keys: [key]) { [weak self] error, result in
                    if error == nil,let map = result {
                        for id in userIds {
                            if let value = map[id]?[key] {
                                self?.cache(groupId: groupId, userId: id, key: key, value: value)
                                values.append(value)
                            } else {
                                self?.cache(groupId: groupId, userId: id, key: key, value: id)
                                values.append(id)
                            }
                        }
                        completion(error,values)
                    } else {
                        completion(error,nil)
                        consoleLogInfo("fetchCacheValue error:\(error?.errorDescription ?? "")", type: .error)
                    }
                }
            } else {
                completion(nil,nil)
                assert(false, "The data provider and the chat room member custom attribute cache that comes with the SDK cannot be used at the same time. ")
            }
        }
    }
    
    /// Request the user's information about the group members displayed on the current page through ``EaseGroupMemberProfileProvider``.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userIds: Array of the user's id.
    /// - Returns: Array of the conform ``EaseProfileProtocol`` object.
    @objc(fetchCacheProfileWithGroupId:userIds:)
    public func fetchCacheProfile(groupId: String,userIds: [String]) -> [EaseProfileProtocol] {
        var profiles = [EaseProfileProtocol]()
        for userId in userIds {
            if let profile = self.profiles[groupId]?[userId] {
                profiles.append(profile)
            }
        }
        if profiles.count <= 0,self.provider != nil {
            Task {
                let profiles = await self.provider?.fetchMembers(groupId: groupId, userIds: userIds) ?? []
                for profile in profiles {
                    self.cacheProfile(groupId: groupId, profile: profile)
                }
                return profiles
            }
        }
        return profiles
    }
    
    /// Request the user's information about the group members displayed on the current page through ``EaseGroupMemberProfileProviderOC``.
    /// - Parameters:
    ///   - groupId: ID of the group.
    ///   - userIds: Array of the user's id.
    /// - Returns: Result,contain the array of the conform ``EaseProfileProtocol`` object.
    @objc(fetchCacheProfileOCWithGroupId:userIds:completion:)
    public func fetchCacheProfileOC(groupId: String,userIds: [String],completion: @escaping ([EaseProfileProtocol]) -> Void)  {
        var profiles = [EaseProfileProtocol]()
        for userId in userIds {
            if let profile = self.profiles[groupId]?[userId] {
                profiles.append(profile)
            }
        }
        if profiles.count <= 0 {
            if self.providerOC != nil {
                self.providerOC?.fetchMembers(groupId: groupId, userIds: userIds) { profiles in
                    for profile in profiles {
                        self.cacheProfile(groupId: groupId, profile: profile)
                    }
                    completion(profiles)
                }
            }
        }
        completion(profiles)
    }
    
    /// Update a group member cache attribute value.
    /// - Parameters:
    ///   - groupId: ID of the group
    ///   - userId: ID of the user.
    ///   - key: Attribute key.
    ///   - value: Attribute value
    @objc(updateCacheWithGroupId:userId:key:value:)
    public func updateCache(groupId: String, userId: String, key: String, value: String) {
        if self.provider == nil,self.providerOC == nil {
            GroupServiceImplement().setMemberAttributes(attributes: [key:value], groupId: groupId, userId: userId) { [weak self] error in
                if error == nil {
                    self?.cache(groupId: groupId, userId: userId, key: key, value: value)
                } else {
                    consoleLogInfo("updateCache error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        } else {
            assert(false, "The data provider and the chat room member custom attribute cache that comes with the SDK cannot be used at the same time. ")
        }
    }
    
    /// Update cache profiles
    /// - Parameters:
    ///   - groupId: ID of the group
    ///   - profiles: Array that you want to update of the conform ``EaseProfileProtocol`` object.
    @objc public func updateCacheProfile(groupId: String,profiles: [EaseProfileProtocol]) {
        if self.provider != nil {
            self.provider?.updateMember(groupId: groupId, profiles: profiles)
        } else {
            self.providerOC?.updateMember(groupId: groupId, profiles: profiles)
        }
        for profile in profiles {
            self.cacheProfile(groupId: groupId, profile: profile)
        }
    }
}
