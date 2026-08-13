import Foundation

public let ChatUIKit_VERSION = "5.0.0"

public let cache_update_notification = "ChatUIKitContextUpdateCache"

@objcMembers public class ChatUIKitOptions: NSObject {
    
    /// The option of UI components.
    public var option_UI: UIOptions = UIOptions()
    
    /// The option of chat sdk function.
    public var option_chat: ChatOptions = ChatOptions()
    
    
}

@objcMembers final public class ChatOptions: ChatSDKOptions {
}

@objcMembers public class UIOptions: NSObject {
    
    
    /// Whether to store session avatars and nicknames in EaseChatUIKit.
    public var saveConversationInfo = true
    
    /// Whether to play a sound when new messages are received
    public var soundOnReceivedNewMessage = true
    
    /// Whether load messages from local database.
    public var loadLocalHistoryMessages = true
    
    /// Whether using contact list module.
    public var enableContact = true
    
    /// Whether compatible with older versions of user information transmission or not.
    public var compatibilityModeForUserInfo = false
}

@objcMembers public class ChatUIKitClient: NSObject {
        
    public static let shared = ChatUIKitClient()
    
    /// User-related protocol implementation class.
    public private(set) lazy var userService: UserServiceProtocol? = nil
    
    /// Contact-related protocol implementation class.
    public private(set) lazy var contactService: ContactServiceProtocol? = nil
    
    /// Options function wrapper.
    public var option: ChatUIKitOptions = ChatUIKitOptions()
    
    /// Business objects that want to be notified about the data-sync lifecycle.
    private let dataSyncListeners = NSHashTable<ChatDataSyncListener>.weakObjects()
    
    /// Initializes the ease chat UIKit.
    /// - Parameters:
    ///   - option: The unique identifier that Chat assigns to each app.``ChatOptions``
    /// Returns the initialization success or an error that includes the description of the cause of the failure.
    @objc(setupWithAppKey:option:)
    public func setup(appKey: String? = nil,option: ChatOptions? = nil) -> ChatError? {
        var error: ChatError?
        if let options = option {
            options.uiKitVersion = ChatUIKit_VERSION
            error = ChatClient.shared().initializeSDK(with: options)
            if options.enableUserInfo {
                self.userService = UserServiceImplement()
            }
        } else {
            if let key = appKey {
                let options = ChatOptions(appkey: key)
                options.uiKitVersion = ChatUIKit_VERSION
                options.enableUserInfo = true
                options.dataSyncType = [.conversations, .contacts, .joinedGroups]
                error = ChatClient.shared().initializeSDK(with: options)
                self.userService = UserServiceImplement()
            }
            error = ChatError(description: "App key can't be nil", code: .invalidAppkey)
        }
        if ChatUIKitClient.shared.option.option_UI.enableContact {
            self.contactService = ContactServiceImplement()
        }
        ChatClient.shared().add(self, delegateQueue: .main)
        return error
    }
    
    /// Registers a listener to receive the unified data-sync lifecycle events.
    /// - Parameter listener: ``ChatDataSyncListener``
    @objc public func addDataSyncListener(_ listener: ChatDataSyncListener) {
        if !self.dataSyncListeners.contains(listener) {
            self.dataSyncListeners.add(listener)
        }
    }
    
    /// Removes a previously registered data-sync listener.
    /// - Parameter listener: ``ChatDataSyncListener``
    @objc public func removeDataSyncListener(_ listener: ChatDataSyncListener) {
        if self.dataSyncListeners.contains(listener) {
            self.dataSyncListeners.remove(listener)
        }
    }
    
    /// Fans an action out to every registered listener (invoked on the main thread).
    fileprivate func dispatchToDataSyncListeners(_ action: (ChatDataSyncListener) -> Void) {
        for listener in self.dataSyncListeners.allObjects {
            action(listener)
        }
    }
    
    /// Fans an action out to listeners whose interested type is contained in `type` (main thread).
    fileprivate func dispatchToDataSyncListeners(type: DataSyncType, action: (ChatDataSyncListener) -> Void) {
        for listener in self.dataSyncListeners.allObjects where type.contains(listener.interestedSyncType) {
            action(listener)
        }
    }
    
