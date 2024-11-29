//
//  MessageInputBar.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/4.
//

import UIKit

/// The types of actions that can be triggered by the input bar.
@objc public enum MessageInputBarActionType: UInt {
    case send
    case audio
    case mention
    case attachment
    case textKeyboard
    case emojiKeyboard
    case cancelMention
    case startTyping
}

@objcMembers open class MessageInputBar: UIView {
    
    public var axisYChanged: ((CGFloat) -> Void)?
    
    open override var frame: CGRect {
        didSet {
            if self.frame.origin.y != oldValue.origin.y {
                self.axisYChanged?(self.frame.origin.y)
            }
        }
    }
    
    public var textViewFirstResponder: ((Bool) -> Void)?
    
    
    public private(set) var audioImage = UIImage(named: "audio", in: .chatBundle, with: nil)
    
    public private(set) var attachmentImage = UIImage(named: "attachment", in: .chatBundle, with: nil)
    
    public private(set) var selectedAttachmentImage = UIImage(named: "attachmentSelected", in: .chatBundle, with: nil)
    
    private var style: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineHeightMultiple = 1.15
        return paragraph
    }
    
    private var typingAttributesText: [NSAttributedString.Key : Any] {
        set {}
        get {
            [.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1,.font:UIFont.theme.bodyLarge,.paragraphStyle: self.style]
        }
    }
        
    /// The height of the keyboard.
    public private(set) var keyboardHeight = CGFloat(0)

    /// The raw height of the input bar.
    public private(set)var rawHeight: CGFloat = 0

    /// The raw height of the text input area.
    public private(set) var rawTextHeight: CGFloat = 0

    /// The raw frame of the input bar.
    public private(set) var rawFrame: CGRect = .zero
    
    public private(set) var recordedFrame: CGRect = .zero
    
    /// Action events callback,contain ``MessageInputBarActionType`` and send text when you click send button.
    public var actionClosure: ((MessageInputBarActionType,NSAttributedString?) -> Void)?

    /// A closure to be called when the user toggles the emoji keyboard.
    public var changeEmojiClosure: ((Bool) -> Void)?
    
    private var hiddenDuration = Double(0.2)
    
    public private(set) lazy var rightView: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-80, y: self.inputField.frame.maxY-32, width: 30, height: 30)).addTargetFor(self, action: #selector(changeToEmoji), for: .touchUpInside).backgroundColor(.clear)
    }()
    
    public private(set) lazy var audio: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 12, y: self.inputField.frame.maxY-32, width: 30, height: 30)).backgroundColor(.clear).image(self.audioImage, .normal).addTargetFor(self, action: #selector(audioAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var inputField: PlaceHolderTextView = {
        PlaceHolderTextView(frame: CGRect(x: 50, y: 8, width: self.frame.width-142, height: 36)).delegate(self).font(UIFont.theme.bodyLarge).backgroundColor(.clear).backgroundColor(UIColor.theme.neutralColor95)
    }()
    
    public private(set) lazy var attachment: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)).backgroundColor(.clear).addTargetFor(self, action: #selector(attachmentAction), for: .touchUpInside)
    }()
        
    public private(set) lazy var line: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)).backgroundColor(UIColor.theme.neutralColor9)
    }()
    
    public private(set) var emoji: MessageInputEmojiView?
    
    public private(set) lazy var extensionMenus: MessageInputExtensionView = {
        MessageInputExtensionView(frame: CGRect(x: 0, y: self.inputField.frame.maxY+15, width: self.frame.width, height: (Appearance.chat.inputExtendActions.count > 4 ? 230:132))).backgroundColor(.clear)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// MessageInputBar init method
    /// - Parameters:
    ///   - frame: CGRect
    ///   - text: `String` value
    ///   - placeHolder: `String` value
    @objc required public init(frame: CGRect,text: String? = nil,placeHolder: String? = nil) {
        self.rawFrame = frame
        self.recordedFrame = frame
        self.rawHeight = frame.height
        self.rawTextHeight = self.rawHeight-16
        super.init(frame: frame)
        self.addSubViews([self.audio,self.inputField, self.rightView,self.attachment,self.line])
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: Bundle.chatBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: Bundle.chatBundle, with: nil)?.withTintColor(UIColor.theme.neutralColor3), for: .selected)
        self.attachment.setImage(self.attachmentImage, for: .normal)
        self.attachment.setImage(self.selectedAttachmentImage, for: .selected)
        self.inputField.returnKeyType = .send
        self.inputField.typingAttributes = self.typingAttributesText
        self.inputField.contentInsetAdjustmentBehavior = .never
        self.inputField.cornerRadius(Appearance.chat.inputBarCorner)
        self.inputField.contentInset = UIEdgeInsets(top: 4, left: Appearance.chat.inputBarCorner == .large ? 10:6, bottom: 4, right: 6)
        self.inputField.tintColor = UIColor.theme.primaryLightColor
        self.inputField.placeHolderColor = UIColor.theme.neutralColor6
        self.inputField.textColor = UIColor.theme.neutralColor1
        self.inputField.font = UIFont.theme.bodyLarge
        self.inputField.bounces = false
        self.inputField.isScrollEnabled = false
        self.inputField.layoutManager.allowsNonContiguousLayout = false
        self.inputField.adjustsFontForContentSizeCategory = true
        if text != nil {
            self.inputField.text = text
        }
        self.inputField.placeHolder = placeHolder ?? "Aa"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        inputField.removeFromSuperview()
        emoji?.removeFromSuperview()
        emoji = nil
        consoleLogInfo("\(self.swiftClassName ?? "") deinit", type: .debug)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

