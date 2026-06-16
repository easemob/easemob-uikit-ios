import Foundation

public let ChatUIKit_VERSION = "4.15.0"

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
}

@objcMembers public class ChatUIKitClient: NSObject {
        
    public static let shared = ChatUIKitClient()
    
    /// User-related protocol implementation class.
    public private(set) lazy var userService: UserServiceProtocol? = nil
    
    /// Options function wrapper.
    public var option: ChatUIKitOptions = ChatUIKitOptions()
    
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Array<Dictionary<String,Any>>>()) private var newFriends
    
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
                ChatClient.shared().userInfoManager?.add(self, delegateQueue: nil)
            }
        } else {
            if let key = appKey {
                let options = ChatOptions(appkey: key)
                options.uiKitVersion = ChatUIKit_VERSION
                options.enableUserInfo = true
                error = ChatClient.shared().initializeSDK(with: options)
                ChatClient.shared().userInfoManager?.add(self, delegateQueue: nil)
            }
            error = ChatError(description: "App key can't be nil", code: .invalidAppkey)
        }
        if ChatUIKitClient.shared.option.option_UI.enableContact {
            ChatClient.shared().contactManager?.add(self, delegateQueue: nil)
        }
        return error
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
            self.userService?.login(userId: user.id, token: token, completion: { success, error in
                completion(error)
            })
        } else {
            self.userService = UserServiceImplement(userInfo: user, token: token, completion: completion)
        }
    }
    
    /// Logout user
    @objc public func logout(unbindNotificationDeviceToken: Bool = false,completion: @escaping (ChatError?) -> Void) {
        UserDefaults.standard.removeObject(forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
        
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
    
    /// Converts an array of SDK UserInfo objects into an array of user protocol types used internally by ChatUIKit
    /// - Parameter userInfos: Array of user information returned by the SDK, containing basic information such as user ID, nickname, and avatar
    /// - Returns: An array of user objects that conform to the ChatUserProfileProtocol, suitable for UI display
    public func transformUserInfos(userInfos: [UserInfo]) -> [ChatUserProfileProtocol] {
        // Array to store the converted user objects
        var resultProfiles = [ChatUserProfileProtocol]()
        for info in userInfos {
            let profile = ChatUserProfile()
            profile.id = info.userId ?? ""
            profile.nickname = info.nickname ?? ""
            if let remark = ChatClient.shared().contactManager?.getContact(profile.id)?.remark {
                profile.remark = remark
            }
            profile.avatarURL = info.avatarUrl ?? ""
            resultProfiles.append(profile)
        }
        return resultProfiles
    }
}

extension ChatUIKitClient: ContactEventsListener {
    public func friendRequestDidReceive(fromUser aUsername: String, message aMessage: String?) {
        let requestInfo: [String:Any] = ["userId":aUsername,"timestamp":Date().timeIntervalSince1970*1000,"groupApply":0,"read":0]
        var exist = self.newFriends[saveIdentifier]
        if exist == nil {
            self.newFriends[saveIdentifier] = [requestInfo]
        } else {
            if exist?.first(where: { $0["userId"] as? String == aUsername }) == nil {
                exist?.append(requestInfo)
                self.newFriends[saveIdentifier] = exist
            }
        }
        if let index = Appearance.contact.listHeaderExtensionActions.firstIndex(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let item = Appearance.contact.listHeaderExtensionActions[index]
            item.showBadge = true
            let unreadCount = self.newFriends[saveIdentifier]?.filter({ $0["read"] as? Int == 0 }).count ?? 0
            item.numberCount = UInt(unreadCount)
            Appearance.contact.listHeaderExtensionActions[index].numberCount = UInt(unreadCount)
        }
    }
    
    public func friendRequestDidApprove(byUser aUsername: String) {
        let conversation = ChatClient.shared().chatManager?.getConversation(aUsername, type: .chat, createIfNotExist: true)
        let ext = ["something":("You have added".chat.localize+" "+aUsername+" "+"to say hello".chat.localize)]
        let message = ChatMessage(conversationID: aUsername, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
        conversation?.insert(message, error: nil)
    }
}

extension ChatUIKitClient: UserInfoManagerDelegate {
    public func onSelfUserInfoUpdate(_ aUserInfo: UserInfo) {
        if let profile = transformUserInfos(userInfos: [aUserInfo]).first {
            ChatUIKitContext.shared?.updateChatAndUserTypeCaches(profiles: [profile])
        }
    }
    
    public func onUserInfoUpdate(_ aUserInfos: [String : UserInfo]) {
        ChatUIKitContext.shared?.updateChatAndUserTypeCaches(profiles: transformUserInfos(userInfos: Array(aUserInfos.values)))
    }
}

