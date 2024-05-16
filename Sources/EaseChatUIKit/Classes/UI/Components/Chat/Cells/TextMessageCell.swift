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
        UILabel(frame: .zero).backgroundColor(.clear).numberOfLines(0)
    }
    
    public private(set) lazy var edit: UIButton = {
        self.createEditSymbol()
    }()
    
    @objc open func createEditSymbol() -> UIButton {
        UIButton(type: .custom).frame(.zero).backgroundColor(.clear).font(UIFont.theme.labelSmall)
    }
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: .zero)
    }()
    
    public private(set) lazy var translation: UITextView = {
        self.createTranslation()
    }()
    
    @objc open func createTranslation() -> UITextView {
        UITextView(frame: .zero).backgroundColor(.clear)
    }
    
    public private(set) lazy var translateSymbol: UIButton = {
        self.createTranslateSymbol()
    }()
    
    @objc open func createTranslateSymbol() -> UIButton {
        UIButton(type: .custom).frame(.zero).backgroundColor(.clear).font(UIFont.theme.labelSmall)
    }
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.addSubViews([self.content,self.edit])
            if Appearance.chat.enableTranslation {
                self.bubbleWithArrow.addSubViews([self.separatorLine,self.translation,self.translateSymbol])
            }
            self.addGestureTo(view: self.bubbleWithArrow, target: self)
        } else {
            self.bubbleMultiCorners.addSubViews([self.content,self.edit])
            if Appearance.chat.enableTranslation {
                self.bubbleMultiCorners.addSubViews([self.separatorLine,self.translation,self.translateSymbol])
            }
            self.addGestureTo(view: self.bubbleMultiCorners, target: self)
        }
        self.translation.isScrollEnabled = false
        self.translation.showsVerticalScrollIndicator = false
        self.translation.showsHorizontalScrollIndicator = false
        self.edit.contentHorizontalAlignment = .right
        self.translateSymbol.contentHorizontalAlignment = .right
        self.translation.isEditable = false 
        self.translation.contentInset = UIEdgeInsets(top: -8, left: -6, bottom: -8, right: -6)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        let textSize = entity.textSize()
        let translationSize = Appearance.chat.enableTranslation ? entity.translationSize():.zero
        self.content.frame = CGRect(x: 12, y: 6.5, width: entity.bubbleSize.width-24, height: textSize.height)
        let stateColor: UIColor = entity.message.direction == .send ? self.sendStateColor:self.receiveStateColor
        self.edit.setTitleColor(stateColor, for: .normal)
        self.translateSymbol.setTitleColor(stateColor, for: .normal)
        if entity.message.direction == .send {
            self.separatorLine.backgroundColor(Theme.style == .dark ? UIColor.theme.primaryColor9:UIColor.theme.primaryColor8)
        } else {
            self.separatorLine.backgroundColor(Theme.style == .dark ? UIColor.theme.neutralSpecialColor7:UIColor.theme.neutralSpecialColor8)
        }

        if entity.message.edited {
            self.edit.isHidden = false
            self.edit.frame = CGRect(x: 12, y: self.content.frame.maxY, width: entity.bubbleSize.width-24, height: 16)
            let image = UIImage(named: "text_message_edited", in: .chatBundle, with: nil)
            self.edit.image(image?.withTintColor(stateColor), .normal)
            self.edit.setTitle("Edited".chat.localize, for: .normal)
        } else {
            self.edit.isHidden = true
            self.edit.frame = .zero
        }
        
        if entity.showTranslation,Appearance.chat.enableTranslation {
            self.separatorLine.isHidden = false
            self.translation.isHidden = false
            self.translateSymbol.isHidden = false
            self.separatorLine.frame = CGRect(x: 12, y: (entity.message.edited ? self.edit.frame.maxY+8:self.content.frame.maxY+6), width: entity.bubbleSize.width-24, height: 0.5)
            self.translation.frame = CGRect(x: 12, y: self.separatorLine.frame.maxY+8, width: entity.bubbleSize.width-24, height: translationSize.height)
            self.translateSymbol.frame = CGRect(x: 12, y: entity.bubbleSize.height-20, width: entity.bubbleSize.width-24, height: 16)
            self.translateSymbol.setTitle("Translated".chat.localize, for: .normal)
            let image = UIImage(named: "text_message_translated", in: .chatBundle, with: nil)
            self.translateSymbol.image(image?.withTintColor(stateColor), .normal)
        } else {
            self.separatorLine.isHidden = true
            self.translation.isHidden = true
            self.translateSymbol.isHidden = true
        }
        self.content.attributedText = entity.content
        self.translation.attributedText = entity.translation
    }
    
}
