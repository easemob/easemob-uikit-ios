//
//  ComponentViewsActionHooker.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/7.
//

import UIKit

@objcMembers public class ComponentViewsActionHooker: NSObject {
    
    public static var shared = ComponentViewsActionHooker()
    
    public let chat = ComponentViewsActionHooker.Chat()
    
    public let contact = ComponentViewsActionHooker.Contact()
    
    public let conversation = ComponentViewsActionHooker.Conversation()
    
    @objcMembers public class Conversation: NSObject {
                
        public var swipeAction: ((UIContextualActionType,ConversationInfo) -> Void)?
        
        public var longPressed: ((IndexPath,ConversationInfo) -> Void)?
        
        public var didSelected: ((IndexPath,ConversationInfo) -> Void)?
    }
    
    @objcMembers public class Contact: NSObject {
        
        public var didSelectedContact: ((IndexPath,EaseProfileProtocol) -> Void)?
        
        public var groupWithSelected: ((IndexPath,EaseProfileProtocol) -> Void)?
    }
                
    @objcMembers public class Chat: NSObject {
        
        public var replyClicked: ((MessageEntity) -> Void)?
        
        public var bubbleClicked: ((MessageEntity) -> Void)?
        
        public var bubbleLongPressed: ((MessageEntity) -> Void)?
        
        public var avatarClicked: ((EaseProfileProtocol) -> Void)?
        
        public var avatarLongPressed: ((EaseProfileProtocol) -> Void)?
    }
}
