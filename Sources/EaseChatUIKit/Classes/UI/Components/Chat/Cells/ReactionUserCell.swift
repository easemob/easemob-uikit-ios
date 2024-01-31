//
//  ReactionUserCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/30.
//

import UIKit

@objcMembers open class ReactionUserCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).cornerRadius(Appearance.avatarRadius).backgroundColor(.clear)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-12-28-12, height: 16)).backgroundColor(.clear).font(UIFont.theme.labelLarge)
    }()
    
    public private(set) lazy var trash: UIImageView = {
        UIImageView(frame: CGRect(x: self.contentView.frame.width-40, y: 16, width: 28, height: 28)).backgroundColor(.clear).contentMode(.scaleAspectFit)
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
        self.trash.frame = CGRect(x: self.contentView.frame.width-40, y: 16, width: 28, height: 28)
        self.separatorLine.frame = CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    
    }
    
    @objc open func refresh(profile: EaseProfileProtocol) {
        let nickName = profile.nickname.isEmpty ? profile.id:profile.nickname
        self.nickName.text = nickName
        self.nickName.textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        
        if !profile.avatarURL.isEmpty {
            self.avatar.image(with: profile.avatarURL, placeHolder: Appearance.conversation.singlePlaceHolder)
        } else {
            self.avatar.image = Appearance.conversation.singlePlaceHolder
        }
        var image = UIImage(named: "reaction_trash", in: .chatBundle, with: nil)
        if Theme.style == .dark {
            image = image?.withTintColor(UIColor.theme.neutralColor7)
        }
        self.trash.image = image
        self.trash.isHidden = EaseChatUIKitContext.shared?.currentUserId ?? "" != profile.id
        self.separatorLine.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
    }

}