    /// Login user.
    /// - Parameters:
    ///   - user: An instance that conforms to ``ChatUserProfileProtocol``.
    ///   - token: The user chat token.
    @objc(loginWithUser:token:completion:)
    public func login(user: ChatUserProfileProtocol,token: String,completion: @escaping (ChatError?) -> Void) {
        ChatUIKitContext.shared?.currentUser = user
        ChatUIKitContext.shared?.chatCache?[user.id] = user
        ChatUIKitContext.shared?.userCache?[user.id] = user
        if self.userService != nil {
            self.userService?.login(userId: user.id, token: token, completion: {[weak self] success, error in
                if error == nil {
                    self?.updateUserInfoIfNeed(user: user)
                }
                completion(error)
            })
        } else {
            self.userService = UserServiceImplement(userInfo: user, token: token, completion: {[weak self] error in
                if error == nil {
                    self?.updateUserInfoIfNeed(user: user)
                }
                completion(error)
            })
        }
    }
    
    /// Logout user
    @objc public func logout(unbindNotificationDeviceToken: Bool = false,completion: @escaping (ChatError?) -> Void) {
        ChatClient.shared().logout(unbindNotificationDeviceToken) { error in
            completion(error)
        }
    }
    
    /// Register a user to listen for callbacks that monitor user status changes.
    /// - Parameter listener: ``UserStateChangedListener``
    @objc public func registerUserStateListener(_ listener: UserStateChangedListener) {
        if self.userService == nil {
            self.userService = UserServiceImplement()
        }
        self.userService?.bindUserStateChangedListener(listener: listener)
    }
    
    /// Remove monitoring of user status changes.
    /// - Parameter listener: ``UserStateChangedListener``
    @objc public func unregisterUserStateListener(_ listener: UserStateChangedListener) {
        self.userService?.unBindUserStateChangedListener(listener: listener)
    }
    
    /// unregister theme.
    @objc public func unregisterThemes() {
        Theme.unregisterSwitchThemeViews()
    }
    
//    /// Updates user information that is used for login with the `login(with user: UserInfoProtocol,token: String,use userProperties: Bool = true,completion: @escaping (ChatError?) -> Void)` method.
//    /// - Parameters:
//    ///   - info: An instance that conforms to ``ChatUserProfileProtocol``.
//    ///   - completion: Callback.
//    @objc(updateWithUserInfo:completion:)
//    public func updateUserInfo(info: ChatUserProfileProtocol,completion: @escaping (ChatError?) -> Void) {
//        self.userService?.updateUserInfo(userInfo: info, completion: { success, error in
//            completion(error)
//        })
//    }
    
    ///  Refreshes the user chat token when receiving the ``ChatClientListener.onUserTokenWillExpired`` callback.
    /// - Parameter token: The user chat token.
    @objc(refreshWithToken:)
    public func refreshToken(token: String) {
        ChatClient.shared().renewToken(token)
    }
    
    
    private func updateUserInfoIfNeed(user: ChatUserProfileProtocol) {
        guard let profiles = ChatClient.shared().userInfoManager?.getUserInfo(byIds: [user.id]),
           let profile = profiles[user.id] else {
            let userInfo = UserInfo()
            userInfo.userId = user.id
            userInfo.avatarUrl = user.avatarURL
            ChatClient.shared().userInfoManager?.updateOwn(userInfo)
            return
        }
        if user.nickname == profile.nickname,
           user.avatarURL == profile.avatarUrl {
            return
        }
        let userInfo = profile
        userInfo.nickname = user.nickname
        userInfo.avatarUrl = user.avatarURL
        ChatClient.shared().userInfoManager?.updateOwn(userInfo)
    }
}

//MARK: - ChatClientListener
extension ChatUIKitClient: ChatClientListener {
    
    public func onDatabaseOpened(_ error: ChatError?, username: String) {
        guard error == nil else { return }
        self.dispatchToDataSyncListeners { $0.onChatDatabaseOpened?() }
    }
    
    public func syncDataStart(with type: DataSyncType) {
        self.dispatchToDataSyncListeners(type: type) { $0.onChatDataSyncStart?(type: type) }
    }
    
    public func syncDataFinished(_ error: ChatError?, type: DataSyncType) {
        self.dispatchToDataSyncListeners(type: type) { $0.onChatDataSyncFinished?(error: error,type: type) }
    }
}

