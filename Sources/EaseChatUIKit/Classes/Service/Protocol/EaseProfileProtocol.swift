//
//  DisplayProviderProtocol.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/8.
//

import Foundation

@objc public enum EaseProfileProviderType: UInt {
    case chat
    case group
    case contact
}

/// Profile of the EaseChatUIKit display needed.
@objc public protocol EaseProfileProtocol: NSObjectProtocol {
    var id: String {set get}
    var remark: String {set get}
    var selected: Bool {set get}
    var nickname: String {set get}
    var avatarURL: String {set get}
    
    func toJsonObject() -> Dictionary<String,Any>?
}

@objcMembers open class EaseProfile:NSObject, EaseProfileProtocol {
    public var remark: String = ""
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id,"remark":self.remark]]
    }
    
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickname: String = ""
        
    public var selected: Bool = false
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
        
}

/// Profile provider of the EaseChatUIKit.Only available in Swift language.
public protocol EaseProfileProvider {
    
    /// Synchronously obtain user information.
    /// - Parameters:
    ///   - id: Conversation's id.
    ///   - type: ``EaseProfileProviderType``
    /// - Returns: ``EaseProfileProtocol``
//    func getProfile(id: String, type: EaseProfileProviderType) -> EaseProfileProtocol
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameter profilesMap: The map parameter key is the conversation type value is the corresponding conversation id string array.
    /// - Returns: Array of the conform``EaseProfileProtocol`` object.
    func fetchProfiles(profilesMap: [EaseProfileProviderType:[String]]) async -> [EaseProfileProtocol]
}

//public extension EaseProfileProvider {
//    func getProfile(id: String, type: EaseProfileProviderType) -> EaseProfileProtocol {
//        EaseProfile()
//    }
//}


/// /// Profile provider of the EaseChatUIKit.Only available in Objective-C language.
@objc public protocol EaseProfileProviderOC: NSObjectProtocol {
    /// Synchronously obtain user information.
    /// - Parameters:
    ///   - id: Conversation's id.
    ///   - type: ``ChatConversationType``
    /// - Returns: ``EaseProfileProtocol``
//    @objc optional func getProfile(id: String, type: EaseProfileProviderType) -> EaseProfileProtocol
    
    /// Need to obtain the list display information on the current screen.
    /// - Parameters:
    ///   - profilesMap: The map parameter key is the conversation type value is the corresponding conversation id string array.
    ///   - completion: Callback,obtain Array of the ``EaseProfileProtocol`` object.
    func fetchProfiles(profilesMap: [Int:[String]],completion: @escaping ([EaseProfileProtocol]) -> Void)
}

public protocol EaseGroupMemberProfileProvider {
    
    /// Get member to render user nick name and avatar.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userId: The id of the user.
    /// - Returns: The object of conform ``EaseProfileProtocol``.
    func getMember(groupId:String ,userId: String ) -> EaseProfileProtocol
    
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userIds: The id of the user.
    /// - Returns: Callback,obtain Array  of conform ``EaseProfileProtocol`` object.
    func fetchMembers(groupId:String, userIds:[String]) async -> [EaseProfileProtocol]
    
    /// Update cache user info of group participant.
    /// - Parameters:
    ///   - groupId: The ID of group
    ///   - profiles: The profile array you want to update.
    func updateMember(groupId: String,profiles:[EaseProfileProtocol])
 
}

public extension EaseGroupMemberProfileProvider {
    func getMember(groupId: String, userId: String) -> EaseProfileProtocol {
        EaseProfile()
    }
}

@objc public protocol EaseGroupMemberProfileProviderOC: NSObjectProtocol {
    /// Get member to render user nick name and avatar.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userId: The id of the user.
    /// - Returns: The object of conform ``EaseProfileProtocol``.
    @objc optional func getMember(groupId:String ,userId: String ) -> EaseProfileProtocol
    
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameters:
    ///   - groupId: The id of the group.
    ///   - userIds: The id of the user.
    /// - Returns: Callback,obtain Array  of conform ``EaseProfileProtocol`` object.
    func fetchMembers(groupId:String, userIds:[String], completion: @escaping ([EaseProfileProtocol]) -> Void)
    
    /// Update cache user info of group participant.
    /// - Parameters:
    ///   - groupId: The ID of group
    ///   - profiles: The profile array you want to update.
    func updateMember(groupId: String,profiles:[EaseProfileProtocol])
}


