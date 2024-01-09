//
//  LocationMessageCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/12/29.
//

import UIKit

@objc open class LocationMessageCell: MessageCell {

    public private(set) lazy var content: UIView = {
        UIView(frame: .zero).backgroundColor(.clear).tag(bubbleTag)
    }()
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.addSubview(self.content)
        } else {
            self.bubbleMultiCorners.addSubview(self.content)
        }
        self.addGestureTo(view: self.content, target: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        let frame = Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame:self.bubbleMultiCorners.frame
        let size = frame.size
        self.content.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if entity.message.direction == .receive {
            //render receive UI
        } else {
            //render send UI
        }
    }
    
    public override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
    }

}
