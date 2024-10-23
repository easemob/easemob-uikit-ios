//
//  AudioMessageView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/9.
//

import UIKit

@objc open class AudioMessageView: UIView {
    
    public private(set) var towards = BubbleTowards.left

    public private(set) lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.towards == .left ? 12+20:self.frame.width-12-20-12, y: 5, width: self.frame.width-24, height: self.frame.height-10)).backgroundColor(.clear).numberOfLines(1).font(UIFont.theme.bodyLarge).backgroundColor(.clear)
    }()
    
    public private(set) lazy var audioIcon: UIImageView = {
        UIImageView(frame: CGRect(x: self.towards == .left ? 12:self.frame.width-12-20, y: 5, width: self.frame.height - 10, height: self.frame.height - 10)).backgroundColor(.clear).contentMode(.scaleAspectFit)
    }()
    
    @objc required public init(frame: CGRect,towards: BubbleTowards) {
        super.init(frame: frame)
        self.towards = towards
        self.addSubViews([self.content,self.audioIcon])
        self.audioIcon.animationDuration = 1.0
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func refresh(entity: MessageEntity) {
        self.towards = entity.message.direction == .receive ? .left:.right
        self.content.frame = CGRect(x: self.towards == .left ? 12+20+8:12, y: 5, width: self.frame.width-32-20, height: self.frame.height-10)
        self.audioIcon.frame = CGRect(x: self.towards == .left ? 12:self.frame.width-12-20, y: self.frame.height/2.0-10, width: 20, height: 20)
        self.switchTheme(style: Theme.style)
        let currentUser = ChatUIKitContext.shared?.currentUserId ?? ""
        var textColor = UIColor.white
        if entity.message.direction == .send {
            textColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        } else {
            textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        }
        self.content.textColor = textColor
        self.content.textAlignment = entity.message.direction == .receive ? .right:.left
        self.content.text = entity.message.showContent
        if entity.playing {
            self.audioIcon.startAnimating()
        } else {
            self.audioIcon.stopAnimating()
        }
    }
}

extension AudioMessageView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        if self.towards == .left {
            self.audioIcon.image = UIImage(named: "audio_message_icon_show_left", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5)
            self.audioIcon.animationImages = Appearance.chat.receiveAudioAnimationImages
        } else {
            self.audioIcon.image = UIImage(named: "audio_message_icon_show_right", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralColor98)
            self.audioIcon.animationImages = Appearance.chat.sendAudioAnimationImages
        }
    }
}
