//
//  GroupParticipantCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/27.
//

import UIKit

@objc open class GroupParticipantCell: UITableViewCell {

    
    public private(set) lazy var checkbox: UIImageView = {
        UIImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: self.display == .normal ? 16:self.checkbox.frame.maxX+12, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)).contentMode(.scaleAspectFill).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius).contentMode(.scaleAspectFill)
    }()
    
    lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-30, height: 16)).font(UIFont.theme.titleMedium).backgroundColor(.clear).textColor(UIColor.theme.neutralColor1)
    }()
    
    lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }()
    
    public private(set) var display = ContactDisplayStyle.normal
    
    @objc public required init(displayStyle: ContactDisplayStyle,identifier: String?) {
        self.display = displayStyle
        super.init(style: .default, reuseIdentifier: identifier)
        if displayStyle == .normal {
            self.contentView.addSubViews([self.avatar,self.nickName,self.separatorLine])
        } else {
            self.contentView.addSubViews([self.checkbox,self.avatar,self.nickName,self.separatorLine])
        }
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    
    @objc public func refresh(profile: ChatUserProfileProtocol) {
        self.avatar.image(with: profile.avatarURL, placeHolder: Appearance.avatarPlaceHolder)
        self.nickName.text = profile.nickname.isEmpty ? profile.id:profile.nickname
        if self.display == .withCheckBox,let item = profile as? ChatUserProfile {
            self.checkbox.image = UIImage(named: item.selected ? "select":"unselect", in: .chatBundle, compatibleWith: nil)
        }
    }
    
    @objc public func refresh(profile: ChatUserProfileProtocol,keyword: String) {
        let nickName = profile.nickname.isEmpty ? profile.id:profile.nickname
        self.nickName.attributedText = self.highlightKeywords(keyword: keyword, in: nickName)
        if profile.avatarURL.lowercased() == "all" {
            self.avatar.image = UIImage(named: "all",in: .chatBundle,with: nil)
        } else {
            self.avatar.image(with: profile.avatarURL, placeHolder:Appearance.conversation.singlePlaceHolder)
        }
        if self.display == .withCheckBox,let item = profile as? ChatUserProfile {
            self.checkbox.image = UIImage(named: item.selected ? "select":"unselect", in: .chatBundle, compatibleWith: nil)
        }
    }
    
    func highlightKeywords(keyword: String, in string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString {
            AttributedText(string).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        }
        if !keyword.isEmpty {
            var range = (string as NSString).range(of: keyword, options: .caseInsensitive)
            while range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, range: range)
                let remainingRange = NSRange(location: range.location + range.length, length: string.count - (range.location + range.length))
                range = (string as NSString).range(of: keyword, options: .caseInsensitive, range: remainingRange)
            }
        }
        return attributedString
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.checkbox.frame = CGRect(x: 16, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)
        self.avatar.frame = CGRect(x: self.display == .normal ? 16:self.checkbox.frame.maxX+12, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)
        self.nickName.frame = CGRect(x: self.avatar.frame.maxX+12, y: (self.contentView.frame.height-16)/2.0, width: self.contentView.frame.width-self.avatar.frame.maxX-12-30, height: 16)
        self.separatorLine.frame = CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    }
    
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupParticipantCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
    
    
}
