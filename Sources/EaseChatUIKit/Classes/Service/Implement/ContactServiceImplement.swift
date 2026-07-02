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
    
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Array<Dictionary<String,Any>>>()) private var newFriends
    
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
        let conversation = ChatClient.shared().chatManager?.getConversation(aUsername, type: .chat, createIfNotExist: true)
        let ext = ["something":("You have added".chat.localize+" "+aUsername+" "+"to say hello".chat.localize)]
        let message = ChatMessage(conversationID: aUsername, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
        conversation?.insert(message, error: nil)
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
        self.saveFriendRequest(from: aUsername)
        for listener in self.responseDelegates.allObjects {
            listener.friendRequestDidReceive(by: aUsername)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.3) {
            self.handleResult(error: nil, type: .add, operatorId: aUsername)
        }
    }
    
    public func onFriendInfoChanged(_ contact: Contact) {
        let profile = ChatUserProfile()
        profile.id = contact.userId
        profile.nickname = contact.userInfo?.nickname ?? ChatUIKitContext.shared?.userCache?[contact.userId]?.nickname ?? ""
        profile.remark = contact.remark ?? ChatUIKitContext.shared?.userCache?[contact.userId]?.remark ?? ""
        profile.avatarURL = contact.userInfo?.avatarUrl ?? ChatUIKitContext.shared?.userCache?[contact.userId]?.avatarURL ?? ""
        ChatUIKitContext.shared?.updateCaches(type: .user, profiles: [profile])
        self.handleResult(error: nil, type: .fetchContacts, operatorId: contact.userId)
    }
    
    private func saveFriendRequest(from userId: String) {
        let requestInfo: [String:Any] = ["userId":userId,"timestamp":Date().timeIntervalSince1970*1000,"groupApply":0,"read":0]
        var exist = self.newFriends[saveIdentifier]
        if exist == nil {
            self.newFriends[saveIdentifier] = [requestInfo]
        } else if exist?.first(where: { $0["userId"] as? String == userId }) == nil {
            exist?.append(requestInfo)
            self.newFriends[saveIdentifier] = exist
        }
        if let index = Appearance.contact.listHeaderExtensionActions.firstIndex(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let item = Appearance.contact.listHeaderExtensionActions[index]
            item.showBadge = true
            let unreadCount = self.newFriends[saveIdentifier]?.filter({ $0["read"] as? Int == 0 }).count ?? 0
            item.numberCount = UInt(unreadCount)
            Appearance.contact.listHeaderExtensionActions[index].numberCount = UInt(unreadCount)
        }
    }
    
    func handleResult(error: ChatError?,type: ContactEmergencyType,operatorId: String) {
        for listener in self.eventsNotifiers.allObjects {
            listener.onResult(error: error, type: type, operatorId: operatorId)
        }
    }
    
}


