//
//  ConversationSearchCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import UIKit

@objc open class ConversationSearchCell: UITableViewCell {
    
    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).cornerRadius(Appearance.avatarRadius).backgroundColor(.clear).contentMode(.scaleAspectFill)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        self.createSeparatorLine()
    }()
    
    @objc open func createSeparatorLine() -> UIView {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }

    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickName,self.separatorLine])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.center = CGPoint(x: self.avatar.center.x, y: self.contentView.center.y)
        self.nickName.center = CGPoint(x: self.nickName.center.x, y: self.contentView.center.y)
        self.separatorLine.frame = CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    
    }
    
    func refresh(info: ConversationInfo,keyword: String) {
        var showName = ChatUIKitContext.shared?.userCache?[info.id]?.remark ?? ""
        if showName.isEmpty {
            if info.type == .chat {
                showName = ChatUIKitContext.shared?.userCache?[info.id]?.nickname ?? ""
            } else {
                showName = ChatUIKitContext.shared?.groupCache?[info.id]?.nickname ?? ""
            }
        }
        if showName.isEmpty {
            showName = info.id
        }
        var avatarURL = info.avatarURL
        if avatarURL.isEmpty {
            avatarURL = ChatUIKitContext.shared?.userCache?[info.id]?.avatarURL ?? ""
        }
        self.nickName.attributedText = self.highlightKeywords(keyword: keyword, in: showName)
        self.avatar.image(with: avatarURL, placeHolder: info.type == .chat ? Appearance.conversation.singlePlaceHolder:Appearance.conversation.groupPlaceHolder)
        self.separatorLine.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
    
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
