//
//  MessageTopicView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/16.
//

import UIKit

@objcMembers open class MessageTopicView: UIView {
    
    public private(set) lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 8, y: 8, width: 16, height: 16)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public private(set) lazy var title: UILabel = {
        UILabel(frame: CGRect(x: self.icon.frame.maxX+2, y: 8, width: self.frame.width-82, height: 16)).font(UIFont.theme.labelSmall).backgroundColor(.clear)
    }()
    
    public private(set) lazy var messageCount: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width-80, y: 8, width: 56, height: 16)).font(UIFont.theme.labelSmall).backgroundColor(.clear).textAlignment(.right)
    }()
    
    public private(set) lazy var indicator: UIImageView = {
        UIImageView(frame: CGRect(x: self.frame.width-24, y: 8, width: 16, height: 16)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public private(set) lazy var lastMessage: UILabel = {
        UILabel(frame: CGRect(x: 12, y: self.title.frame.maxY+6, width: self.frame.width-24, height: 16)).backgroundColor(.clear)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.icon,self.title,self.messageCount,self.indicator,self.lastMessage])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func resetFrame() {
        self.title.frame = CGRect(x: self.icon.frame.maxX+2, y: 8, width: self.frame.width-82, height: 16)
        self.messageCount.frame = CGRect(x: self.frame.width-80, y: 8, width: 56, height: 16)
        self.indicator.frame = CGRect(x: self.frame.width-24, y: 8, width: 16, height: 16)
        self.lastMessage.frame = CGRect(x: 12, y: self.title.frame.maxY+6, width: self.frame.width-24, height: 16)
    }
    
    @objc open func refresh(entity: MessageEntity) {
        self.resetFrame()
        self.switchTheme(style: Theme.style)
        self.title.text = entity.message.chatThread?.threadName ?? ""
        self.lastMessage.attributedText = entity.topicContent
        if let count = entity.message.chatThread?.messageCount {
            self.indicator.isHidden = false
            if count > 99 {
                self.messageCount.text = "99+"+"barrage_long_press_menu_reply".chat.localize
            } else {
                self.messageCount.text = "\(count)"+"barrage_long_press_menu_reply".chat.localize
            }
        } else {
            self.indicator.isHidden = true
        }
        
    }
}

extension MessageTopicView: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        let textColor = style == .dark ? UIColor.theme.neutralColor9:UIColor.theme.neutralColor3
        var image = UIImage(named: "message_topic", in: .chatBundle, with: nil)
        if style == .light {
            image = image?.withTintColor(textColor)
        }
        self.icon.image = image
        self.title.textColor = textColor
        self.messageCount.textColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        var indicatorImage = UIImage(named: "topic_indicator", in: .chatBundle, with: nil)
        if style == .light {
            indicatorImage = indicatorImage?.withTintColor(UIColor.theme.primaryLightColor)
        }
        self.indicator.image = indicatorImage
    }
    
}
