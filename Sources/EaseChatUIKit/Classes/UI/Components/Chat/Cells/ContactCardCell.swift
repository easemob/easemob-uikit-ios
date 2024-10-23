//
//  ContactCardCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/5.
//

import UIKit

@objc open class ContactCardCell: MessageCell {
    
    public private(set) lazy var content: UIView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> UIView {
        ContactCardView(frame: .zero, towards: self.towards).backgroundColor(.clear).tag(bubbleTag)
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
        let frame = Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame:self.bubbleMultiCorners.frame
        self.content.frame = CGRect(x: 0, y: 0, width: frame.width-(Appearance.chat.bubbleStyle == .withArrow ? 5:0), height: frame.height)
        (self.content as? ContactCardView)?.refresh(entity: entity)
    }

}
