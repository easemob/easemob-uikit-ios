//
//  ConversationServiceImplement.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit



@objc public class ConversationServiceImplement: NSObject {
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    private var responseDelegates: NSHashTable<ConversationServiceListener> = NSHashTable<ConversationServiceListener>.weakObjects()
    
    public private(set) var eventsNotifiers: NSHashTable<ConversationEmergencyListener> = NSHashTable<ConversationEmergencyListener>.weakObjects()
    
    public override init() {
        super.init()
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
        ChatClient.shared().add(self, delegateQueue: .main)
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
        ChatClient.shared().removeDelegate(self)
    }
}

extension ConversationServiceImplement: ConversationService {
    public func loadIfNotExistCreate(conversationId: String,type: ChatConversationType) -> ChatConversation? {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            return conversation
        }
        return ChatClient.shared().chatManager?.getConversation(conversationId, type: type, createIfNotExist: true)
    }
    
    
    
    public func loadExistConversations() {
        let conversations = ChatClient.shared().chatManager?.getAllConversations(true) ?? []
        let notifyLocalConversations: () -> Void = { [weak self] in
            guard let `self` = self else { return }
            for listener in self.responseDelegates.allObjects {
                listener.onChatConversationListDidChanged(list: self.mapper(objects: conversations))
            }
        }
        guard !conversations.isEmpty else {
            notifyLocalConversations()
            return
        }
        self.fetchSilentMode(conversationIds: conversations.map({ $0.conversationId })) { [weak self] resultSilent, silentError in
            if silentError == nil {
                self?.updateMuteMap(result: resultSilent)
            }
            notifyLocalConversations()
        }
    }
    
    /// Update the local do-not-disturb map according to the silent mode result of conversations.
    private func updateMuteMap(result: Dictionary<String, SilentModeResult>?) {
        guard let result = result else { return }
        let currentUser = ChatUIKitContext.shared?.currentUserId ?? ""
        var conversationMap = self.muteMap[currentUser] ?? [:]
        for (conversationId, silentResult) in result {
            conversationMap[conversationId] = silentResult.remindType.rawValue
        }
        self.muteMap[currentUser] = conversationMap
    }
    
    
    public func fetchSilentMode(conversationIds: [String], completion: @escaping (Dictionary<String, SilentModeResult>?, ChatError?) -> Void) {
        var conversations = [ChatConversation]()
        for id in conversationIds {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(id) {
                conversations.append(conversation)
            }
        }
        ChatClient.shared().pushManager?.getSilentMode(for: conversations,completion: { [weak self] result, error in
            self?.handleResult(error: error, type: .fetchSilent)
            completion(result,error)
        })
    }
    
    public func setSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            let params = SilentModeParam(paramType: .remindType)
            params.remindType = (conversation.type == .chat ? .none:.mentionOnly)
            ChatClient.shared().pushManager?.setSilentModeForConversation(conversationId, conversationType: conversation.type, params: params,completion: { [weak self] result, error in
                self?.handleResult(error: error, type: .setSilent)
                completion(result,error)
            })
        }
    }
    
    public func clearSilentMode(conversationId: String, completion: @escaping (SilentModeResult?, ChatError?) -> Void) {
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            let params = SilentModeParam(paramType: .remindType)
            params.remindType = .all
            ChatClient.shared().pushManager?.setSilentModeForConversation(conversationId, conversationType: conversation.type, params: params,completion: { [weak self] result, error in
                self?.handleResult(error: error, type: .setSilent)
                completion(result,error)
            })
        }
    }
    
    public func pin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: true, completionBlock: { [weak self] error in
            self?.handleResult(error: error, type: .pin)
            completion(error)
        })
    }
    
    public func unpin(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinConversation(conversationId, isPinned: false, completionBlock: { [weak self] error in
            self?.handleResult(error: error, type: .unpin)
            completion(error)
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (ChatError?) -> Void) {
        if let _ = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
            ChatClient.shared().chatManager?.deleteConversation(conversationId, isDeleteMessages: true, completion: { [weak self] localId, error in
                ChatUIKitContext.shared?.pinnedCache?.removeValue(forKey: conversationId)
                self?.handleResult(error: error, type: .delete)
                completion(error)
            })
        }
        
    }
    
    public func markAllMessagesAsRead(conversationId: String) {
        let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId)
        conversation?.markAllMessages(asRead: nil)
    }
    
    public func bindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveLocalNotify(notification:)), name: Notification.Name("EaseChatUIKit_Conversation_last_message_need_update"), object: nil)
    }
    
    @objc private func receiveLocalNotify(notification: Notification) {
        if let conversationId = notification.object as? String , let message = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId)?.latestMessage {
            self.notifyHandler(message: message,local: true)
        }
    }
    
    public func unbindConversationEventsListener(listener: ConversationServiceListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    
    public func registerEmergencyListener(listener: ConversationEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            return
        }
        self.eventsNotifiers.add(listener)
    }
    
    public func unregisterEmergencyListener(listener: ConversationEmergencyListener) {
        if self.eventsNotifiers.contains(listener) {
            self.eventsNotifiers.remove(listener)
        }
    }
    
    public func handleResult(error: ChatError?,type: ConversationEmergencyType) {
        for listener in self.eventsNotifiers.allObjects {
            listener.onResult(error: error, type: type)
        }
    }
    
    public func notifyUnreadCount(count: UInt) {
        for listener in self.eventsNotifiers.allObjects {
            listener.onConversationsUnreadCountUpdate(unreadCount: count)
        }
    }
    
    public func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ComponentsRegister.shared.Conversation.init()
            conversation.id = $0.conversationId
            var nickname = ""
            var profile: ChatUserProfileProtocol?
            if $0.type == .chat {
                profile = ChatUIKitContext.shared?.userCache?[$0.conversationId]
            } else {
                profile = ChatUIKitContext.shared?.groupCache?[$0.conversationId]
                if ChatUIKitContext.shared?.groupProfileProvider == nil,ChatUIKitContext.shared?.groupProfileProviderOC == nil {
                    profile?.nickname = ChatGroup(id: $0.conversationId).groupName ?? ""
                }
            }
            if nickname.isEmpty {
                nickname = profile?.remark ?? ""
            }
            if nickname.isEmpty {
                nickname = profile?.nickname ?? ""
            }
            if nickname.isEmpty {
                nickname = $0.conversationId
            }
            conversation.unreadCount = UInt($0.unreadMessagesCount)
            conversation.lastMessage = $0.latestMessage
            conversation.type = ChatUserProfileProviderType(rawValue: UInt($0.type.rawValue)) ?? .chat
            conversation.pinned = $0.isPinned
            if ChatUIKitClient.shared.option.option_UI.saveConversationInfo {
                if $0.type == .chat {
                    if let nickName = ChatUIKitContext.shared?.userCache?[$0.conversationId]?.nickname as? String {
                        conversation.nickname = nickName
                    }
                    if let avatarURL = ChatUIKitContext.shared?.userCache?[$0.conversationId]?.avatarURL as? String {
                        conversation.avatarURL = avatarURL
                    }
                } else {
                    if let nickName = ChatUIKitContext.shared?.groupCache?[$0.conversationId]?.nickname as? String {
                        conversation.nickname = nickName
                    }
                    if let avatarURL = ChatUIKitContext.shared?.groupCache?[$0.conversationId]?.avatarURL as? String {
                        conversation.avatarURL = avatarURL
                    }
                }
            }
            conversation.doNotDisturb = false
            if let silentMode = self.muteMap[ChatUIKitContext.shared?.currentUserId ?? ""]?[$0.conversationId] {
                conversation.doNotDisturb = silentMode != 0
            }
            
            _ = conversation.showContent
            return conversation
        }
    }
}


