//
//  UIContextualActionCutom.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/7.
//

import UIKit

@objc public enum UIContextualActionType: UInt {
    case pin
    case unpin
    case delete
    case mute
    case unmute
    case read
    case more
}

@objcMembers open class UIContextualActionChatUIKit: UIContextualAction {
    
    public var actionType: UIContextualActionType = .more
    
    @objc required public convenience init(title: String,style: UIContextualAction.Style, actionType: UIContextualActionType,handler: @escaping UIContextualAction.Handler) {
        self.init(style: style, title: title, handler: handler)
        self.actionType = actionType
    }
    
    func backgroundColor(color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    func icon(image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    
}
