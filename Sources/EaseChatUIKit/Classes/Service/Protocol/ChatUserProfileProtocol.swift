//
//  DisplayProviderProtocol.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/8.
//

import Foundation

@objc public enum ChatUserProfileProviderType: UInt {
    case chat
    case group
    case contact
}

/// Profile of the ChatUIKit display needed.
@objc public protocol ChatUserProfileProtocol: NSObjectProtocol {
    var id: String {set get}
    var remark: String {set get}
    var selected: Bool {set get}
    var nickname: String {set get}
    var avatarURL: String {set get}
    
    func toJsonObject() -> Dictionary<String,Any>?
}

@objcMembers open class ChatUserProfile:NSObject, ChatUserProfileProtocol {
    public var remark: String = ""
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_user_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id]]
    }
    
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickname: String = ""
        
    public var selected: Bool = false
    
    public var modifyTime: Int64 = 0
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
        
}

/// Profile provider of the ChatUIKit.Only available in Swift language.
public protocol ChatUserProfileProvider {
    
    /// Coroutine obtains user information asynchronously.
    /// - Parameter profileIds: The corresponding conversation id string array.
    /// - Returns: Array of the conform``ChatUserProfileProtocol`` object.
    func fetchProfiles(profileIds: [String]) async -> [ChatUserProfileProtocol]
}

/// /// Profile provider of the ChatUIKit.Only available in Objective-C language.
@objc public protocol ChatUserProfileProviderOC: NSObjectProtocol {
    
    /// Need to obtain the list display information on the current screen.
    /// - Parameters:
    ///   - profileIds: The corresponding conversation id string array.
    ///   - completion: Callback,obtain Array of the ``ChatUserProfileProtocol`` object.
    func fetchProfiles(profileIds: [String],completion: @escaping ([ChatUserProfileProtocol]) -> Void)
}

public protocol ChatGroupProfileProvider {
    /// Coroutine obtains user information asynchronously.
    /// - Parameter profileIds: The corresponding conversation id string array.
    /// - Returns: Array of the conform``ChatUserProfileProtocol`` object.
    func fetchGroupProfiles(profileIds: [String]) async -> [ChatUserProfileProtocol]
    
}



@objc public protocol ChatGroupProfileProviderOC: NSObjectProtocol {
    
    /// Need to obtain the list display information on the current screen.
    /// - Parameters:
    ///   - profileIds: The corresponding conversation id string array.
    ///   - completion: Callback,obtain Array of the ``ChatUserProfileProtocol`` object.
    func fetchGroupProfiles(profileIds: [String],completion: @escaping ([ChatUserProfileProtocol]) -> Void)
}


