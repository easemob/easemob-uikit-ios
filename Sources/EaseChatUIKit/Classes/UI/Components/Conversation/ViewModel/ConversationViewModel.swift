//
//  ConversationViewModel.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import Foundation
import AudioToolbox


/// Bind service and driver
@objc open class ConversationViewModel: NSObject {
    
    /// Map to store session settings do not disturb.
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    /// When conversation clicked.
    @objc public var toChat: ((IndexPath,ConversationInfo) -> Void)?
    
    @objc public var chatId = ""
    
    @objc private weak var provider_OC: EaseProfileProviderOC?
    
    private var provider: EaseProfileProvider?
    
    /// ``ConversationViewModel`` init method.
    /// - Parameter providerOC: Only available in Objective-C language.
    @objc(initWithProviderOC:)
    public required init(providerOC: EaseProfileProviderOC?) {
        self.provider_OC = providerOC
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(loadExistLocalDataIfEmptyFetchServer), name: Notification.Name("New Friend Chat"), object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name("EaseUIKit_do_not_disturb_changed"), object: nil, queue: .main) { [weak self] notify in
            if let userInfo = notify.userInfo {
                if let id = userInfo["id"] as? String {
                    if let doNotDisturb = userInfo["value"] as? Bool {
                        let info = ComponentsRegister.shared.Conversation.init()
                        info.id = id
                        self?.driver?.swipeMenuOperation(info: info, type: doNotDisturb == true ? .mute:.unmute)
                    }
                }
            }
        }
    }
    
    /// ``ConversationViewModel`` init method.
    /// - Parameter providerOC: Only available in Swift language.
    public required init(provider: EaseProfileProvider?) {
        self.provider = provider
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(loadExistLocalDataIfEmptyFetchServer), name: Notification.Name("New Friend Chat"), object: nil)
        NotificationCenter.default.addObserver(forName: Notification.Name("EaseUIKit_do_not_disturb_changed"), object: nil, queue: .main) { [weak self] notify in
            if let userInfo = notify.userInfo {
                if let id = userInfo["id"] as? String {
                    if let doNotDisturb = userInfo["value"] as? Bool {
                        let info = ComponentsRegister.shared.Conversation.init()
                        info.id = id
                        self?.driver?.swipeMenuOperation(info: info, type: doNotDisturb == true ? .mute:.unmute)
                    }
                }
            }
        }
    }
    
    public private(set) weak var driver: IConversationListDriver?
    
    public private(set) var service: ConversationServiceImplement? = ConversationServiceImplement()
    
    public private(set) var contactService: ContactServiceProtocol? = ContactServiceImplement()
    
    public private(set) var multiService: MultiDeviceService?  = MultiDeviceServiceImplement()
    
    /// Bind UI driver and service
    /// - Parameters:
    ///   - driver: The object of conform``IConversationListDriver``.
    @objc open func bind(driver: IConversationListDriver) {
        self.driver = driver
        self.service?.unbindConversationEventsListener(listener: self)
        self.service?.bindConversationEventsListener(listener: self)
        _ = self.contactService
        self.multiService?.unbindMultiDeviceListener(listener: self)
        self.multiService?.bindMultiDeviceListener(listener: self)
        self.driver?.addActionHandler(actionHandler: self)
        self.loadExistLocalDataIfEmptyFetchServer()
    }
    
    /// Register to monitor when certain emergencies occur
    /// - Parameter listener: ``ConversationEmergencyListener``
    @objc open func registerEventsListener(listener: ConversationEmergencyListener) {
        self.service?.unregisterEmergencyListener(listener: listener)
        self.service?.registerEmergencyListener(listener: listener)
    }
    
    /// When you don’t want to listen to the registered events above, you can use this method to clear the registration.
    /// - Parameter listener: ``ConversationEmergencyListener``
    @objc open func unregisterEventsListener(listener: ConversationEmergencyListener) {
        self.service?.unregisterEmergencyListener(listener: listener)
    }
    
    /// Load all sessions that exist locally. If they do not exist, load them from the server.
    @objc open func loadExistLocalDataIfEmptyFetchServer() {
        self.service?.loadExistConversations(completion: { [weak self] result, error in
            if error == nil {
                self?.driver?.refreshList(infos: result)
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadExistOtherwiseFetchServer error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    
    /// Load the session in the local database and create one if it does not exist
    /// - Parameters:
    ///   - profile: ``EaseProfileProtocol``
    ///   - text: Welcome message.
    /// - Returns: ``ConversationInfo`` object.
    @objc(loadIfNotExistCreateWithProfile:type:text:)
    open func loadIfNotExistCreate(profile: EaseProfileProtocol,type: ChatConversationType,text: String) -> ConversationInfo? {
        if let conversation = self.service?.loadIfNotExistCreate(conversationId: profile.id,type: type) {
            if let info = self.mapper(objects: [conversation]).first,!info.id.isEmpty {
                if conversation.type == .groupChat {
                    let content = "Group".chat.localize + " [\(text)] " + "has been created.".chat.localize
                    conversation.insert(self.welcomeMessage(conversationId: info.id,text: content), error: nil)
                }
                self.loadExistLocalDataIfEmptyFetchServer()
                return info
            }
            return nil
        }
        return nil
    }
    
    @objc open func welcomeMessage(conversationId: String,text: String) -> ChatMessage {
        ChatMessage(conversationID: conversationId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: text.isEmpty ? nil:["something":text])
    }
    
    @objc open func destroyed() {
        self.driver?.removeActionHandler(actionHandler: self)
        self.service?.unbindConversationEventsListener(listener: self)
        self.multiService?.unbindMultiDeviceListener(listener: self)
        self.driver = nil
        self.service = nil
        self.multiService = nil
    }
    
    deinit {
        destroyed()
    }
}

//MARK: - ConversationListActionEventsDelegate
extension ConversationViewModel: ConversationListActionEventsDelegate {
    
    public func onConversationListOccurErrorWhenFetchServer() {
        self.loadExistLocalDataIfEmptyFetchServer()
    }
    
    public func onConversationListEndScrollNeededDisplayInfos(ids: [String]) {
        var privateChats = [String]()
        var groupChats = [String]()
        for id in ids {
            if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(id) {
                if conversation.type == .chat {
                    privateChats.append(id)
                } else {
                    groupChats.append(id)
                }
            }
        }
        if self.provider_OC != nil {
            let infoMap_OC = [0:privateChats,1:groupChats]
            self.provider_OC?.fetchProfiles(profilesMap: infoMap_OC, completion: { [weak self] profiles in
                self?.renderDriver(infos: profiles)
                for profile in profiles {
                    EaseChatUIKitContext.shared?.conversationsCache?[profile.id] = profile
                }
            })
        }
        if self.provider != nil {
            let infoMap = [EaseProfileProviderType.chat:privateChats,EaseProfileProviderType.group:groupChats]
            Task(priority: .background) {
                let profiles = await self.provider?.fetchProfiles(profilesMap: infoMap) ?? []
                for profile in profiles {
                    EaseChatUIKitContext.shared?.conversationsCache?[profile.id] = profile
                }
                DispatchQueue.main.async {
                    self.renderDriver(infos: profiles)
                }
            }
        }
    }
    
    @objc open func renderDriver(infos: [EaseProfileProtocol]) {
        self.driver?.refreshProfiles(infos: infos)
        if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
            for info in infos {
                EaseChatUIKitContext.shared?.conversationsCache?[info.id] = info
            }
        }
    }
    
    public func onConversationListRefresh() {
        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
            self.driver?.refreshList(infos: self.mapper(objects: infos))
        }
    }
    
    @objc open func pin(info: ConversationInfo) {
        self.service?.pin(conversationId: info.id) { [weak self] error in
            guard let `self` = self else { return }
            if error != nil {
                consoleLogInfo("onConversationSwipe pin:\(error?.errorDescription ?? "")", type: .error)
            } else {
                if let idx = Appearance.conversation.swipeLeftActions.firstIndex(where: { $0 == .pin }) {
                    Appearance.conversation.swipeLeftActions[idx] = .unpin
                }
                if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                    self.driver?.refreshList(infos: self.mapper(objects: infos))
                }
            }
        }
    }
    
    @objc open func unpin(info: ConversationInfo) {
        self.service?.unpin(conversationId: info.id) { [weak self] error in
            guard let `self` = self else { return }
            if error != nil {
                consoleLogInfo("onConversationSwipe unpin:\(error?.errorDescription ?? "")", type: .error)
            } else {
                if let idx = Appearance.conversation.swipeLeftActions.firstIndex(where: { $0 == .unpin }) {
                    Appearance.conversation.swipeLeftActions[idx] = .pin
                }
                if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                    self.driver?.refreshList(infos: self.mapper(objects: infos))
                }
            }
        }
    }
    
    @objc open func mute(info: ConversationInfo) {
        self.service?.setSilentMode(conversationId: info.id) { [weak self] _, error in
            if error != nil {
                consoleLogInfo("onConversationSwipe mute:\(error?.errorDescription ?? "")", type: .error)
            } else {
                let currentUser = EaseChatUIKitContext.shared?.currentUserId ?? ""
                var conversationMap = self?.muteMap[currentUser]
                if conversationMap != nil {
                    conversationMap?[info.id] = 1
                } else {
                    conversationMap = [info.id:1]
                }
                self?.muteMap[currentUser] = conversationMap
                self?.driver?.swipeMenuOperation(info: info, type: .mute)
            }
        }
    }
    
    @objc open func delete(info: ConversationInfo) {
        self.service?.deleteConversation(conversationId: info.id) { [weak self] error in
            guard let `self` = self else { return }
                if error != nil {
                    consoleLogInfo("onConversationSwipe delete:\(error?.errorDescription ?? "")", type: .error)
                } else {
                    if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                        self.driver?.refreshList(infos: self.mapper(objects: infos))
                    }
                }
            }
    }
    
    @objc open func unmute(info: ConversationInfo) {
        self.service?.clearSilentMode(conversationId: info.id) { [weak self] _, error in
            if error != nil {
                consoleLogInfo("onConversationSwipe unmute:\(error?.errorDescription ?? "")", type: .error)
            } else {
                let currentUser = EaseChatUIKitContext.shared?.currentUserId ?? ""
                var conversationMap = self?.muteMap[currentUser]
                if conversationMap != nil {
                    conversationMap?[info.id] = 0
                } else {
                    conversationMap = [info.id:0]
                }
                self?.muteMap[currentUser] = conversationMap
                self?.driver?.swipeMenuOperation(info: info, type: .unmute)
            }
        }
    }
    
    @objc open func read(info: ConversationInfo) {
        info.unreadCount = 0
        self.driver?.swipeMenuOperation(info: info, type: .read)
        self.service?.markAllMessagesAsRead(conversationId: info.id)
    }
    
    public func onConversationSwipe(type: UIContextualActionType, info: ConversationInfo) {
        if let hooker = ComponentViewsActionHooker.shared.conversation.swipeAction {
            hooker(type, info)
        } else {
            switch type {
            case .pin: self.pin(info: info)
            case .unpin: self.unpin(info: info)
            case .mute: self.mute(info: info)
            case .unmute: self.unmute(info: info)
            case .delete: self.delete(info: info)
            case .read: self.read(info: info)
            case .more: self.moreAction(info: info)
            }
        }
    }
    
    public func onConversationDidSelected(indexPath: IndexPath, info: ConversationInfo) {
        self.conversationDidSelected(indexPath: indexPath, info: info)
    }
    
    @objc open func conversationDidSelected(indexPath: IndexPath, info: ConversationInfo) {
        self.chatId = info.id
        self.service?.markAllMessagesAsRead(conversationId: info.id)
        ChatClient.shared().chatManager?.ackConversationRead(info.id)
        self.driver?.swipeMenuOperation(info: info, type: .read)
        self.toChat?(indexPath,info)
    }
    
    public func onConversationLongPressed(indexPath: IndexPath, info: ConversationInfo) {
        if let hooker = ComponentViewsActionHooker.shared.conversation.longPressed {
            hooker(indexPath,info)
        } else {
            consoleLogInfo("onConversationLongPressed", type: .debug)
        }
    }
    
    @objc open func moreAction(info: ConversationInfo) {
        DialogManager.shared.showMessageActions(actions: Appearance.conversation.moreActions) { item  in
            //According to item tag
/// -            switch item.tag {
/// -            case "xxx":
/// -            default: break
/// -            }
            item.action?(item,info)
        }
    }
}


