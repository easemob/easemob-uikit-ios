//
//  MessageReplyView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/1.
//

import UIKit

@objc public class MessageInputReplyView: UIView {
    
    private var replyPhotoImage = UIImage(named: "reply_image", in: .chatBundle, with: nil)
    private var replyAudioImage = UIImage(named: "reply_audio", in: .chatBundle, with: nil)
    private var replyVideoImage = UIImage(named: "reply_video", in: .chatBundle, with: nil)
    private var replyFileImage = UIImage(named: "reply_file", in: .chatBundle, with: nil)
    private var replyContactImage = UIImage(named: "reply_contact", in: .chatBundle, with: nil)
    
    private var cancelImage = UIImage(named: "reply_cancel", in: .chatBundle, with: nil)
    
    public private(set) lazy var line: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5)).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    public private(set) lazy var replyUser: UILabel = {
        UILabel(frame: CGRect(x: 12, y: 8, width: self.frame.width-12-36-44-8, height: 16)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var replyContent: UILabel = {
        UILabel(frame: CGRect(x: 12, y: self.replyUser.frame.maxY, width: self.frame.width-12-36-44-8, height: 20)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var replyIcon: ImageView = {
        ImageView(frame: CGRect(x: self.frame.width-80, y: 8, width: 36, height: 36)).contentMode(.scaleAspectFit)
    }()
    
    public private(set) lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-32, y: 16, width: 20, height: 20)).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.replyUser,self.replyContent,self.replyIcon,self.cancel,self.line])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @MainActor
    @objc public func refresh(message: ChatMessage) {
        var replyTo = message.from
        if let nickName = message.user?.nickname {
            replyTo = nickName
        }
        self.replyUser.attributedText = NSAttributedString {
            AttributedText("Replying".chat.localize+" ").font(Font.theme.bodySmall).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5)
            AttributedText(replyTo).font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5)
        }
        self.replyContent.attributedText = self.constructReplyContent(message: message, replyTo: replyTo)
        if message.body.type == .image || message.body.type == .video {
            self.replyIcon.isHidden = false
        } else {
            self.replyIcon.isHidden = true
        }
        self.constructIcon(message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructReplyContent(message: ChatMessage,replyTo: String) -> NSAttributedString {
        let reply = NSMutableAttributedString()
        if let icon = message.replyIcon?.withTintColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5) {
            reply.append(NSAttributedString {
                ImageAttachment(icon, bounds: CGRect(x: 0, y: -3.5, width: 16, height: 16))
            })
        }
        if message.body.type == .text {
            reply.append(NSAttributedString {
                AttributedText(message.showContent).font(Font.theme.bodySmall).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
            })
        } else {
            reply.append(NSAttributedString {
                AttributedText("  "+message.showType).font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
                AttributedText("  "+message.showContent).font(Font.theme.bodySmall).foregroundColor(Theme.style == .dark ? Color.theme.neutralColor6:Color.theme.neutralColor5)
            })
        }
        return reply
    }
    
    private func constructIcon(message: ChatMessage) {
        if let body = message.body as? ChatImageMessageBody {
            self.replyIcon.image(with: body.thumbnailRemotePath, placeHolder: Theme.style == .dark ? self.icon(message: message)?.withTintColor(UIColor.theme.neutralColor5):self.icon(message: message))
        }
        if let body = message.body as? ChatVideoMessageBody,let path = body.thumbnailRemotePath {
            if path.isEmpty {
                self.replyIcon.image = self.icon(message: message)
            } else {
                let image = self.icon(message: message)
                self.replyIcon.image(with: path, placeHolder: Theme.style == .dark ? image?.withTintColor(UIColor.theme.neutralColor5):image)
            }
        }
    }
    
    private func icon(message: ChatMessage) -> UIImage? {
        switch message.body.type {
        case .image: return self.replyPhotoImage
        case .voice: return self.replyAudioImage
        case .video: return self.replyVideoImage
        case .file: return self.replyFileImage
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


extension MessageInputReplyView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.replyIcon.layerProperties(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor8, 0.5)
        self.replyIcon.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor9)
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.line.backgroundColor(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor8)
        if style == .light {
            self.cancelImage = self.cancelImage?.withTintColor(UIColor.theme.neutralColor3)
        } else {
            self.cancelImage = self.cancelImage?.withTintColor(UIColor.theme.neutralColor5)
        }
        self.cancel.setImage(self.cancelImage, for: .normal)
    }
}
