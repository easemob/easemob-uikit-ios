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
    
    /// Contact-related protocol implementation class.
    public private(set) lazy var contactService: ContactServiceProtocol? = nil
    
    /// Options function wrapper.
    public var option: ChatUIKitOptions = ChatUIKitOptions()
    
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
                options.enableAutoSyncContacts = true
                error = ChatClient.shared().initializeSDK(with: options)
                self.userService = UserServiceImplement()
            }
            error = ChatError(description: "App key can't be nil", code: .invalidAppkey)
        }
        if ChatUIKitClient.shared.option.option_UI.enableContact {
            self.contactService = ContactServiceImplement()
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
    
}

