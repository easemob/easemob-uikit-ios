//
//  SearchHistoryMessageCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/15.
//

import UIKit

@objcMembers open class SearchHistoryMessageCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).cornerRadius(Appearance.avatarRadius).backgroundColor(.clear)
    }()
    
    public private(set) lazy var conversationName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 18)).backgroundColor(.clear).font(UIFont.theme.labelLarge).textColor(UIColor.theme.neutralColor1)
    }()
    
    public private(set) lazy var messageContent: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.maxX-20, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).backgroundColor(.clear)
    }()

    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.conversationName,self.messageContent])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.center = CGPoint(x: self.avatar.center.x, y: self.contentView.center.y)
        self.conversationName.frame =  CGRect(x: self.avatar.frame.maxX+12, y: 10, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 18)
        self.messageContent.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.maxY-20, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 18)
    }
    
    func refresh(message: ChatMessage,info: ChatUserProfileProtocol,keyword: String) {
        var nickName = info.nickname.isEmpty ? info.id:info.nickname
        if !info.remark.isEmpty {
            nickName = info.remark
        }
        self.conversationName.text = nickName
        self.messageContent.attributedText = self.highlightKeywords(keyword: keyword, in: message.showType)
        self.avatar.image(with: info.avatarURL, placeHolder:Appearance.conversation.singlePlaceHolder)
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
}

extension SearchHistoryMessageCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.conversationName.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1    
    }
    
}