//MARK: - ConversationServiceListener
extension ConversationViewModel: ConversationServiceListener {
    public func onConversationLastMessageUpdate(message: ChatMessage, info: ConversationInfo) {
        self.conversationLastMessageUpdate(message: message, info: info)
    }
    
    @objc open func conversationLastMessageUpdate(message: ChatMessage, info: ConversationInfo) {
        if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
            let items = self.mapper(objects: infos)
            var count = UInt(0)
            for item in items where item.doNotDisturb == false {
                count += item.unreadCount
            }
            self.service?.notifyUnreadCount(count: count)
            self.driver?.refreshList(infos: items)
            if !info.doNotDisturb,EaseChatUIKitClient.shared.option.option_chat.soundOnReceivedNewMessage,UIApplication.shared.applicationState == .active,self.chatId != info.id {
                self.playNewMessageSound()
            }
        }
    }
    
    @objc open func playNewMessageSound() {
        let audioPath = NSURL(fileURLWithPath: Appearance.chat.newMessageSoundPath)
        var soundID: SystemSoundID = 0
        let completion: @convention(c) (SystemSoundID, UnsafeMutableRawPointer?) -> Void = { soundId, pointer in
            AudioServicesDisposeSystemSoundID(soundId)
            }
        AudioServicesCreateSystemSoundID(audioPath, &soundID) // Register the sound completion callback.
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, completion, nil)
    }
    
    
    public func onChatConversationListDidChanged(list: [ConversationInfo]) {
        consoleLogInfo("onChatConversationListDidChanged", type: .debug)
    }
    
    public func onConversationMessageAlreadyReadOnOtherDevice(info: ConversationInfo) {
        self.conversationMessageAlreadyReadOnOtherDevice(info: info)
    }
    
    @objc open func conversationMessageAlreadyReadOnOtherDevice(info: ConversationInfo) {
        info.unreadCount = 0
        self.service?.markAllMessagesAsRead(conversationId: info.id)
        self.driver?.swipeMenuOperation(info: info, type: .read)
    }
}

