//
//  ChatServiceImplement.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objcMembers public class ChatServiceImplement: NSObject {
    private var responseDelegates: NSHashTable<ChatResponseListener> = NSHashTable<ChatResponseListener>.weakObjects()
    
    public private(set) var to = ""
    
    @objc required public init(to: String) {
        super.init()
        self.to = to
        ChatClient.shared().chatManager?.add(self, delegateQueue: nil)
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
    }
}

extension ChatServiceImplement: ChatService {
    public func fetchChatThreadHistoryMessages(conversationId: String, cursor: String?, pageSize: UInt, completion: @escaping (ChatError?, [ChatMessage], String?) -> Void) {
        // SDK 5.0 pages server history via an opaque cursor (``EMCursorResult/cursor``). The caller owns
        // the cursor and the "no more" flag; here we simply fetch from the given cursor and hand back the
        // next one (nil for the first page).
        let option = ChatFetchServerMessagesOption()
        option.direction = .down
        ChatClient.shared().chatManager?.fetchMessagesFromServer(by: conversationId, conversationType: .groupChat, cursor: cursor, pageSize: pageSize, option: option, completion: { result, error in
            completion(error, result?.list ?? [], result?.cursor)
        })
    }
    
    
    public func reaction(reaction: String, message: ChatMessage, completion: @escaping (ChatError?) -> Void) {
        let messageReaction = ChatClient.shared().chatManager?.getMessageWithMessageId(message.messageId)?.reactionList?.first(where: { $0.reaction ?? "" == reaction })
        if messageReaction == nil {
            ChatClient.shared().chatManager?.addReaction(reaction, toMessage: message.messageId, completion: { error in
                completion(error)
            })
        } else {
            if messageReaction!.isAddedBySelf {
                ChatClient.shared().chatManager?.removeReaction(reaction, fromMessage: message.messageId, completion: { error in
                    completion(error)
                })
            } else {
                ChatClient.shared().chatManager?.addReaction(reaction, toMessage: message.messageId, completion: { error in
                    completion(error)
                })
            }
        }
    }
    
    public func edit(messageId: String, text: String, completion: @escaping (ChatError?, ChatMessage?) -> Void) {
        let rawMessage = ChatClient.shared().chatManager?.getMessageWithMessageId(messageId)
        let body = ChatTextMessageBody(text: text)
        if let rawBody = rawMessage?.body as? ChatTextMessageBody {
            body.targetLanguages = rawBody.targetLanguages
        }
        ChatClient.shared().chatManager?.modifyMessage(messageId, body: body, ext: nil, completion: { error, message in
            completion(error,message)
        })
    }
    
    public func recall(messageId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.recallMessage(withMessageId: messageId, completion: { error in
            completion(error)
        })
    }
    
