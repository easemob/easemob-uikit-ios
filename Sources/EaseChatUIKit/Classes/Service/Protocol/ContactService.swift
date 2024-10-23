//
//  ContactService.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation

@objc public protocol ContactServiceProtocol: NSObjectProtocol {
    
    /// Bind contacts changed listener
    /// - Parameter listener: ``ContactEventsResponse``
    func bindContactEventListener(listener: ContactEventsResponse)
    
    /// Unbind contacts state changed listener
    /// - Parameter listener: ``ContactEventsResponse``
    func unbindContactEventListener(listener: ContactEventsResponse)
    
    /// Register emergency listener
    /// - Parameter listener: ``ContactEmergencyListener``
    func registerEmergencyListener(listener: ContactEmergencyListener)
    
    /// Unregister emergency listener
    /// - Parameter listener: ``ContactEmergencyListener``
    func unregisterEmergencyListener(listener: ContactEmergencyListener)
    
    /// Fetch contacts form server.
    /// - Parameters:
    ///   - completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func contacts(completion: @escaping (ChatError?,[Contact]) -> Void)
    
    /// Add contact.
    /// - Parameters:
    ///   - userId: The ID of the user you want to add as a friend.
    ///   - invitation: Invitation information
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func addContact(userId: String,invitation: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Remove contact.
    /// - Parameters:
    ///   - userId: The ID of the user you want to remove from your friends.
    ///   - removeChannel: Whether to also remove the channel with this user.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func removeContact(userId: String, removeChannel: Bool,completion: @escaping (ChatError?,String) -> Void)
    
    /// Agree friend request.
    /// - Parameters:
    ///   - userId: The user ID that initiated the friend request.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func agreeFriendRequest(from userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Decline friend request.
    /// - Parameters:
    ///   - userId: The user ID that initiated the friend request.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func declineFriendRequest(from userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Get friend blacklist list
    /// - Parameter completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func userBlackList(completion: @escaping (ChatError?,[String]) -> Void)
    
    /// Add user to black list.
    /// - Parameters:
    ///   - userId: The user ID you want to block.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func addUserToBlackList(userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Remove user from black list.
    /// - Parameters:
    ///   - userId: The user ID you want to unblock.
    ///   - completion: Callback, if successful it will return a string of user id, if it fails it will return an error.
    func removeUserFromBlackList(userId: String,completion: @escaping (ChatError?,String) -> Void)
    
    /// Get the device ID array of all current user logins except the current device.
    /// - Parameter completion: Callback, if successful it will return a string array of user id, if it fails it will return an error.
    func deviceIdsOnOtherPlatformOfCurrentUser(completion: @escaping (ChatError?,[String]) -> Void)
    
    /// Set remark to the friend.
    /// - Parameters:
    ///   - userId: Friend user id.
    ///   - remark: Friend remark
    ///   - completion: Callback, if successful it will return a ``Contact`` object, if it fails it will return an error.
    func setRemark(userId: String, remark: String,completion: @escaping (ChatError?,Contact?) -> Void)
}

@objc public protocol ContactEventsResponse: NSObjectProtocol {
    
    /// The friend request was accepted by the other party
    /// - Parameter userId: Friend user id
    func friendRequestDidAgree(by userId: String)
    
    /// Friend request was rejected by the other party
    /// - Parameter userId: Friend user id
    func friendRequestDidDecline(by userId: String)
    
    /// The friend relationship was removed by the other party
    /// - Parameter userId: Friend user id
    func friendshipDidRemove(by userId: String)
    
    /// Friend relationship added successfully
    /// - Parameter userId: Friend user id
    func friendshipDidAddSuccessful(by userId: String)
    
    /// Received friend request
    /// - Parameter userId: Friend user id
    func friendRequestDidReceive(by userId:String)
}


@objc public enum ContactEmergencyType: UInt8 {
    case add
    case addFriend
    case remove
    case setRemark
    case agree
    case decline
    case fetchContacts
    case cleanFriendBadge
}

@objc public protocol ContactEmergencyListener: NSObjectProtocol {
    
    /// You'll receive the result on conversation service request successful or failure.
    /// - Parameters:
    ///   - error: .Success ``ChatError`` is nil.
    ///   - type: ``ContactEmergencyType``
    ///   - operatorId: The id of operator.
    func onResult(error: ChatError?,type: ContactEmergencyType,operatorId: String)
    
}
