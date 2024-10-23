//
//  ReactionUserCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/30.
//

import UIKit

@objcMembers open class ReactionUserCell: UITableViewCell {

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
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-40)/2.0, width: 40, height: 40)).contentMode(.scaleAspectFill).backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
    }
    
    public private(set) lazy var nickName: UILabel = {
        self.createNickName()
    }()
    
    @objc open func createNickName() -> UILabel {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-30, height: 16)).font(UIFont.theme.titleMedium).backgroundColor(.clear).textColor(UIColor.theme.neutralColor1)
    }
    
    
    public private(set) lazy var trash: UIImageView = {
        UIImageView(frame: CGRect(x: self.contentView.frame.width-40, y: self.contentView.frame.height/2.0-10, width: 20, height: 20)).backgroundColor(.clear).contentMode(.scaleAspectFit)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }()

    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickName,self.trash,self.separatorLine])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.center = CGPoint(x: self.avatar.center.x, y: self.contentView.center.y)
        self.nickName.center = CGPoint(x: self.nickName.center.x, y: self.contentView.center.y)
        self.trash.frame = CGRect(x: self.contentView.frame.width-40, y: self.contentView.frame.height/2.0-10, width: 20, height: 20)
        self.separatorLine.frame = CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    
    }
    
    @objc open func refresh(profile: ChatUserProfileProtocol) {
        self.nickName.textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        
        var nickName = profile.id
        var avatarURL = profile.avatarURL
        var info = ChatUIKitContext.shared?.chatCache?[profile.id]
        if info == nil {
            info = ChatUIKitContext.shared?.userCache?[profile.id]
        }
        if let info = info {
            if !info.nickname.isEmpty {
                nickName = info.nickname
            }
            if !info.remark.isEmpty {
                nickName = info.remark
            }
            if !info.avatarURL.isEmpty {
                avatarURL = info.avatarURL
            }
        }
        self.nickName.text = nickName
        if !profile.avatarURL.isEmpty {
            self.avatar.image(with: avatarURL, placeHolder: Appearance.conversation.singlePlaceHolder)
        } else {
            self.avatar.image = Appearance.conversation.singlePlaceHolder
        }
        var image = UIImage(named: "reaction_trash", in: .chatBundle, with: nil)
        if Theme.style == .dark {
            image = image?.withTintColor(UIColor.theme.neutralColor7)
        }
        self.trash.image = image
        self.trash.isHidden = ChatUIKitContext.shared?.currentUserId ?? "" != profile.id
        self.separatorLine.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
    }

}
