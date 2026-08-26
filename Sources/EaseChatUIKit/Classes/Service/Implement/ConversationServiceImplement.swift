//
//  ConversationServiceImplement.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit



@objc public class ConversationServiceImplement: NSObject {
    
    private let pageSize = UInt8(20)
    
    private var cursor = ""
    
    /// Guards `loadExistConversations` against re-entry: the paging chain advances the shared
    /// `cursor`, so only one server fetch may be in flight at a time.
    private var fetchingFromServer = false
    
    private let fetchingLock = NSLock()
    
    var aa = ""
    
    @UserDefault("EaseChatUIKit_conversation_load_more_finished", defaultValue: [(ChatClient.shared().currentUsername ?? ""):false]) private var loadFinished
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    private var responseDelegates: NSHashTable<ConversationServiceListener> = NSHashTable<ConversationServiceListener>.weakObjects()
    
    public private(set) var eventsNotifiers: NSHashTable<ConversationEmergencyListener> = NSHashTable<ConversationEmergencyListener>.weakObjects()
    
    public override init() {
        super.init()
        ChatClient.shared().chatManager?.add(self, delegateQueue: .main)
        
    }
    
    deinit {
        ChatClient.shared().chatManager?.remove(self)
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
        let items = ChatClient.shared().chatManager?.getAllConversations(true) ?? []
        let userId = ChatClient.shared().currentUsername ?? ""
        if items.count <= 0,!(self.loadFinished[userId] ?? false) {
            // bind / loadIfNotExistCreate / 拉取失败重试 / "New Friend Chat" 通知都会走到这里，
            // 重入会让两条分页链同时改写 cursor，所以已有拉取在进行时直接丢弃本次调用，
            // 进行中的那次结束后会通知到当前所有 listener。
            guard self.beginFetchingFromServer() else {
                consoleLogInfo("loadExistConversations skipped: a server fetch is already in flight", type: .debug)
                return
            }
            let taskGroup = BalancedTaskGroup(label: "loadExistConversations")
            let queue1 = DispatchQueue(label: "conversations.pin")
            let queue2 = DispatchQueue(label: "conversations")

            let pinnedToken = taskGroup.enter(task: "fetchPinnedConversations")
            queue1.async {
                self.fetchPinnedConversations(cursor: "", pageSize: self.pageSize) { [weak self] result, error in
                    guard let `self` = self else {
                        pinnedToken.leave()
                        return
                    }
                    guard error == nil else {
                        self.handleResult(error: error, type: .loadAllConversationFirstLoadUIKit)
                        pinnedToken.leave()
                        return
                    }
                    let pinnedIds = result?.list?.map({ $0.id }) ?? []
                    self.fetchSilentMode(conversationIds: pinnedIds) { [weak self] resultSilent, silentError in
                        defer { pinnedToken.leave() }
                        guard let `self` = self else { return }
                        if let silentError = silentError {
                            self.handleResult(error: silentError, type: .fetchSilent)
                            return
                        }
                        self.cacheSilentMode(conversationIds: pinnedIds, result: resultSilent)
                    }
                }
            }

            let allToken = taskGroup.enter(task: "fetchAllConversations")
            queue2.async {
                self.fetchAllConversations { result, _ in
                    // 每页都会回调一次。`fetchSilentMode` 失败也会带 error，但不代表会话分页结束；
                    // 会话拉取失败时 result 为 nil（cursor 为空），同样在这里 leave。
                    if (result?.cursor ?? "").isEmpty {
                        allToken.leave()
                    }
                }
            }

            taskGroup.notify(queue: .main) { [weak self] in
                guard let `self` = self else { return }
                self.endFetchingFromServer()
                if let conversations = ChatClient.shared().chatManager?.getAllConversations(true) {
                    for listener in self.responseDelegates.allObjects {
                        listener.onChatConversationListDidChanged(list: self.mapper(objects: conversations))
                    }
                }
            }

        } else {
            if let conversations = ChatClient.shared().chatManager?.getAllConversations(true) {
                for listener in self.responseDelegates.allObjects {
                    listener.onChatConversationListDidChanged(list: self.mapper(objects: conversations))
                }
            }
        }
    }
    
    
    /// Claims the "fetching from server" state. Returns `false` when another fetch already owns it.
    private func beginFetchingFromServer() -> Bool {
        self.fetchingLock.lock()
        defer { self.fetchingLock.unlock() }
        if self.fetchingFromServer {
            return false
        }
        self.fetchingFromServer = true
        return true
    }
    
    private func endFetchingFromServer() {
        self.fetchingLock.lock()
        self.fetchingFromServer = false
        self.fetchingLock.unlock()
    }
    
    public func fetchSilentMode(conversationIds: [String], completion: @escaping (Dictionary<String, SilentModeResult>?, ChatError?) -> Void) {
        var conversations = [ChatConversation]()
        for id in conversationIds {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(id) {
                conversations.append(conversation)
            }
        }
        // 空列表或 pushManager 缺失时 SDK 不会回调，这里直接收敛，保证 completion 恰好执行一次
        guard !conversations.isEmpty, let pushManager = ChatClient.shared().pushManager else {
            completion(nil,nil)
            return
        }
        pushManager.getSilentMode(for: conversations,completion: { [weak self] result, error in
            self?.handleResult(error: error, type: .fetchSilent)
            completion(result,error)
        })
    }

