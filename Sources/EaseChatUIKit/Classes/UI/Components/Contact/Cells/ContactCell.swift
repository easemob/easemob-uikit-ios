import UIKit

@objc public enum ContactDisplayStyle: UInt {
    case normal
    case withCheckBox
}

@objc open class ContactCell: UITableViewCell {
    
    public private(set) lazy var checkbox: UIImageView = {
        self.createCheckbox()
    }()
    
    @objc open func createCheckbox() -> UIImageView {
        UIImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }
    
    public private(set) lazy var avatar: ImageView = {
        self.createAvatar()
    }()
    
    @objc open func createAvatar() -> ImageView {
        ImageView(frame: CGRect(x: self.display == .normal ? 16:self.checkbox.frame.maxX+12, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)).contentMode(.scaleAspectFit).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }
    
    public private(set) lazy var nickName: UILabel = {
        self.createNickName()
    }()
    
    @objc open func createNickName() -> UILabel {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-30, height: 16)).font(UIFont.theme.titleMedium).backgroundColor(.clear).textColor(UIColor.theme.neutralColor1)
    }
    
    public private(set) lazy var separatorLine: UIView = {
        self.createSeparatorLine()
    }()
    
    @objc open func createSeparatorLine() -> UIView {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }
    
    public private(set) var display = ContactDisplayStyle.normal
    
    @objc public required init(displayStyle: ContactDisplayStyle,identifier: String?) {
        super.init(style: .default, reuseIdentifier: identifier)
        self.display = displayStyle
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
    
    @objc open func refresh(profile: EaseProfileProtocol) {
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.avatar.image(with: profile.avatarURL, placeHolder: Appearance.avatarPlaceHolder)
        self.nickName.text = profile.nickname.isEmpty ? profile.id:profile.nickname
        if self.display == .withCheckBox,let item = profile as? EaseProfile {
            self.checkbox.image = UIImage(named: item.selected ? "select":"unselect", in: .chatBundle, with: nil)
        }
    }
    
    @objc public func refresh(profile: EaseProfileProtocol,keyword: String) {
        let nickName = profile.nickname.isEmpty ? profile.id:profile.nickname
        self.nickName.attributedText = self.highlightKeywords(keyword: keyword, in: nickName)
        self.avatar.image(with: profile.avatarURL, placeHolder: Appearance.conversation.singlePlaceHolder)
        if self.display == .withCheckBox,let item = profile as? EaseProfile {
            self.checkbox.image = UIImage(named: item.selected ? "select":"unselect", in: .chatBundle, with: nil)
        }
    }
    
    @objc public func highlightKeywords(keyword: String, in string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString {
            AttributedText(string).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        }
        if !keyword.isEmpty {
            var range = (string as NSString).range(of: keyword, options: .caseInsensitive)
            while range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, range: range)
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

extension ContactCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
    
    
}
