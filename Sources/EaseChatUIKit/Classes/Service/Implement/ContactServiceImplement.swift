//
//  ContactServiceImplement.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import UIKit

@objc public class ContactServiceImplement: NSObject {
        
    private var responseDelegates: NSHashTable<ContactEventsResponse> = NSHashTable<ContactEventsResponse>.weakObjects()
    
    private var eventsNotifiers: NSHashTable<ContactEmergencyListener> = NSHashTable<ContactEmergencyListener>.weakObjects()
    
    @objc public override init() {
        super.init()
        ChatClient.shared().contactManager?.add(self, delegateQueue: .main)
    }
    
    deinit {
        ChatClient.shared().contactManager?.removeDelegate(self)
    }
}

extension ContactServiceImplement: ContactServiceProtocol {
    
    public func registerEmergencyListener(listener: ContactEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            return
        }
        self.eventsNotifiers.add(listener)
    }
    
    public func unregisterEmergencyListener(listener: ContactEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            self.eventsNotifiers.remove(listener)
        }
    }
        
    public func bindContactEventListener(listener: ContactEventsResponse) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindContactEventListener(listener: ContactEventsResponse) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func contacts(completion: @escaping (ChatError?, [Contact]) -> Void) {
        let contacts = ChatClient.shared().contactManager?.getAllContacts()
        let loadFinish = UserDefaults.standard.bool(forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
        if !loadFinish,contacts?.count ?? 0 <= 0 {
            ChatClient.shared().contactManager?.getAllContactsFromServer(completion: { [weak self] contacts, error in
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
                }
                completion(error,contacts ?? [])
                self?.handleResult(error: error, type: .fetchContacts, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
            })
        } else {
            completion(nil,contacts ?? [])
        }
    }
    
    public func addContact(userId: String, invitation: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.addContact(userId, message: invitation, completion: { [weak self] useId, error in
            guard let `self` = self else { return }
            completion(error,userId)
            self.handleResult(error: error, type: .add, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        })
    }
    
    public func removeContact(userId: String, removeChannel: Bool = false, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.deleteContact(userId, isDeleteConversation: removeChannel, completion: { [weak self] userId, error in
            completion(error,userId ?? "")
            self?.handleResult(error: error, type: .remove, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        })
    }
    
    public func agreeFriendRequest(from userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.approveFriendRequest(fromUser: userId, completion: { [weak self] userId, error in
            completion(error,userId ?? "")
            self?.handleResult(error: error, type: .agree, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        })
    }
    
    public func declineFriendRequest(from userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.declineFriendRequest(fromUser: userId, completion: { [weak self] userId, error in
            completion(error,userId ?? "")
            self?.handleResult(error: error, type: .decline, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        })
    }
    
    public func userBlackList(completion: @escaping (ChatError?, [String]) -> Void) {
        ChatClient.shared().contactManager?.getBlackListFromServer(completion: { userIds, error in
            completion(error,userIds ?? [])
        })
    }
    
    public func addUserToBlackList(userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.addUser(toBlackList: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func removeUserFromBlackList(userId: String, completion: @escaping (ChatError?, String) -> Void) {
        ChatClient.shared().contactManager?.removeUser(fromBlackList: userId, completion: { userId, error in
            completion(error,userId ?? "")
        })
    }
    
    public func deviceIdsOnOtherPlatformOfCurrentUser(completion: @escaping (ChatError?, [String]) -> Void) {
        ChatClient.shared().contactManager?.getSelfIdsOnOtherPlatform(completion: { deviceIds, error in
            completion(error,deviceIds ?? [])
        })
    }
    
    public func setRemark(userId: String, remark: String, completion: @escaping (ChatError?, Contact?) -> Void) {
        ChatClient.shared().contactManager?.setContactRemark(userId,remark: remark,completion: { [weak self] contact, error in
            completion(error,contact)
            self?.handleResult(error: error, type: .setRemark, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        })
    }
}

extension ContactServiceImplement: ContactEventsListener {
    
    public func friendshipDidAdd(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendshipDidAddSuccessful(by: aUsername)
        }
        self.handleResult(error: nil, type: .add, operatorId: aUsername)
    }
    
    public func friendshipDidRemove(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendshipDidRemove(by: aUsername)
        }
        self.handleResult(error: nil, type: .remove, operatorId: aUsername)
    }
    
    public func friendRequestDidApprove(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidAgree(by: aUsername)
        }
        self.handleResult(error: nil, type: .agree, operatorId: aUsername)
    }
    
    public func friendRequestDidDecline(byUser aUsername: String) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidDecline(by: aUsername)
        }
        self.handleResult(error: nil, type: .decline, operatorId: aUsername)
    }
    
    public func friendRequestDidReceive(fromUser aUsername: String, message aMessage: String?) {
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidReceive(by: aUsername)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.3) {
            self.handleResult(error: nil, type: .add, operatorId: aUsername)
        }
    }
    
    func handleResult(error: ChatError?,type: ContactEmergencyType,operatorId: String) {
        for listener in self.eventsNotifiers.allObjects {
            listener.onResult(error: error, type: type, operatorId: operatorId)
        }
    }
    
}

