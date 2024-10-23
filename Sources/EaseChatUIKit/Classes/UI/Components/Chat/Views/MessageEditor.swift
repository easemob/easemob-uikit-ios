//
//  MessageEditor.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/12.
//

import UIKit

@objcMembers open class MessageEditor: UIView {
    
    private let statusImage = UIImage(named: "edit_bar_status", in: .chatBundle, with: nil)
    
    private var text = ""
    
    private var modifyClosure:((String) -> Void)?
    
    private var keyboardHeight = CGFloat(0)
    
    private var placeHolderHeight = CGFloat(20)
    
    private var normalFrame = CGRect.zero
    
    public private(set) var contentHeightConstraint: NSLayoutConstraint!
    
    lazy var background: UIView = {
        UIView(frame: self.bounds).backgroundColor(.clear)
    }()
    
    lazy var container: UIView = {
        UIView(frame: CGRect(x: 0, y: self.frame.height-46-32-BottomBarHeight, width: self.frame.width, height: 46+32+BottomBarHeight))
    }()
    
    lazy var statusView: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: ScreenHeight-154, width: self.frame.width, height: self.frame.height-154)).backgroundColor(UIColor.theme.neutralColor95).title(" "+"Editing".chat.localize, .normal).font(UIFont.theme.labelSmall)
    }()
    
    lazy var done: UIButton = {
        UIButton(type: .custom).frame(.zero).font(.systemFont(ofSize: 16, weight: .medium)).tag(12).addTargetFor(self, action: #selector(doneAction), for: .touchUpInside)
    }()
    
    lazy var editor: TextEditorView = {
        TextEditorView(frame: .zero).backgroundColor(UIColor.theme.neutralColor98)
    }()
    
    @objc public init(content: String,changeClosure: @escaping (String) -> Void) {
        self.modifyClosure = changeClosure
        super.init(frame: UIScreen.main.bounds)
        self.addSubViews([self.background,self.container])
        self.container.addSubViews([self.statusView,self.editor,self.done])
        
        self.statusView.contentHorizontalAlignment = .left
        
        self.statusView.translatesAutoresizingMaskIntoConstraints = false
        self.statusView.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
        self.statusView.leftAnchor.constraint(equalTo: self.container.leftAnchor).isActive = true
        self.statusView.rightAnchor.constraint(equalTo: self.container.rightAnchor).isActive = true
        self.statusView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.editor.cornerRadius(.small)
        self.editor.textView.text = content
        self.editor.placeholderFont = .systemFont(ofSize: 14, weight: .regular)
        self.editor.textView.font = UIFont.theme.labelMedium
        
        let contentHeight = content.chat.sizeWithText(font: UIFont.systemFont(ofSize: 14, weight: .medium), size: CGSize(width: ScreenWidth-66, height: Appearance.chat.maxInputHeight)).height+CGFloat(BottomBarHeight)+CGFloat(46)+(NavigationHeight > 64 ? 0:20)
        if contentHeight > Appearance.chat.maxInputHeight+46+CGFloat(BottomBarHeight) {
            let containerY = ScreenHeight-(Appearance.chat.maxInputHeight+46+CGFloat(BottomBarHeight))
            self.container.frame = CGRect(x: 0, y: containerY, width: self.frame.width, height: Appearance.chat.maxInputHeight+46+CGFloat(BottomBarHeight)+(NavigationHeight > 64 ? 0:20))
            self.placeHolderHeight = contentHeight
        }
       
        self.editor.translatesAutoresizingMaskIntoConstraints = false
        self.editor.leftAnchor.constraint(equalTo: self.container.leftAnchor, constant: 8).isActive = true
        self.editor.rightAnchor.constraint(equalTo: self.container.rightAnchor, constant: -54).isActive = true
        self.editor.topAnchor.constraint(equalTo: self.container.topAnchor, constant: 38).isActive = true
        self.editor.heightAnchor.constraint(lessThanOrEqualToConstant: Appearance.chat.maxInputHeight).isActive = true
        self.editor.heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true
        self.normalFrame = self.frame
        self.done.isEnabled = false
        self.editor.textDidChanged = { [weak self] in
            self?.done.isEnabled = $0 != content
            self?.text = $0
        }
        
        self.editor.heightDidChangedShouldScroll = { [weak self] in
            guard let `self` = self else { return true }
            var changeHeight = ($0+46+CGFloat(BottomBarHeight)+(NavigationHeight > 64 ? 0:20))
            if $0 > 49 {
                changeHeight = (Appearance.chat.maxInputHeight+46+CGFloat(BottomBarHeight)+(NavigationHeight > 64 ? 0:20))
                self.placeHolderHeight = changeHeight
                self.container.frame = CGRect(x: 0, y: ScreenHeight - ($0+46+CGFloat(BottomBarHeight)+(NavigationHeight > 64 ? 0:20)-12) - self.keyboardHeight, width: self.frame.width, height: changeHeight)
                return true
            } else {
                self.placeHolderHeight = changeHeight
                self.container.frame = CGRect(x: 0, y: ScreenHeight - ($0+46+CGFloat(BottomBarHeight)+(NavigationHeight > 64 ? 0:20)-12) - self.keyboardHeight, width: self.frame.width, height: changeHeight)
                return false
            }
        }
        
        self.done.translatesAutoresizingMaskIntoConstraints = false
        self.done.bottomAnchor.constraint(equalTo: self.editor.bottomAnchor).isActive = true
        self.done.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        self.done.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.done.heightAnchor.constraint(equalToConstant: 30).isActive = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func doneAction() {
        self.modifyClosure?(self.text)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.modifyClosure?("")
    }
}


extension MessageEditor: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor = .clear
        self.container.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.statusView.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.editor.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.statusView.textColor(style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5, .normal)
        if style == .dark {
            self.statusImage?.withTintColor(UIColor.theme.neutralSpecialColor6)
        }
        self.done.image(UIImage(named: "uncheck", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7, renderingMode: .alwaysOriginal), .disabled).image(UIImage(named: "check", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), .normal)
        self.statusView.setImage(self.statusImage, for: .normal)
    }
}
