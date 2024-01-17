//
//  TextMessageCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/12/5.
//

import UIKit

@objc open class TextMessageCell: MessageCell {
    
    public var receiveStateColor: UIColor {
        Theme.style  == .dark ? UIColor.theme.neutralSpecialColor7:UIColor.theme.neutralSpecialColor5
    }
    
    public var sendStateColor: UIColor {
        Theme.style  == .dark ? UIColor.theme.primaryColor3:UIColor.theme.primaryColor9
    }
    
    public private(set) lazy var content: UILabel = {
        self.createContent()
    }()
    
    @objc open func createContent() -> UILabel {
        UILabel(frame: .zero).backgroundColor(.clear).lineBreakMode(LanguageConvertor.chineseLanguage() ? .byCharWrapping:.byWordWrapping).numberOfLines(0)
    }
    
    public private(set) lazy var edit: UILabel = {
        self.createEditSymbol()
    }()
    
    @objc open func createEditSymbol() -> UILabel {
        UILabel(frame: .zero).backgroundColor(.clear).numberOfLines(1).textAlignment(.right).font(UIFont.theme.bodyExtraSmall)
    }
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.addSubview(self.content)
            self.bubbleWithArrow.addSubview(self.edit)
        } else {
            self.bubbleMultiCorners.addSubview(self.content)
            self.bubbleWithArrow.addSubview(self.edit)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        self.content.frame = CGRect(x: 12, y: 5, width: entity.bubbleSize.width-24, height: entity.message.edited ? entity.bubbleSize.height-21:entity.bubbleSize.height)
        if entity.message.edited {
            self.edit.isHidden = false
            self.edit.frame = CGRect(x: 12, y: self.content.frame.maxY, width: entity.bubbleSize.width-24, height: 14)
            self.edit.textColor = entity.message.direction == .send ? self.sendStateColor:self.receiveStateColor
            self.edit.text = "Edited".chat.localize
        } else {
            self.edit.isHidden = true
        }
        self.content.attributedText = entity.content
    }

}