extension ConversationServiceImplement: ChatEventsListener {
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for message in aMessages {
            self.notifyHandler(message: message, local: false)
        }
    }
    
    public func messagesInfoDidRecall(_ aRecallMessagesInfo: [RecallInfo]) {
        for info in aRecallMessagesInfo {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(info.recallMessage?.conversationId ?? "") {
                let alertMessage = ChatMessage(conversationID: conversation.conversationId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ["something":"recalled a message".chat.localize])
                alertMessage.timestamp = Int64(Date().timeIntervalSince1970*1000)
                alertMessage.localTime = Int64(Date().timeIntervalSince1970*1000)
                alertMessage.from = info.recallBy
                conversation.insert(alertMessage, error: nil)
                self.notifyHandler(message: alertMessage, local: true)
            }
            
        }
    }
    
    public func onMessageContentChanged(_ message: ChatMessage, operatorId: String, operationTime: UInt) {
        self.notifyHandler(message: message, local: false)
    }
    
    private func notifyHandler(message: ChatMessage,local: Bool) {
        guard let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(message.conversationId) else {
            return
        }
        if conversation.ext == nil {
            conversation.ext = [:]
        }
        if !message.mention.isEmpty {
            conversation.ext?["EaseChatUIKit_mention"] = true
        }
        let list = self.mapper(objects: [conversation])
        for listener in self.responseDelegates.allObjects {
            if let info = list.first {
                listener.onConversationLastMessageUpdate(message: message, info: info)
            }
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.5) {
            for handler in self.eventsNotifiers.allObjects {
                if let info = list.first {
                    handler.onConversationLastMessageUpdate(message: message, info: info)
                }
            }
        }
    }
    
    public func conversationListDidUpdate(_ aConversationList: [ChatConversation]) {
        let list = self.mapper(objects: aConversationList)
        for listener in self.responseDelegates.allObjects {
            listener.onChatConversationListDidChanged(list: list)
        }
    }
    
    public func onConversationRead(_ from: String, to: String) {
        if from == ChatUIKitContext.shared?.currentUserId ?? "" {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(to) {
                self.onConversationReadCallback(conversation: conversation)
            } else {
                if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(from) {
                    self.onConversationReadCallback(conversation: conversation)
                }
            }
        }
        
    }
    
    @objc open func onConversationReadCallback(conversation: ChatConversation ) {
//        conversation.markAllMessages(asRead: nil)
        if let info = self.mapper(objects: [conversation]).first{
            info.unreadCount = 0
            for listener in self.responseDelegates.allObjects {
                listener.onConversationMessageAlreadyReadOnOtherDevice(info: info)
            }
            
            for handler in self.eventsNotifiers.allObjects {
                handler.onResult(error: nil, type: .read)
            }
        }
    }

}

//MARK: - ChatClientListener data sync
extension ConversationServiceImplement: ChatClientListener {
    
    public func onDatabaseOpened(_ error: ChatError?, username: String) {
        // The local database is the earliest point at which cached conversations are queryable
        // (it opens before data sync). Pages may already be visible by now, so load the local data
        // immediately instead of waiting for the sync to finish (which may be delayed or not fire).
        guard error == nil else { return }
        self.loadExistConversations()
    }
    
    public func syncDataStart(with type: DataSyncType) {
        guard type.contains(.conversations) else { return }
        for listener in self.responseDelegates.allObjects {
            listener.onConversationSyncingStatusChanged?(syncing: true, error: nil)
        }
    }
    
    public func syncDataFinished(_ error: ChatError?, type: DataSyncType) {
        guard type.contains(.conversations) else { return }
        if error == nil {
            self.loadExistConversations()
        }
        for listener in self.responseDelegates.allObjects {
            listener.onConversationSyncingStatusChanged?(syncing: false, error: error)
        }
    }
}
