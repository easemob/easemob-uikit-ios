//
//  MessageReplyView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/5.
//

import UIKit

@objc open class MessageReplyView: UIView {
    
    private var replyPhotoImage = UIImage(named: "reply_image", in: .chatBundle, with: nil)
    private var replyAudioImage = UIImage(named: "reply_audio", in: .chatBundle, with: nil)
    private var replyVideoImage = UIImage(named: "reply_video", in: .chatBundle, with: nil)
    private var replyFileImage = UIImage(named: "reply_file", in: .chatBundle, with: nil)
    private var replyContactImage = UIImage(named: "reply_contact", in: .chatBundle, with: nil)
    
    
    public private(set) lazy var replyUser: UILabel = {
        UILabel(frame: CGRect(x: 12, y: 8, width: self.frame.width-12-36-44-8, height: 16)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var replyContent: UILabel = {
        UILabel(frame: CGRect(x: 12, y: self.replyUser.frame.maxY, width: self.frame.width-12-36-44-8, height: 16)).backgroundColor(.clear).numberOfLines(2)
    }()
    
    public private(set) lazy var replyIcon: ImageView = {
        ImageView(frame: CGRect(x: self.frame.width-80, y: 8, width: 36, height: 36))
    }()
    
    public private(set) lazy var videoPlay: UIImageView = {
        UIImageView(frame: CGRect(x: 6, y: 6, width: 24, height: 24)).contentMode(.scaleAspectFit).image(UIImage(named: "video_icon", in: .chatBundle, with: nil))
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.replyUser,self.replyContent,self.replyIcon])
        self.replyIcon.addSubview(self.videoPlay)
        self.videoPlay.isHidden = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @MainActor
    @objc public func refresh(entity: MessageEntity) {
        self.cornerRadius(Appearance.chat.imageMessageCorner)
        guard let message = entity.message.quoteMessage else {
            self.replyIcon.isHidden = true
            self.replyUser.isHidden = true
            self.replyUser.frame = .zero
            self.replyContent.frame = CGRect(x: 5, y: 5, width: self.frame.width-10, height: self.frame.height-10)
            self.replyContent.attributedText = entity.replyContent
            return
        }
        if let content = entity.replyContent,content.string != "message doesn't exist".chat.localize {
            self.replyUser.isHidden = false
            self.replyIcon.isHidden = false
            if message.body.type == .image || message.body.type == .video {
                self.replyUser.frame = CGRect(x: 12, y: 8, width: self.frame.width-24-36-8, height: 16)
            } else {
                self.replyUser.frame = CGRect(x: 12, y: 8, width: self.frame.width-24, height: 16)
            }
            self.replyContent.frame = CGRect(x: 12, y: self.replyUser.frame.maxY, width: self.replyUser.frame.width, height: self.frame.height - 34)
            
            self.replyUser.attributedText = entity.replyTitle
            self.replyContent.attributedText = entity.replyContent
            self.constructIcon(message: message)
        } else {
            self.replyIcon.isHidden = true
            self.replyUser.isHidden = true
            self.replyUser.frame = .zero
            self.replyContent.frame = CGRect(x: 5, y: 5, width: self.frame.width-10, height: self.frame.height-10)
            self.replyContent.attributedText = entity.replyContent
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructIcon(message: ChatMessage) {
        if let body = message.body as? ChatVideoMessageBody,let path = body.thumbnailRemotePath {
            if path.isEmpty {
                self.replyIcon.image = self.replyVideoImage
            } else {
                self.replyIcon.image(with: path, placeHolder: Theme.style == .dark ? self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor7):self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor5)) { [weak self] image in
                    if image != nil{
                        self?.videoPlay.isHidden = false
                    }
                }
            }
        }
        if let body = message.body as? ChatImageMessageBody {
            if message.from == ChatUIKitContext.shared?.currentUserId ?? "" {
                if FileManager.default.fileExists(atPath: body.localPath) {
                    self.replyIcon.image = UIImage(contentsOfFile: body.localPath)
                } else {
                    self.replyIcon.image(with: body.remotePath, placeHolder: Theme.style == .dark ? self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor7):self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor5))
                }
            } else {
                self.replyIcon.image(with: body.thumbnailRemotePath ?? "", placeHolder: Theme.style == .dark ? self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor7):self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor5))
            }
        }
        if message.body.type == .image || message.body.type == .video {
            self.replyIcon.isHidden = false
            self.replyIcon.frame = CGRect(x: self.frame.width-48, y: 8, width: 36, height: 36)
        } else {
            self.replyIcon.isHidden = true
        }
    }
    
    private func icon(message: ChatMessage) -> UIImage? {
        switch message.body.type {
        case .image: return self.replyPhotoImage
        case .video: return self.replyVideoImage
        case .file: return  self.replyFileImage
        case .voice: return self.replyAudioImage
        case .custom:
            if let body = message.body as? ChatCustomMessageBody {
                if body.event == EaseChatUIKit_user_card_message {
                    return self.replyContactImage
                }
            }
            return nil
        
        default:
            return nil
        }
    }
    
    @objc private func cancelAction() {
        self.isHidden = true
        self.replyUser.attributedText = nil
        self.replyContent.attributedText = nil
        self.replyIcon.image = nil
    }
}


extension MessageReplyView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.replyIcon.layerProperties(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor8, 0.5)
        self.replyIcon.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor9)
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
    }
}