    public func bindChatEventsListener(listener: ChatResponseListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindChatEventsListener(listener: ChatResponseListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    public func send(message: ChatMessage, completion: @escaping (ChatError?, ChatMessage?) -> Void) {
        let message = message
        ChatClient.shared().chatManager?.send(message, progress: nil, completion: { message, error in
//            self?.pushSendNotification(message: message)
            completion(error,message)
        })
    }
    
    private func pushSendNotification(message: ChatMessage?) {
        if let conversationId = message?.conversationId {
            NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_Conversation_last_message_need_update"), object: conversationId)
        }
    }
    
    public func removeLocalMessage(messageId: String) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.deleteMessage(withId: messageId, error: nil)
        
    }
    
    public func removeHistoryMessages() {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.deleteAllMessages(nil)
    }
    
    public func markMessageAsRead(messageId: String) {
        if let message = ChatClient.shared().chatManager?.getMessageWithMessageId(messageId) {
            ChatClient.shared().chatManager?.sendMessageReadReceipts([message]) { error in
                
                if error != nil {
                    consoleLogInfo("sendMessageReadReceipts error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
        
    }
    
    public func markAllMessagesAsRead() {
        ChatClient.shared().chatManager?.clearConversationUnreadMessageCount(self.to) { error in
            if error != nil {
                consoleLogInfo("clearConversationUnreadMessageCount error:\(error?.errorDescription ?? "")", type: .error)
            }
        }
    }
    
    public func loadMessages(start messageId: String, cursor: String?, pageSize: UInt, searchMessage: Bool, completion: @escaping (ChatError?, [ChatMessage], String?) -> Void) {
        if ChatUIKitContext.shared?.chatCache == nil {
            ChatUIKitContext.shared?.chatCache = [String:ChatUserProfileProtocol]()
        }
        if ChatUIKitClient.shared.option.option_UI.loadLocalHistoryMessages {
            ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.loadMessagesStart(fromId: messageId, count: Int32(pageSize), searchDirection: searchMessage ? .down:.up,completion: { messages, error in
                if error == nil,let messages = messages {
                    for message in messages {
                        // Compatibility with old data: legacy messages have no `senderInfo`, so fall back
                        // to the sender profile previously stored in the message's `ease_chat_uikit_user_info` ext.
                        if message.senderInfo == nil {
                            if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
                                let user = ChatUIKitContext.shared?.userCache?[message.from] as? ChatUserProfile
                                if user?.modifyTime ?? 0 < message.timestamp {
                                    let user = ChatUserProfile()
                                    user.setValuesForKeys(dic)
                                    if user.id.isEmpty {
                                        user.id = message.from
                                    }
                                    user.modifyTime = message.timestamp
                                    ChatUIKitContext.shared?.chatCache?[message.from] = user
                                }
                            }
                        }
                        if let dic = message.ext?["ease_chat_uikit_text_url_preview"] as? Dictionary<String,String>,let url = dic["url"] {
                            let content = URLPreviewManager.HTMLContent()
                            if let description = dic["description"] {
                                content.descriptionHTML = description
                            }
                            if let imageURL = dic["imageUrl"] {
                                content.imageURL = imageURL
                            }
                            if let title = dic["title"] {
                                content.title = title
                                URLPreviewManager.caches[url] = content
                            }
                            content.towards = message.direction == .send ? .right:.left
                        }
                    }
                }
                completion(error,messages ?? [],nil)
            })
        } else {
            let type = ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.type ?? .chat
            let option = ChatFetchServerMessagesOption()
            option.direction = searchMessage ? .down:.up
            let cacheSenderInfo: (ChatMessage) -> Void = { message in
                guard message.senderInfo == nil else { return }
                if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
                    let user = ChatUIKitContext.shared?.userCache?[message.from] as? ChatUserProfile
                    if user?.modifyTime ?? 0 < message.timestamp {
                        let user = ChatUserProfile()
                        user.setValuesForKeys(dic)
                        if user.id.isEmpty {
                            user.id = message.from
                        }
                        user.modifyTime = message.timestamp
                        ChatUIKitContext.shared?.chatCache?[message.from] = user
                    }
                }
            }
            if searchMessage {
                // Anchored jump to a specific (locally available) message: page forward from its
                // timestamp. The new server API has no message-id anchor, so we use the time window.
                if let timestamp = ChatClient.shared().chatManager?.getMessageWithMessageId(messageId)?.timestamp {
                    option.startTime = Int(timestamp) + 1
                }
                ChatClient.shared().chatManager?.fetchMessagesFromServer(by: self.to, conversationType: type, cursor: nil, pageSize: pageSize, option: option, completion: { result, error in
                    if error == nil, let messages = result?.list {
                        for message in messages { cacheSenderInfo(message) }
                    }
                    // Anchored search is a one-shot fetch, so there is no continuation cursor.
                    completion(error,result?.list ?? [],nil)
                })
                return
            }
            // Load older page. SDK 5.0 pages via an opaque cursor. The caller owns the cursor and the
            // "no more" flag and passes the cursor in (nil for the first page); we hand back the next one.
            ChatClient.shared().chatManager?.fetchMessagesFromServer(by: self.to, conversationType: type, cursor: cursor, pageSize: pageSize, option: option, completion: { result, error in
                if error == nil, let messages = result?.list {
                    for message in messages { cacheSenderInfo(message) }
                }
                completion(error,result?.list ?? [],result?.cursor)
            })
        }
    }
    
    public func searchMessage(keyword: String, pageSize: UInt, userId: String, completion: @escaping (ChatError?, [ChatMessage]) -> Void) {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.to)?.loadMessages(withKeyword: keyword, timestamp: -1, count: Int32(pageSize), fromUsers: [userId], searchDirection: .up, scope: .content, completion: { messages, error in
            completion(error,messages ?? [])
        })
    }
    
    public func translateMessage(message: ChatMessage, completion: @escaping (ChatError?, ChatMessage?) -> Void) {
        ChatClient.shared().chatManager?.translate(message, targetLanguages: [Appearance.chat.targetLanguage.rawValue], completion: { message,error in
            completion(error,message)
        })
    }
    
    public func pinMessage(messageId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.pinMessage(messageId, completion: { message,error in
            completion(error)
        })
    }
    
    public func unpinMessage(messageId: String, completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().chatManager?.unpinMessage(messageId, completion: { message,error in
            completion(error)
        })
    }
    
    public func pinnedMessages(conversationId: String, completion: @escaping ([ChatMessage]?, ChatError?) -> Void) {
        ChatClient.shared().chatManager?.getPinnedMessages(fromServer: conversationId, completion: { messages, error in
            completion(messages,error)
        })
    }
}

extension ChatServiceImplement: ChatEventsListener {
    
    public func onMessageReadReceipts(_ aReceipts: [MessageReadReceipt]) {
        for listener in self.responseDelegates.allObjects {
            listener.messageReadReceiptReceived(receipt: aReceipts)
        }
    }
    
    public func onMessagePinChanged(_ messageId: String, conversationId: String, operation pinOperation: MessagePinOperation, pinInfo: MessagePinInfo) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageStickiedTop(conversationId: conversationId, messageId: messageId, operation: pinOperation, info: pinInfo)
        }
    }
    