    /// Writes the fetched remind types into `muteMap` in a single pass.
    private func cacheSilentMode(conversationIds: [String], result: Dictionary<String,SilentModeResult>?) {
        guard let result = result, !conversationIds.isEmpty else { return }
        let currentUser = ChatUIKitContext.shared?.currentUserId ?? ""
        var conversationMap = self.muteMap[currentUser] ?? [:]
        for id in conversationIds {
            if let silentMode = result[id]?.remindType {
                conversationMap[id] = silentMode.rawValue
            }
        }
        self.muteMap[currentUser] = conversationMap
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
    
    public func fetchPinnedConversations(cursor: String, pageSize: UInt8, completion: @escaping (CursorResult<ConversationInfo>?, ChatError?) -> Void) {
        guard let chatManager = ChatClient.shared().chatManager else {
            completion(nil,nil)
            return
        }
        chatManager.getPinnedConversationsFromServer(withCursor: cursor, pageSize: pageSize, completion: { [weak self] result, error in
            self?.handleResult(error: error, type: .fetchPinned)
            completion(CursorResult(list: self?.mapper(objects: result?.list ?? []), andCursor: cursor),error)
        })
    }
    
    /// Fetches conversations page by page. `completion` fires once per page: a non-empty cursor in
    /// the result means another page is on the way, an empty cursor means the paging finished.
    public func fetchAllConversations(completion: ((CursorResult<ConversationInfo>?,ChatError?) -> Void)?) {
        guard let chatManager = ChatClient.shared().chatManager else {
            completion?(nil,nil)
            return
        }
        chatManager.getConversationsFromServer(withCursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
            guard error == nil else {
                completion?(nil,error)
                return
            }
            guard let `self` = self else {
                completion?(nil,nil)
                return
            }
            self.cursor = result?.cursor ?? ""
            if self.cursor.isEmpty {
                self.loadFinished[ChatClient.shared().currentUsername ?? ""] = true
            }
            guard let list = result?.list else {
                completion?(nil,nil)
                return
            }
            // 服务端没有给下一页游标，或者当前页不满一页，都表示已经拉到底了
            let hasMorePage = !self.cursor.isEmpty && list.count >= Int(self.pageSize)
            let conversationIds = list.compactMap({ $0.conversationId })
            self.fetchSilentMode(conversationIds: conversationIds, completion: { [weak self] resultSilent, silentError in
                guard let `self` = self else {
                    completion?(nil,nil)
                    return
                }
                self.cacheSilentMode(conversationIds: conversationIds, result: resultSilent)
                completion?(CursorResult(list: self.mapper(objects: list), andCursor: hasMorePage ? self.cursor : ""),silentError)
                if hasMorePage {
                    self.fetchAllConversations(completion: completion)
                }
            })
        })
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
        if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId) {
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
            if let dic = conversation.lastMessage?.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
                let from = conversation.lastMessage?.from ?? ""
                let profile_chat = ChatUserProfile()
                profile_chat.setValuesForKeys(dic)
                profile_chat.id = from
                profile_chat.modifyTime = conversation.lastMessage?.timestamp ?? 0
                if ChatUIKitContext.shared?.userCache?[from] == nil {
                    ChatUIKitContext.shared?.userCache?[from] = profile_chat
                } else {
                    ChatUIKitContext.shared?.userCache?[from]?.nickname = profile_chat.nickname
                    ChatUIKitContext.shared?.userCache?[from]?.avatarURL = profile_chat.avatarURL
                }
            }
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

/// A `DispatchGroup` wrapper that keeps `enter`/`leave` balanced and reports the final tally.
///
/// `enter(task:)` hands back a token whose `leave()` is idempotent, so a completion handler that
/// fires more than once can no longer underflow the group and trip the libdispatch assertion
/// "Unbalanced call to dispatch_group_leave()". Every redundant call is counted and logged instead.
final class BalancedTaskGroup {

    final class Token {

        fileprivate let task: String

        fileprivate var finished = false

        private let owner: BalancedTaskGroup

        fileprivate init(owner: BalancedTaskGroup, task: String) {
            self.owner = owner
            self.task = task
        }

        /// Balances the matching `enter`. Calls after the first one are dropped.
        func leave() {
            self.owner.leave(token: self)
        }
    }

    private let dispatchGroup = DispatchGroup()

    private let lock = NSLock()

    private let label: String

    private var enterCount = 0

    private var leaveCount = 0

    private var redundantLeaveCount = 0

    init(label: String) {
        self.label = label
    }

    func enter(task: String) -> Token {
        self.lock.lock()
        self.enterCount += 1
        let count = self.enterCount
        self.lock.unlock()
        self.dispatchGroup.enter()
        consoleLogInfo("\(self.label) enter[\(count)] task: \(task)", type: .debug)
        return Token(owner: self, task: task)
    }

    func notify(queue: DispatchQueue, execute work: @escaping () -> Void) {
        self.dispatchGroup.notify(queue: queue) {
            self.lock.lock()
            let enters = self.enterCount
            let leaves = self.leaveCount
            let redundant = self.redundantLeaveCount
            self.lock.unlock()
            consoleLogInfo("\(self.label) finished. enter: \(enters), leave: \(leaves), redundantLeaveIgnored: \(redundant)", type: redundant > 0 ? .error : .debug)
            work()
        }
    }

    fileprivate func leave(token: Token) {
        self.lock.lock()
        let redundant = token.finished
        token.finished = true
        if redundant {
            self.redundantLeaveCount += 1
        } else {
            self.leaveCount += 1
        }
        let enters = self.enterCount
        let leaves = self.leaveCount
        let redundantCount = self.redundantLeaveCount
        self.lock.unlock()

        if redundant {
            consoleLogInfo("\(self.label) ignored redundant leave of task: \(token.task). enter: \(enters), leave: \(leaves), redundantLeaveIgnored: \(redundantCount)", type: .error)
            return
        }
        consoleLogInfo("\(self.label) leave[\(leaves)] task: \(token.task)", type: .debug)
        self.dispatchGroup.leave()
    }
}
