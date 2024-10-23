//
//  ForwardTargetCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/2/19.
//

import UIKit

@objc public enum ForwardTargetState: UInt {
    case normal
    case forwarded
}

@objcMembers open class ForwardTargetCell: UITableViewCell {
    
    public var actionClosure: ((ForwardTargetCell) -> Void)?

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)).cornerRadius(Appearance.avatarRadius).backgroundColor(.clear)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 22)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var action: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 72, y: self.nickName.frame.minY, width: 60, height: 18)).font(UIFont.theme.labelMedium).cornerRadius(Appearance.avatarRadius).textColor(UIColor.theme.neutralColor1, .normal).backgroundColor(UIColor.theme.neutralColor95).title("Send".chat.localize, .normal).title("Sent".chat.localize, .disabled).addTargetFor(self, action: #selector(actionClick), for: .touchUpInside)
    }()
    
    public private(set) lazy var separateLine: UIView = {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }()

    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickName,self.action,self.separateLine])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.center = CGPoint(x: self.avatar.center.x, y: self.contentView.center.y)
        self.nickName.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)
        self.nickName.center = CGPoint(x: self.nickName.center.x, y: self.contentView.center.y)
        self.action.frame = CGRect(x: self.contentView.frame.width-72, y: (self.contentView.frame.height-28)/2.0, width: 60, height: 28)
        self.separateLine.frame = CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    }
    
    open func refresh(info: ChatUserProfileProtocol,keyword: String,forward state: ForwardTargetState) {
        let nickName = info.nickname.isEmpty ? info.id:info.nickname
        self.nickName.attributedText = self.highlightKeywords(keyword: keyword, in: nickName )
        self.avatar.image(with: info.avatarURL, placeHolder: Appearance.conversation.groupPlaceHolder)
        self.action.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.separateLine.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
        if state == .normal {
            self.action.setTitleColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1, for: .normal)
        } else {
            self.action.setTitleColor(Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor7, for: .normal)
        }
        self.action.isEnabled = state == .normal
    }
    
    func highlightKeywords(keyword: String, in string: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString {
            AttributedText(string).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1).font(Font.theme.titleMedium)
        }
        if !keyword.isEmpty {
            var range = (string as NSString).range(of: keyword, options: .caseInsensitive)
            while range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, range: range)
                attributedString.addAttribute(.font, value: UIFont.theme.titleMedium, range: range)
                let remainingRange = NSRange(location: range.location + range.length, length: string.count - (range.location + range.length))
                range = (string as NSString).range(of: keyword, options: .caseInsensitive, range: remainingRange)
            }
        }
        return attributedString
    }

    @objc open func actionClick() {
        self.actionClosure?(self)
    }

}