    public func messagesDidReceive(_ aMessages: [ChatMessage]) {
        for listener in self.responseDelegates.allObjects {
            for message in aMessages {
                if message.senderInfo == nil {
                    if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
                        let profile = ChatUserProfile()
                        profile.setValuesForKeys(dic)
                        profile.id = message.from
                        profile.modifyTime = message.timestamp
                        ChatUIKitContext.shared?.chatCache?[message.from] = profile
                        if ChatUIKitContext.shared?.userCache?[message.from] == nil {
                            ChatUIKitContext.shared?.userCache?[message.from] = profile
                        } else {
                            ChatUIKitContext.shared?.userCache?[message.from]?.nickname = profile.nickname
                            ChatUIKitContext.shared?.userCache?[message.from]?.avatarURL = profile.avatarURL
                        }
                    }
                } else {
                    if let profile = message.senderInfo {
                        if ChatUIKitContext.shared?.userCache?[message.from] == nil {
                            let user = ChatUserProfile()
                            user.id = profile.userId ?? message.from
                            user.nickname = profile.nickname ?? ""
                            user.avatarURL = profile.avatarUrl ?? ""
                            user.modifyTime = message.timestamp
                            user.remark = profile.remark ?? ""
                            ChatUIKitContext.shared?.userCache?[message.from] = user
                        } else {
                            ChatUIKitContext.shared?.userCache?[message.from]?.nickname = message.senderInfo?.nickname ?? ""
                            ChatUIKitContext.shared?.userCache?[message.from]?.avatarURL = message.senderInfo?.avatarUrl ?? ""
                        }
                    }
                }
                listener.onMessageDidReceived(message: message)
            }
        }
    }
    
    public func cmdMessagesDidReceive(_ aCmdMessages: [ChatMessage]) {
        for listener in self.responseDelegates.allObjects {
            for message in aCmdMessages {
                listener.onCMDMessageDidReceived(message: message)
            }
        }
    }
    
    public func messagesInfoDidRecall(_ aRecallMessagesInfo: [RecallInfo]) {
        for listener in self.responseDelegates.allObjects {
            for info in aRecallMessagesInfo {
                listener.onMessageDidRecalled(recallInfo: info)
            }
        }
    }
    
    public func messageStatusDidChange(_ aMessage: ChatMessage, error aError: ChatError?) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageStatusDidChanged(message: aMessage, status: aError == nil ? .succeed:.failure, error: aError)
        }
    }
    
    public func messageAttachmentStatusDidChange(_ aMessage: ChatMessage, error aError: ChatError?) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageAttachmentStatusChanged(message: aMessage, error: aError)
        }
    }
    
    public func messageReactionDidChange(_ changes: [MessageReactionChange]) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageReactionChanged(changes: changes)
        }
    }
    
    public func messagesDidDeliver(_ aMessages: [ChatMessage]) {
        for aMessage in aMessages {
            for listener in self.responseDelegates.allObjects {
                listener.onMessageStatusDidChanged(message: aMessage, status: .delivered, error: nil)
            }
        }
    }
    
    public func messagesDidRead(_ aMessages: [ChatMessage]) {
        for aMessage in aMessages {
            for listener in self.responseDelegates.allObjects {
                listener.onMessageStatusDidChanged(message: aMessage, status: .read, error: nil)
            }
        }
    }
    
    public func onMessageContentChanged(_ message: ChatMessage, operatorId: String, operationTime: UInt) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageDidEdited(message: message)
        }
    }
    
    
    
}

