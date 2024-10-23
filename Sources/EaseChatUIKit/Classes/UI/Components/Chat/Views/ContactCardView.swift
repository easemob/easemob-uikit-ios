//
//  ContactCardView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/11.
//

import UIKit

@objc open class ContactCardView: UIView {
    
    public private(set) var towards = BubbleTowards.left
    
    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 12, y: 12, width: 44, height: 44)).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var nickName: UILabel = {
        UILabel(frame: .zero).backgroundColor(.clear).numberOfLines(0).font(UIFont.theme.labelLarge)
    }()
    
    public private(set) lazy var divideLine: UIView = {
        UIView(frame: .zero)
    }()
    
    public private(set) lazy var alert: UILabel = {
        UILabel(frame: .zero).font(UIFont.theme.bodyExtraSmall).text("input_extension_menu_contact".chat.localize)
    }()

    @objc required public init(frame: CGRect,towards: BubbleTowards) {
        super.init(frame: frame)
        self.towards = towards
        self.addSubViews([self.avatar,self.nickName,self.divideLine,self.alert])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func refresh(entity: MessageEntity) {
        self.towards = entity.message.direction == .receive ? .left:.right
        self.nickName.textColor = self.towards == .right ? Appearance.chat.sendTextColor:Appearance.chat.receiveTextColor
        self.switchTheme(style: Theme.style)
        self.avatar.frame = CGRect(x: 12, y: 12, width: 44, height: 44)
        self.nickName.frame = CGRect(x: self.avatar.frame.maxX+12, y: 12, width: self.frame.width - 80, height: 44)
        self.divideLine.frame = CGRect(x: 12, y: self.avatar.frame.maxY+12.5, width: self.frame.width-24, height: 0.5)
        self.alert.frame = CGRect(x: 12, y: self.frame.height-18, width: 150, height: 12)
        if let body = entity.message.body as? ChatCustomMessageBody {
            if let avatarURL = body.customExt?["avatar"] as? String {
                if avatarURL.isEmpty {
                    self.avatar.image = Appearance.avatarPlaceHolder
                } else {
                    self.avatar.image(with: avatarURL, placeHolder: Appearance.avatarPlaceHolder)
                }
            }
            if let nickname = body.customExt?["nickname"] as? String {
                if nickname.isEmpty,let userId = body.customExt?["uid"] as? String   {
                    self.nickName.text = userId
                } else {
                    self.nickName.text = nickname
                }
            }
        }
    }

}

extension ContactCardView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        var divideColor = UIColor.white
        if self.towards == .left {
            if style == .dark {
                divideColor = UIColor.theme.neutralSpecialColor5
            } else {
                divideColor = UIColor.theme.neutralSpecialColor8
            }
            
        } else {
            divideColor = style == .dark ? UIColor.theme.primaryColor9:UIColor.theme.primaryColor8
        }
        
        self.divideLine.backgroundColor = divideColor
        if self.towards == .left {
            self.alert.textColor = style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5
        } else {
            self.alert.textColor = style == .dark ? UIColor.theme.neutralSpecialColor3:UIColor.theme.neutralColor98
        }
    }
    
    
}
