//
//  CombineMessageView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/2/2.
//

import UIKit

@objcMembers open class CombineMessageView: UIView {
    
    public private(set) lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 12, y: 6, width: self.frame.width-24, height: self.frame.height-20)).font(UIFont.theme.bodySmall).numberOfLines(4).lineBreakMode(.byTruncatingTail).backgroundColor(.clear)
    }()
    
    public private(set) lazy var title: UILabel = {
        UILabel(frame:CGRect(x: self.frame.width-200, y: self.content.frame.maxY+4, width: 188, height: 18)).textAlignment(.right)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.content)
        self.addSubview(self.title)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func refresh(message: ChatMessage) {
        self.content.frame = CGRect(x: 12, y: 6, width: self.frame.width-24, height: self.frame.height-20)
        self.title.frame = CGRect(x: self.frame.width-200, y: self.frame.height-22, width: 188, height: 18)
        if let body = message.body as? ChatCombineMessageBody {
            self.content.text = body.summary
        }
        if message.direction == .send {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        } else {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor5
        
        }
        self.title.attributedText = self.constructTitle(message: message)
    }
    
    
    @objc open func constructTitle(message: ChatMessage) -> NSAttributedString {
        let text = NSMutableAttributedString()
        var textColor = Theme.style == .dark ? Color.theme.neutralSpecialColor5:Color.theme.neutralSpecialColor7
        if message.direction == .send {
            textColor = Theme.style == .dark ? Color.theme.neutralSpecialColor3:Color.theme.neutralSpecialColor9
        }
        if let icon = message.replyIcon?.withTintColor(textColor) {
            text.append(NSAttributedString {
                ImageAttachment(icon, bounds: CGRect(x: 0, y: -3.5, width: 16, height: 16))
                AttributedText("Chat History".chat.localize).font(Font.theme.labelMedium).foregroundColor(textColor)
            })
        }
        return text
    }
}
