//
//  ComponentViewsActionHooker.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/7.
//

import UIKit

/**
 A class that handles action events for various component views in the application.
 
 - Note: This class is a singleton and can be accessed using the `shared` property.
 
 - Warning: Do not create instances of this class directly.
 
 - SeeAlso: `ComponentViewsActionHooker.Chat`, `ComponentViewsActionHooker.Contact`, `ComponentViewsActionHooker.Conversation`
 */
@objcMembers public class ComponentViewsActionHooker: NSObject {
    
    public static var shared = ComponentViewsActionHooker()
    
    public let chat = ChatHooker()
    
    public let contact = ContactHooker()
    
    public let conversation = ConversationHooker()
    
    
}

/**
 A class representing a conversation in the chat UI.
 
 Use this class to handle swipe actions, long press events, and selection events for a conversation.
 */
@objcMembers public class ConversationHooker: NSObject {
    
    public var swipeAction: ((UIContextualActionType,ConversationInfo) -> Void)?
    
    public var longPressed: ((IndexPath,ConversationInfo) -> Void)?
    
    public var didSelected: ((IndexPath,ConversationInfo) -> Void)?
}

/**
 A class representing a contact.
 */
@objcMembers public class ContactHooker: NSObject {
    
    /**
     A closure that is called when a contact is selected.
     
     - Parameters:
     - indexPath: The index path of the selected contact.
     - profile: The profile of the selected contact conforming to ChatUserProfileProtocol.
     */
    public var didSelectedContact: ((IndexPath, ChatUserProfileProtocol) -> Void)?
    
    /**
     A closure that is called when a group is created with the selected contact.
     
     - Parameters:
     - indexPath: The index path of the selected contact.
     - profile: The profile of the selected contact conforming to ChatUserProfileProtocol.
     */
    public var groupWithSelected: ((IndexPath, ChatUserProfileProtocol) -> Void)?
}

/**
 A class representing a chat component.
 
 This class provides various closures for handling different chat events such as reply clicked, bubble clicked, bubble long pressed, avatar clicked, and avatar long pressed.
 */
@objcMembers public class ChatHooker: NSObject {
    
    public var replyClicked: ((MessageEntity) -> Void)?
    
    public var bubbleClicked: ((MessageEntity) -> Void)?
    
    public var bubbleLongPressed: ((MessageEntity) -> Void)?
    
    public var avatarClicked: ((ChatUserProfileProtocol) -> Void)?
    
    public var avatarLongPressed: ((ChatUserProfileProtocol) -> Void)?
}
