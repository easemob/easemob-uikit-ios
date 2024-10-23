//
//  CombineMessageCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/29.
//

import UIKit

@objc open class CombineMessageCell: MessageCell {

    public private(set) lazy var content: CombineMessageView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> CombineMessageView {
        CombineMessageView(frame: .zero).backgroundColor(.clear).tag(bubbleTag)
    }
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.bubble.addSubview(self.content)
        } else {
            self.bubbleMultiCorners.addSubview(self.content)
        }
        self.addGestureTo(view: self.content, target: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        let size = entity.bubbleSize
        self.content.frame = CGRect(x: 0, y: 0, width: size.width - (Appearance.chat.bubbleStyle == .withArrow ? 5:0), height: size.height)
        self.content.refresh(message: entity.message)
    }
    
    open override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
    }

}
