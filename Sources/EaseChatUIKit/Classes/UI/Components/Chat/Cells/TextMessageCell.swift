//
//  TextMessageCell.swift
//  ChatUIKit
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
    
    public private(set) lazy var content: LinkRecognizeTextView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> LinkRecognizeTextView {
        LinkRecognizeTextView(frame: .zero).backgroundColor(.clear)
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
    
    public private(set) lazy var translationContainer: TranslateTextView = {
        self.createTranslationContainer()
    }()
    
    @objc open func createTranslationContainer() -> TranslateTextView {
        TranslateTextView(frame: .zero).backgroundColor(.clear).isEditable(false)
    }
    
    public private(set) lazy var translation: UILabel = {
        self.createTranslation()
    }()
    
    @objc open func createTranslation() -> UILabel {
        UILabel(frame: .zero).backgroundColor(.clear).numberOfLines(0)
    }
    
    public private(set) lazy var translateSymbol: UIButton = {
        self.createTranslateSymbol()
    }()
    
    @objc open func createTranslateSymbol() -> UIButton {
        UIButton(type: .custom).frame(.zero).backgroundColor(.clear).font(UIFont.theme.labelSmall)
    }
    
    public private(set) lazy var previewContent: URLPreviewResultView = {
        self.createPreviewContent()
    }()
    
    @objc open func createPreviewContent() -> URLPreviewResultView {
        URLPreviewResultView(frame: CGRect(x: 0, y: self.frame.height-38, width: limitBubbleWidth, height: 38))
    }
    
    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.addSubViews([self.content,self.edit])
            if Appearance.chat.enableTranslation {
                self.bubbleWithArrow.bubble.addSubViews([self.separatorLine,self.translationContainer,self.translation,self.translateSymbol])
                if Appearance.chat.enableURLPreview {
                    self.bubbleWithArrow.bubble.addSubViews([self.previewContent])
                }
            }
            self.addGestureTo(view: self.bubbleWithArrow, target: self)
        } else {
            self.bubbleMultiCorners.addSubViews([self.content,self.edit])
            if Appearance.chat.enableTranslation {
                self.bubbleMultiCorners.addSubViews([self.separatorLine,self.translationContainer,self.translation,self.translateSymbol])
            }
            if Appearance.chat.enableURLPreview {
                self.bubbleMultiCorners.addSubViews([self.previewContent])
            }
            self.addGestureTo(view: self.bubbleMultiCorners, target: self)
        }
        self.translationContainer.isScrollEnabled = false
        self.translationContainer.showsVerticalScrollIndicator = false
        self.translationContainer.showsHorizontalScrollIndicator = false
        self.translationContainer.isSelectable = true
        self.translationContainer.isUserInteractionEnabled = true
        self.translationContainer.textContainerInset = .zero
        
        
        self.content.showsVerticalScrollIndicator = false
        self.content.showsHorizontalScrollIndicator = false
        self.content.isScrollEnabled = false
        self.content.textContainerInset = .zero
        self.content.textContainer.lineFragmentPadding = 0
        self.content.isEditable = false
        self.content.isSelectable = Appearance.chat.messageLongPressMenuStyle == .withArrow
        self.content.dataDetectorTypes = [.link]
        self.edit.contentHorizontalAlignment = .right
        self.translateSymbol.contentHorizontalAlignment = .right
        self.previewContent.isHidden = true
        
        
        self.content.clickAction = { [weak self] in
            guard let `self` = self else { return }
            self.clickAction?(.bubble,self.entity)
        }
        
        self.content.longPressAction = { [weak self] in
            guard let `self` = self else { return }
            self.longPressAction?(.bubble,self.entity,self)
        }
        
        self.content.showTextMenu = { [weak self] _,_,_,_ in
            guard let `self` = self else { return }
            self.longPressAction?(.bubble,self.entity,self)
        }

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        self.onThemeChanged()
        let textSize = entity.textSize()
        let translationSize = Appearance.chat.enableTranslation ? entity.translationSize():.zero
        if Appearance.chat.bubbleStyle == .withArrow {
            self.content.frame = CGRect(x: self.towards == .right ? 10:14, y: 7, width: entity.bubbleSize.width-24, height: textSize.height)
        } else {
            self.content.frame = CGRect(x: 12, y: 7, width: entity.bubbleSize.width-24, height: textSize.height)
        }
        self.content.attributedText = entity.content
        self.content.parseTextAndExtractActiveElements(entity.content!)
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
            self.translation.attributedText = entity.translation
            self.separatorLine.isHidden = false
            self.translation.isHidden = false
            self.translateSymbol.isHidden = false
            self.separatorLine.frame = CGRect(x: 12, y: (entity.message.edited ? self.edit.frame.maxY+8:self.content.frame.maxY+6), width: entity.bubbleSize.width-24, height: 0.5)
            self.translationContainer.frame = CGRect(x: 12, y: self.separatorLine.frame.maxY+8, width: entity.bubbleSize.width-24, height: translationSize.height)
            self.translation.frame = CGRect(x: 12, y: self.separatorLine.frame.maxY+8, width: entity.bubbleSize.width-24, height: translationSize.height)
            var symbolY = entity.bubbleSize.height - 20
            if Appearance.chat.enableURLPreview {
                symbolY = self.translation.frame.maxY
            }
            self.translateSymbol.frame = CGRect(x: 12, y: symbolY, width: entity.bubbleSize.width-24, height: 16)
            self.translateSymbol.setTitle("Translated".chat.localize, for: .normal)
            let image = UIImage(named: "text_message_translated", in: .chatBundle, with: nil)
            self.translateSymbol.image(image?.withTintColor(stateColor), .normal)
        } else {
            self.separatorLine.frame = CGRect(x: 12, y: (entity.message.edited ? self.edit.frame.maxY+6:self.content.frame.maxY+6), width: entity.bubbleSize.width-24, height: 0.5)
            self.separatorLine.isHidden = true
            self.translation.isHidden = true
            self.translateSymbol.isHidden = true
        }
        if Appearance.chat.enableURLPreview {
            self.previewContent.state = entity.previewResult
            let previewHeight = entity.urlPreviewHeight()
            self.previewContent.frame = CGRect(x: 0, y: entity.bubbleSize.height-previewHeight, width: entity.bubbleSize.width, height: previewHeight)
            var parserColor = UIColor.black
            if self.towards == .left {
                parserColor = Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor6
            } else {
                parserColor = Theme.style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor9
            }
            self.previewContent.loadingLabel.textColor = parserColor
            self.previewContent.descriptionLabel.textColor = self.towards == .right ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor
            switch entity.previewResult {
            case .success:
                self.previewContent.show(with: entity.urlPreview)
            default: break
            }
            self.previewContent.isHidden = previewHeight <= 0
        }
        
    }

    open override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
        self.onThemeChanged()
    }
    
    open func onThemeChanged() {
        let receiveLinkColor = Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        let sendLinkColor = Appearance.chat.sendTextColor
        let receiveSelectedColor = Theme.style == .dark ? UIColor.theme.primaryColor1:UIColor.theme.primaryColor8
        let sendSelectedColor = Theme.style == .dark ? UIColor.theme.primaryColor8:UIColor.theme.primaryColor3
        let sendTintColor = UIColor.theme.primaryColor98
        let receiveTintColor = Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        let color = self.towards == .right ? sendLinkColor:receiveLinkColor
        self.content.linkTextAttributes = [.underlineStyle:NSUnderlineStyle.single.rawValue,.underlineColor:color,.foregroundColor:color]
        
        self.content.tintColor = self.towards == .right ? sendTintColor:receiveTintColor
        self.content.selectedTextColor = self.towards == .right ? sendSelectedColor:receiveSelectedColor
    }
}


@objc open class TranslateTextView: UITextView {
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    open override func copy(_ sender: Any?) {
        if let selectedTextRange = self.selectedTextRange {
            let selectedText = self.text(in: selectedTextRange)
            UIPasteboard.general.string = selectedText
        }
    }

}
