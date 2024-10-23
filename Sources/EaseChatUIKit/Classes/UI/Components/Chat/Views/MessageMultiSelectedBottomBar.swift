//
//  MessageMultiSelectedBottomBar.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objc public enum MessageMultiSelectedBottomBarOperation: UInt {
    case delete
    case forward
}

@objcMembers open class MessageMultiSelectedBottomBar: UIView {
    
    /// Action button click callback
    public var operationClosure: ((MessageMultiSelectedBottomBarOperation) -> Void)?
    
    private let trashIcon = UIImage(named: "trash", in: .chatBundle, with: nil)
    
    private let forwardIcon = UIImage(named: "message_select_bottom_forward", in: .chatBundle, with: nil)
    
    public private(set) lazy var trash: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 12, y: 4, width: 36, height: 36)).backgroundColor(.clear).cornerRadius(.large).addTargetFor(self, action: #selector(removeAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var forward: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-48, y: 2, width: 36, height: 36)).backgroundColor(.clear).cornerRadius(.large).addTargetFor(self, action: #selector(forwardAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)).backgroundColor(UIColor.theme.neutralColor9)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.trash,self.forward,self.separatorLine])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc func removeAction() {
        self.operationClosure?(.delete)
    }
    
    @objc func forwardAction() {
        self.operationClosure?(.forward)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageMultiSelectedBottomBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
        let disable_trash = self.trashIcon?.withTintColor(style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor6)
        self.trash.setImage(disable_trash, for: .disabled)
        let enable_trash = self.trashIcon?.withTintColor(style == .dark ? UIColor.theme.errorColor6:UIColor.theme.errorColor5)
        self.trash.setImage(enable_trash, for: .normal)
        
        let disable_forward = self.forwardIcon?.withTintColor(style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor6)
        self.forward.setImage(disable_forward, for: .disabled)
        let enable_forward = self.forwardIcon?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
        self.forward.setImage(enable_forward, for: .normal)
    }
}
