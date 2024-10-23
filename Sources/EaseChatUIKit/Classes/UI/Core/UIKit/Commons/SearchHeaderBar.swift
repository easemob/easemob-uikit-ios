//
//  SearchBar.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import UIKit

@objc public enum SearchHeaderBarDisplayStyle: UInt {
    case withBack
    case other
}

@objc public enum SearchHeaderBarActionType: UInt {
    case back
    case cancel
}

@objc public enum SearchFieldState: UInt {
    case began
    case end
}

@objc open class SearchHeaderBar: UIView {
    
    public var actionClosure: ((SearchHeaderBarActionType) -> ())?
    
    public var textChanged: ((String) -> Void)?
    
    public var textFieldState: ((SearchFieldState) -> Void)?
    
    lazy var back: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 8, y: (self.frame.height-24)/2.0, width: 24, height: 24)).image(UIImage(named: "back", in: .chatBundle, with: nil), .normal).tag(0).addTargetFor(self, action: #selector(buttonAction(sender:)), for: .touchUpInside).backgroundColor(.clear)
    }()
    
    lazy var leftView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.height-8, height: self.frame.height-8)).backgroundColor(.clear)
    }()
    
    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 8, y: self.leftView.frame.height/2.0-11, width: 22, height: 22)).contentMode(.scaleAspectFill).backgroundColor(.clear)
    }()
    
    lazy var searchField: UITextField = {
        UITextField(frame: CGRect(x: self.back.frame.maxX+12, y: 4, width: self.frame.width-68-16-self.back.frame.maxX-12-8, height: self.frame.height-8)).font(UIFont.theme.bodyLarge).clearButtonMode(.whileEditing).leftView(self.leftView, .always).cornerRadius(.small).delegate(self)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-68-16, y: (self.frame.height-16)/2.0, width: 68, height: 16)).font(UIFont.theme.labelMedium).textColor(UIColor.theme.primaryLightColor, .normal).tag(1).addTargetFor(self, action: #selector(buttonAction(sender:)), for: .touchUpInside).backgroundColor(.clear).title("group_details_extend_button_disband_alert_button_cancel".chat.localize, .normal)
    }()
    
    @objc public required convenience init(frame: CGRect, displayStyle: SearchHeaderBarDisplayStyle) {
        self.init(frame: frame)
        if displayStyle == .withBack {
            self.addSubViews([self.back,self.searchField,self.cancel])
        } else {
            self.searchField.frame = CGRect(x: 12, y: (self.frame.height-36)/2.0, width: self.frame.width-68-16-8, height: 36)
            self.addSubViews([self.searchField,self.cancel])
        }
        self.leftView.addSubview(self.icon)
        self.searchField.returnKeyType = .search
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction(sender: UIButton) {
        self.searchField.resignFirstResponder()
        self.actionClosure?(SearchHeaderBarActionType(rawValue: UInt(sender.tag)) ?? .back)
    }
}

extension SearchHeaderBar: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if var text = textField.text {
            let changed = (text as NSString).replacingCharacters(in: range, with: string)
            self.textChanged?(changed)
        } else {
            self.textChanged?("")
        }
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textFieldState?(.began)
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.textFieldState?(.end)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textChanged?(textField.text ?? "")
        return true
    }
    
}

extension SearchHeaderBar: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        var image = UIImage(named: "back", in: .chatBundle, with: nil)
        var searchIcon = UIImage(named: "search",in: .chatBundle,with: nil)?.withTintColor(UIColor.theme.neutralColor4, renderingMode: .automatic)
        if style == .light {
            image = image?.withTintColor(UIColor.theme.neutralColor3, renderingMode: .automatic)
            searchIcon = searchIcon?.withTintColor(UIColor.theme.neutralColor6, renderingMode: .automatic)
        }
        self.icon.image = searchIcon
        self.searchField.attributedPlaceholder = NSAttributedString {
            AttributedText(" "+"Search".chat.localize).foregroundColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor6)
        }
        self.back.setImage(image, for: .normal)
        self.cancel.setTitleColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, for: .normal)
        self.searchField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.searchField.tintColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.searchField.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
    
}