//MARK: - MultiDeviceListener
extension ConversationViewModel: MultiDeviceListener {
    public func onConversationEventDidChanged(event: MultiDeviceEvent, conversationId: String, conversationType: ChatConversationType) {
        self.conversationEventDidChanged(event: event, conversationId: conversationId, conversationType: conversationType)
    }
    
    @objc open func conversationEventDidChanged(event: MultiDeviceEvent, conversationId: String, conversationType: ChatConversationType) {
        switch event {
        case .conversationPinned,.conversationUnpinned:
            if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                self.driver?.refreshList(infos: self.mapper(objects: infos))
                self.service?.handleResult(error: nil, type: event == .conversationPinned ? .pin:.unpin)
            }
        case .conversationDelete:
            if let infos = ChatClient.shared().chatManager?.getAllConversations(true) {
                if let info = self.mapper(objects: infos).first(where: { $0.id == conversationId }) {
                    self.driver?.swipeMenuOperation(info: info, type: .delete)
                    self.service?.handleResult(error: nil, type: .delete)
                }
            }
            
        default: break
        }
    }
    
    @objc open func mapper(objects: [ChatConversation]) -> [ConversationInfo] {
        objects.map {
            let conversation = ComponentsRegister.shared.Conversation.init()
            conversation.id = $0.conversationId
            conversation.nickname = EaseChatUIKitContext.shared?.conversationsCache?[$0.conversationId]?.nickname ?? ""
            conversation.avatarURL = EaseChatUIKitContext.shared?.conversationsCache?[$0.conversationId]?.avatarURL ?? ""
            if $0.conversationId == self.chatId {
                conversation.unreadCount = 0
            } else {
                conversation.unreadCount = UInt($0.unreadMessagesCount)
            }
            conversation.lastMessage = $0.latestMessage
            conversation.type = EaseProfileProviderType(rawValue: UInt($0.type.rawValue)) ?? .chat
            conversation.pinned = $0.isPinned
            if EaseChatUIKitClient.shared.option.option_chat.saveConversationInfo {
                if let nickName = $0.ext?["EaseChatUIKit_nickName"] as? String {
                    conversation.nickname = nickName
                }
                if let avatarURL = $0.ext?["EaseChatUIKit_avatarURL"] as? String {
                    conversation.avatarURL = avatarURL
                }
            }
            conversation.doNotDisturb = false
            if let silentMode = self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[$0.conversationId] {
                conversation.doNotDisturb = silentMode != 0
            }
            
            _ = conversation.showContent
            return conversation
        }
    }
}
