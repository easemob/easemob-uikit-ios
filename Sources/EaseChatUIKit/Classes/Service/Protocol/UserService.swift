//
//  UserService.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation

@objc public enum UserState: UInt {
    case online
    case offline
}

@objc public protocol UserServiceProtocol: NSObjectProtocol {
    
    /// Bind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func bindUserStateChangedListener(listener: UserStateChangedListener)
    
    /// Unbind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func unBindUserStateChangedListener(listener: UserStateChangedListener)
    
    /// Get user info by userId.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userId: userId
    ///   - completion: completion
    func userInfo(userId: String, completion: @escaping (ChatUserProfileProtocol?,ChatError?) -> Void)
    
    /// Get user info by userIds.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userIds: userIds
    ///   - completion: completion
    func userInfos(userIds: [String], completion: @escaping ([ChatUserProfileProtocol],ChatError?) -> Void)
    
    /// Update user info.The frequency of api usage for free users is 100 times in 1 second.Upgrading the package can increase the usage.
    /// - Parameters:
    ///   - userInfo: ChatUserProfileProtocol
    ///   - completion: 
    func updateUserInfo(userInfo: ChatUserProfileProtocol, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Login SDK
    /// - Parameters:
    ///   - userId: user id
    ///   - token: chat token(https://console.agora.io/project/WLRRH-ir6/extension?id=Chat or https://console.easemob.com/app/applicationOverview/userManagement  can build temp token)
    ///   - completion: Callback,success or failure
    func login(userId: String, token: String, completion: @escaping (Bool,ChatError?) -> Void)
    
    /// Logout SDK
    /// - Parameter completion: Callback,success or failure
    func logout(unbindNotificationDeviceToken: Bool,completion: @escaping (Bool,ChatError?) -> Void)
    
    
}


@objc public protocol UserStateChangedListener: NSObjectProtocol {
    
    /// User login at other device
    /// - Parameter device: Other device name
    func onUserLoginOtherDevice(device: String)
    
    /// User token will expired,when you need to fetch chat token  re-login.
    func onUserTokenWillExpired()
    
    /// User token expired,when you need to fetch chat token  re-login.
    func onUserTokenDidExpired()
    
    /// Chatroom socket connection state changed listener.
    /// - Parameter state: ConnectionState
    func onSocketConnectionStateChanged(state: ConnectionState)
    
    /// The user account did removed by server.
    func userAccountDidRemoved()
    
    /// The method called on user did forbid by server.
    func userDidForbidden()
    
    /// The user account logout by server.
    func userAccountDidForcedToLogout(error: ChatError?)
    
    /// When user auto login completion.
    /// - Parameter error: ``ChatError``
    func onUserAutoLoginCompletion(error: ChatError?)
        
}