extension MessageInputBar: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.extensionMenus.isHidden = true
        self.emoji?.isHidden = true
        if text == "\n" {
            self.sendMessage()
            return false
        } else {
            if textView.text.isEmpty {
                if text.contains("@") {
                    self.actionClosure?(.mention,textView.attributedText)
                } else {
                    self.updateHeight()
                    self.recoverInputState()
                }
            } else {
                if text.contains("@") {
                    self.actionClosure?(.mention,textView.attributedText)
                } else if text.isEmpty {
                    var mention: Bool = false
                    let attributedString = textView.attributedText
                    
                    attributedString?.enumerateAttributes(in: NSRange(location: 0, length: attributedString?.length ?? 0), options: []) { (attributes, blockRange, stop) in
                        if let mentionUser = attributes[NSAttributedString.Key(rawValue: "mentionInfo")] as? ChatUserProfileProtocol {
                            if range.location + range.length == blockRange.location + blockRange.length { mention = true
                                let result = NSMutableAttributedString(attributedString: textView.attributedText)
                                result.deleteCharacters(in: blockRange)
                                textView.attributedText = result
                                let nickname = mentionUser.nickname.isEmpty ? mentionUser.id:mentionUser.nickname
                                self.actionClosure?(.cancelMention,NSAttributedString(string: nickname))
                                stop.pointee = true
                            }
                        }
                    }
                    
                    self.updateHeight()
                    return !mention
                }
                if self.typingAttributesText.isEmpty,!textView.typingAttributes.isEmpty {
                    self.typingAttributesText = textView.typingAttributes
                }
                textView.typingAttributes = self.typingAttributesText
                self.updateHeight()
            }
            return true
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedRange.length > 0 {
            self.rightView.isSelected = false
        }
        textView.attributedText.enumerateAttributes(in: NSMakeRange(0, textView.text.count), options: []) { (attributes, range, stop) in
            if attributes[NSAttributedString.Key(rawValue: "mentionInfo")] is ChatUserProfileProtocol {
                let min = textView.selectedRange.location
                let max = textView.selectedRange.location + textView.selectedRange.length
                if min > range.location && min <= range.location + range.length {
                    let location = range.location + range.length
                    var length = 0
                    
                    if textView.selectedRange.location + textView.selectedRange.length > location {
                        length = textView.selectedRange.location + textView.selectedRange.length - location
                    }
                    
                    textView.selectedRange = NSMakeRange(location, length)
                    stop.pointee = true
                } else if max > range.location && max <= range.location + range.length {
                    let location = min
                    let length = textView.selectedRange.length - (max - range.location - range.length)
                    textView.selectedRange = NSMakeRange(location, length)
                    stop.pointee = true
                }
            }
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        self.rightView.isSelected = false
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            self.updateHeight()
        }
        self.actionClosure?(.startTyping,nil)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if let emojiView = self.emoji {
            self.textViewFirstResponder?(!emojiView.isHidden)
        }
    }
    
    /// Update subviews height on text input content changed.
    private func updateHeight() {
        
        var space: CGFloat = 0
        if self.superview?.frame.height ?? 0 < ScreenHeight - NavigationHeight {
            space = 10
        }
        let textHeight = self.inputField.sizeThatFits(CGSize(width: self.inputField.frame.width, height: Appearance.chat.maxInputHeight)).height
        if textHeight > 38.5 {
            self.inputField.isScrollEnabled = true
            let increment = textHeight - self.rawTextHeight
            self.rawTextHeight += increment
            self.rawHeight = self.rawTextHeight + 16
            
            if textHeight >= Appearance.chat.maxInputHeight {
                self.frame = CGRect(x: 0, y: self.rawFrame.maxY - (Appearance.chat.maxInputHeight) - self.keyboardHeight - (NavigationHeight <= 64 ? 36:0) - space, width: self.frame.width, height: Appearance.chat.maxInputHeight+16)
                self.inputField.frame = CGRect(x: 50, y: 8, width: self.frame.width-142, height: Appearance.chat.maxInputHeight)
                self.inputField.scrollRangeToVisible(NSMakeRange(self.inputField.attributedText.length, 1))
            } else {
                self.frame = CGRect(x: 0, y: self.rawFrame.maxY - textHeight - self.keyboardHeight - (NavigationHeight <= 64 ? 36:0) - space, width: self.frame.width, height: textHeight+16)
                self.inputField.frame = CGRect(x: 50, y: 8, width: self.frame.width-142, height: textHeight+4)
            }
            
            self.audio.frame = CGRect(x: 12, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.rightView.frame = CGRect(x: self.frame.width-80, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.attachment.frame = CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.emoji?.frame = CGRect(x: 0, y: self.inputField.frame.maxY+8, width: self.frame.width, height: self.keyboardHeight)
            self.emoji?.backgroundColor(self.backgroundColor ?? UIColor.theme.neutralColor98)
        } else {
            self.inputField.isScrollEnabled = false
            self.inputField.frame = CGRect(x: 50, y: 8, width: self.frame.width-142, height: 36)
            self.audio.frame = CGRect(x: 12, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.rightView.frame = CGRect(x: self.frame.width-80, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.attachment.frame = CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)
            self.frame = CGRect(x: 0, y: self.rawFrame.maxY - 16 - self.keyboardHeight - (NavigationHeight <= 64 ? 36:0) - space, width: self.frame.width, height: self.rawFrame.height)
            if !(self.emoji?.isHidden ?? false) {
                if self.keyboardHeight <= 152 {
                    self.keyboardHeight = 256+BottomBarHeight
                }
                self.emoji?.frame = CGRect(x: 0, y: self.inputField.frame.maxY+8, width: self.frame.width, height: self.keyboardHeight)
            }
        }
        self.recordedFrame = self.frame
    }
    
    /**
     This function is called when the user taps on the send button in the chat input bar. It hides the input bar, deselects the right view, and sends the message if the input field is not empty. It also resets the input field and the frame of the input bar to their original values.
     */
    @objc func sendMessage() {
        if self.rightView.isSelected {
            self.showEmojiKeyboard()
        }
        if self.attachment.isSelected {
            self.processAttachmentView(selected: self.attachment.isSelected)
        }
        self.rightView.isSelected = false
        self.attachment.isSelected = false
        self.extensionMenus.isHidden = true
        self.extensionMenus.isUserInteractionEnabled = false
        if !self.inputField.attributedText.toString().isEmpty {
            self.actionClosure?(.send,self.inputField.attributedText)
        }
        self.inputField.text = nil
        self.inputField.attributedText = nil
        self.updateHeight()
    }
    
    
    @objc func attachmentAction() {
        switch Appearance.chat.messageAttachmentMenuStyle {
        case .followInput:
            self.attachment.isSelected = !self.attachment.isSelected
            self.processAttachmentView(selected: self.attachment.isSelected)
        default:
            self.actionClosure?(.attachment,nil)
            break
        }

    }
    
    @objc func processAttachmentView(selected: Bool) {
        if selected {
            if !self.inputField.isFirstResponder {
                self.inputField.becomeFirstResponder()
            }
            self.extensionMenus.isHidden = false
            self.emoji?.isHidden = true
            self.inputField.resignFirstResponder()
        } else {
            self.extensionMenus.isHidden = true
            if !self.rightView.isSelected {
                self.inputField.becomeFirstResponder()
            }
        }
        self.keyboardHeight = (Appearance.chat.inputExtendActions.count > 4 ? 230:132)
        self.frame = self.rawFrame
        self.attachment.isSelected = selected
        if selected {
            self.showExtensionMenus()
        }
        self.textViewFirstResponder?(true)
    }
    
    @objc func audioAction() {
        self.rightView.isSelected = false
        self.attachment.isSelected = false
        self.extensionMenus.isHidden = true
        self.extensionMenus.isUserInteractionEnabled = false
        self.emoji?.isHidden = true
        self.inputField.text = nil
        self.inputField.attributedText = nil
        self.updateHeight()
        self.inputField.isScrollEnabled = false
        self.actionClosure?(.audio,nil)
    }
    
    private func recoverInputState() {
        self.rawHeight = self.rawFrame.height
        self.rawTextHeight = self.rawHeight-16
        self.inputField.frame = CGRect(x: 50, y: 8, width: self.frame.width-142, height: 36)
        self.audio.frame = CGRect(x: 12, y: self.inputField.frame.maxY-32, width: 30, height: 30)
        self.rightView.frame = CGRect(x: self.frame.width-80, y: self.inputField.frame.maxY-32, width: 30, height: 30)
        self.attachment.frame = CGRect(x: self.frame.width - 42, y: self.inputField.frame.maxY-32, width: 30, height: 30)
        self.attachment.isSelected = false
        self.extensionMenus.isHidden = true
        self.extensionMenus.isUserInteractionEnabled = false
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews {
            if view.isKind(of: type(of: view)),view.frame.contains(point) {
                if view is MessageInputEmojiView {
                    if view.isHidden,!self.extensionMenus.isHidden {
                        let childPoint = self.convert(point, to: self.extensionMenus)
                        let childView = self.extensionMenus.hitTest(childPoint, with: event)
                        return childView
                    }
                }
                let childPoint = self.convert(point, to: view)
                let childView = view.hitTest(childPoint, with: event)
                return childView
            }
        }
        self.hiddenInputBar()
        self.attachment.isSelected = false
        self.emoji?.isHidden  = true
        self.extensionMenus.isHidden = true
        self.extensionMenus.isUserInteractionEnabled = false
        self.attachment.setImage(self.attachmentImage, for: .normal)
        self.rightView.isSelected = false
        return super.hitTest(point, with: event)
    }

    @objc func changeToEmoji() {
        self.attachment.isSelected = false
        self.extensionMenus.isHidden = true
        self.rightView.isSelected = !self.rightView.isSelected
        self.actionClosure?(self.rightView.isSelected ? .emojiKeyboard:.textKeyboard,nil)
        if self.rightView.isSelected {
            if !self.inputField.isFirstResponder {
                if self.keyboardHeight <= 152 {
                    self.keyboardHeight = 256+BottomBarHeight
                }
            }
            self.rightView.isSelected = true
            self.inputField.resignFirstResponder()
            self.showEmojiKeyboard()
        } else {
            if !self.rightView.isSelected {
                self.inputField.becomeFirstResponder()
            }
        }
        self.updateHeight()
        self.textViewFirstResponder?(true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if !self.inputField.isFirstResponder {
            return
        }
        self.emoji?.isHidden = true
        self.extensionMenus.isHidden = true
        guard let frame = notification.chat.keyboardEndFrame else { return }
        guard let duration = notification.chat.keyboardAnimationDuration else { return }
        self.keyboardHeight = frame.height
        self.attachment.isSelected = false
        guard let superview = self.superview else { return }
        var space: CGFloat = 0
        if superview.frame.height < ScreenHeight - NavigationHeight {
            space = 10
        }
        UIView.animate(withDuration: duration) {
            self.frame = CGRect(x: 0, y: self.rawFrame.maxY - 16 - frame.height - (NavigationHeight <= 64 ? 36:0) - space, width: self.frame.width, height: self.rawFrame.height)
        }
        self.textViewFirstResponder?(true)
        self.updateHeight()
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if self.rightView.isSelected {
//            guard let frame = notification.chat.keyboardEndFrame else { return }
            guard let duration = notification.chat.keyboardAnimationDuration else { return }
            self.hiddenDuration = duration
            self.showEmojiKeyboard()
            self.textViewFirstResponder?(true)
        } else {
            self.hiddenInputBar()
        }
    }
    
    @objc open func showEmojiKeyboard() {
        self.emoji?.isUserInteractionEnabled = true
        if self.rightView.isSelected {
            if self.keyboardHeight <= 152 {
                self.keyboardHeight = 256+BottomBarHeight
            }
            let emojiHeight = self.keyboardHeight+self.inputField.frame.height+16+BottomBarHeight
            self.frame = CGRect(x: 0, y: -emojiHeight, width: self.frame.width, height: emojiHeight)
            if self.emoji == nil{
                let emoji = MessageInputEmojiView(frame: CGRect(x: 0, y: self.rawFrame.height, width: self.frame.width, height: self.keyboardHeight)).tag(124).backgroundColor(.clear)
                self.emoji = emoji
                self.addSubview(emoji)
            } else {
                self.emoji?.frame = CGRect(x: 0, y: self.inputField.frame.maxY+8, width: self.frame.width, height: self.keyboardHeight)
            }
            self.emoji?.sendClosure = { [weak self] in
                self?.sendMessage()
            }
            self.emoji?.emojiClosure = { [weak self] in
                guard let self = self else { return }
                self.emoji?.deleteEmoji.isEnabled = true
                self.emoji?.deleteEmoji.isUserInteractionEnabled = true
                self.inputField.attributedText = self.convertText(text: self.inputField.attributedText, key: $0)
                self.updateHeight()
            }
            self.emoji?.deleteClosure = { [weak self] in
                if self?.inputField.text?.count ?? 0 > 0 {
                    self?.inputField.deleteBackward()
                    self?.emoji?.deleteEmoji.isEnabled = true
                    self?.emoji?.deleteEmoji.isUserInteractionEnabled = true
                } else {
                    self?.emoji?.deleteEmoji.isEnabled = false
                    self?.emoji?.deleteEmoji.isUserInteractionEnabled = false
                }
                self?.updateHeight()
            }
        } else {
            self.frame = CGRect(x: 0, y: self.frame.origin.y, width: self.frame.width, height: self.rawFrame.height)
        }
        
        UIView.animate(withDuration: self.hiddenDuration) {
            self.emoji?.isHidden = !self.rightView.isSelected
        }
    }
    
    @objc open func showExtensionMenus() {
        self.extensionMenus.isUserInteractionEnabled = true
        if !self.subviews.contains(self.extensionMenus) {
            self.addSubview(self.extensionMenus)
        }
        self.extensionMenus.isHidden = false
        UIView.animate(withDuration: self.hiddenDuration) {
            if self.attachment.isSelected {
                self.extensionMenus.frame = CGRect(x: 0, y: self.inputField.frame.maxY+15, width: self.frame.width, height: (Appearance.chat.inputExtendActions.count > 4 ? 230:132))
                self.frame = CGRect(x: 0, y: self.frame.minY-self.extensionMenus.frame.height-BottomBarHeight, width: self.frame.width, height: self.extensionMenus.frame.height + self.inputField.frame.height + BottomBarHeight)
            } else {
                self.extensionMenus.isHidden = true
            }
        }
    }
    
    @objc public func hiddenInputBar() {
        self.inputField.resignFirstResponder()
        UIView.animate(withDuration: self.hiddenDuration) {
            if self.recordedFrame.height > self.rawFrame.height {
                self.frame = self.recordedFrame
            } else {
                self.frame = self.rawFrame
            }
        }
        self.rightView.isSelected = false
        self.emoji?.isHidden = true
        if self.extensionMenus.isHidden {
            self.textViewFirstResponder?(false)
        }
    }
    
    /// Raise input bar
    @objc public func show() {
        self.inputField.becomeFirstResponder()
    }
    
    /// Hidden input bar
    @objc public func hiddenInput() {
        self.hiddenInputBar()
    }

    /**
     Converts the given attributed string to include an emoji image attachment with the specified key.

     - Parameters:
        - text: The attributed string to convert.
        - key: The key of the emoji image to use.

     - Returns: The converted attributed string with the emoji image attachment.
     */
    func convertText(text: NSAttributedString?, key: String) -> NSAttributedString {
        let attribute = NSMutableAttributedString(attributedString: text!)
        attribute.addAttributes([.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1,.font:UIFont.theme.bodyLarge], range: NSMakeRange(0, attribute.length))
        let attachment = NSTextAttachment()
        attachment.image = ChatEmojiConvertor.shared.emojiMap.isEmpty ? UIImage(named: key, in: .chatBundle, with: nil):ChatEmojiConvertor.shared.emojiMap[key]
        attachment.bounds = CGRect(x: 0, y: -3.5, width: 18, height: 18)
        let imageText = NSMutableAttributedString(attachment: attachment)
        if #available(iOS 11.0, *) {
            if self.inputField.selectedRange.location != NSNotFound,self.inputField.selectedRange.length != NSNotFound {
                imageText.addAttributes([.accessibilityTextCustom: key,.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1,.font:UIFont.theme.bodyLarge], range: NSMakeRange(0, imageText.length))
                attribute.replaceCharacters(in: self.inputField.selectedRange, with: imageText)
                
            } else {
                imageText.addAttributes([.accessibilityTextCustom: key,.foregroundColor:Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1,.font:UIFont.theme.bodyLarge], range: NSMakeRange(0, imageText.length))
                attribute.append(imageText)
            }
        } else {
            assert(false,"failed add accessibility custom text!")
        }
        return attribute
    }
    
    public func dismissKeyboard() {
        self.inputField.resignFirstResponder()
    }
}

extension MessageInputBar: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.rightView.setImage(UIImage(named: "emojiKeyboard", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .normal)
        self.rightView.setImage(UIImage(named: "textKeyboard", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor95:UIColor.theme.neutralColor3, renderingMode: .automatic), for: .selected)
        if style == .light {
            self.selectedAttachmentImage = self.selectedAttachmentImage?.withTintColor(UIColor.theme.neutralColor3)
            self.attachmentImage = self.attachmentImage?.withTintColor(UIColor.theme.neutralColor3)
            self.audioImage = self.audioImage?.withTintColor(UIColor.theme.neutralColor3)
        }
        self.attachment.setImage(self.attachmentImage, for: .normal)
        self.attachment.setImage(self.selectedAttachmentImage, for: .selected)
        self.audio.setImage(self.audioImage, for: .normal)
        self.viewWithTag(124)?.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.inputField.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95)
        self.inputField.tintColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.inputField.placeHolderColor = style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor6
        self.inputField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.emoji?.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.line.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
    
}

public extension NSAttributedString {
    /**
     Converts the attributed string to a plain string by replacing any custom accessibility text with its corresponding value.

     - Returns: A plain string representation of the attributed string.
     */
    func toString() -> String {
        let result = NSMutableAttributedString(attributedString: self)
        var replaceList: [(NSRange, String)] = []
        result.enumerateAttribute(.accessibilityTextCustom, in: NSRange(location: 0, length: result.length), using: { value, range, _ in
            if let value = value as? String {
                for i in range.location..<range.location + range.length {
                    replaceList.append((NSRange(location: i, length: 1), value))
                }
            }
        })
        for i in replaceList.reversed() {
            result.replaceCharacters(in: i.0, with: i.1)
        }
        return result.string
    }
}

