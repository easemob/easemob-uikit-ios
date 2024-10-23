//
//  ChatHistoryCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/31.
//

import UIKit

@objcMembers open class ChatHistoryCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: 10, width: 32, height: 32)).cornerRadius(Appearance.avatarRadius).contentMode(.scaleAspectFill)
    }()
    
    public private(set) lazy var nickname: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+10, y: self.avatar.frame.minY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-132, height: 20)).font(UIFont.theme.labelMedium)
    }()
    
    public private(set) lazy var messageDate: UILabel = {
        UILabel(frame: CGRect(x: self.contentView.frame.width-132, y: 10, width: 120, height: 16)).font(UIFont.theme.bodySmall).backgroundColor(.clear).textAlignment(.right)
    }()
    
    public private(set) lazy var content: UIView = {
        UIView(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20))
    }()
    
    public private(set) lazy var play: UIImageView = {
        UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 64, height: 64))).image(UIImage(named: "video_message_play", in: .chatBundle, with: nil)).contentMode(.scaleAspectFit)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.content.frame.minX, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width, height: 0.5))
    }()
    
    
    @objc public required init(reuseIdentifier: String,message: ChatMessage) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        switch message.body.type {
        case .video,.image:
            self.content = ImageView(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20)).cornerRadius(.extraSmall).contentMode(.scaleAspectFit)
        default:
            self.content = UILabel(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20)).numberOfLines(0)
        }
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickname,self.content,self.messageDate,self.separatorLine])
        self.content.addSubview(self.play)
        self.play.isHidden = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.frame = CGRect(x: 16, y: 10, width: 32, height: 32)
        self.nickname.frame = CGRect(x: self.avatar.frame.maxX+10, y: self.avatar.frame.minY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-132, height: 20)
        self.messageDate.frame =  CGRect(x: self.contentView.frame.width-132, y: 10, width: 120, height: 16)
        self.separatorLine.frame = CGRect(x: self.nickname.frame.minX, y: self.contentView.frame.height - 0.5, width: self.contentView.frame.width, height: 0.5)
//        self.content.frame = CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: ScreenWidth-self.avatar.frame.maxX-10-16, height: self.frame.height - self.nickname.frame.maxY)
    }
    
    @objc open func refresh(entity: MessageEntity) {
        let nickName = entity.message.user?.nickname ?? entity.message.from
        self.nickname.text = nickName
        if let avatarURL = entity.message.user?.avatarURL {
            self.avatar.image(with: avatarURL, placeHolder: Appearance.conversation.singlePlaceHolder)
        } else {
            self.avatar.image = Appearance.conversation.singlePlaceHolder
        }
        self.messageDate.text = entity.message.showDetailDate
        switch entity.message.body.type {
        case .video,.image:
            self.content.frame = CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: entity.bubbleSize.width, height: entity.bubbleSize.height)
            self.play.isHidden = true
            self.play.frame = CGRect(origin: CGPoint(x: (entity.bubbleSize.width-64)/2, y: (entity.bubbleSize.height-64)/2), size: CGSize(width: 64, height: 64))
            if let container = self.content as? ImageView {
                if let body = (entity.message.body as? ChatImageMessageBody) {
                    if let url = body.thumbnailLocalPath,!url.isEmpty,FileManager.default.fileExists(atPath: url) {
                        container.image = UIImage(contentsOfFile: url)
                    } else {
                        container.image(with: body.thumbnailRemotePath, placeHolder: Appearance.chat.imagePlaceHolder) { image in
                            if image == nil {
                                container.image = Appearance.chat.imagePlaceHolder
                            }
                        }
                    }
                }
                if let body = (entity.message.body as? ChatVideoMessageBody) {
                    if let url = (entity.message.body as? ChatVideoMessageBody)?.thumbnailLocalPath,FileManager.default.fileExists(atPath: url) {
                        container.image = UIImage(contentsOfFile: url)
                        self.play.isHidden = false
                    } else {
                        if let thumbnailRemotePath = body.thumbnailRemotePath {
                            container.image(with: thumbnailRemotePath, placeHolder: Appearance.chat.videoPlaceHolder) { [weak self] image in
                                if image != nil {
                                    self?.play.isHidden = false
                                } else {
                                    self?.play.isHidden = true
                                }
                            }
                        } else {
                            self.play.isHidden = true
                        }
                    }
                }
            }
        default:
            let textHeight = entity.textSize().height
            self.content.frame = CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: ScreenWidth-self.avatar.frame.maxX-10-16, height: textHeight)
            self.play.isHidden = true
            if let container = self.content as? UILabel {
                container.numberOfLines = 0
                container.attributedText = entity.content
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatHistoryCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickname.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
        self.messageDate.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor7
        if self.content is ImageView {
            self.content.backgroundColor(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
        }
    }
    
    
}
