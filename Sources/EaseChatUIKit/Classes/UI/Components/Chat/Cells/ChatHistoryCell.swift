//
//  ChatHistoryCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/31.
//

import UIKit

@objcMembers open class ChatHistoryCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        ImageView(frame: CGRect(x: 16, y: 10, width: 32, height: 32)).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var nickname: UILabel = {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+10, y: self.avatar.frame.minY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-8, height: 20))
    }()
    
    public private(set) lazy var content: UIView = {
        UIView(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20))
    }()
    
    public private(set) lazy var play: UIImageView = {
        UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 64, height: 64))).image(UIImage(named: "video_message_play", in: .chatBundle, with: nil)).contentMode(.scaleAspectFit)
    }()
    
    
    @objc public required init(reuseIdentifier: String,message: ChatMessage) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        switch message.body.type {
        case .video,.image:
            self.content = ImageView(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20)).cornerRadius(.extraSmall).contentMode(.scaleAspectFit)
        default:
            self.content = UILabel(frame: CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: self.contentView.frame.width-self.avatar.frame.maxX-10-16, height: 20)).numberOfLines(0)
        }
        self.contentView.addSubViews([self.avatar,self.nickname,self.content])
        self.content.addSubview(self.play)
        self.play.isHidden = true
    }
    
    @objc open func refresh(entity: MessageEntity) {
        let nickName = entity.message.user?.nickname ?? entity.message.from
        self.nickname.text = nickName
        if let avatarURL = entity.message.user?.avatarURL {
            self.avatar.image(with: avatarURL, placeHolder: Appearance.conversation.singlePlaceHolder)
        } else {
            self.avatar.image = Appearance.conversation.singlePlaceHolder
        }
        self.content.frame = CGRect(x: self.nickname.frame.minX, y: self.nickname.frame.maxY, width: entity.bubbleSize.width, height: entity.bubbleSize.height)
        switch entity.message.body.type {
        case .video,.image:
            if let container = self.content as? ImageView {
                if let body = (entity.message.body as? ChatImageMessageBody) {
                    self.play.isHidden = true
                    if entity.message.direction == .receive {
                        if let url = body.thumbnailLocalPath,!url.isEmpty {
                            container.image = UIImage(contentsOfFile: url)
                        } else {
                            container.image(with: body.thumbnailRemotePath, placeHolder: Appearance.chat.imagePlaceHolder)
                        }
                    } else {
                        if let path = body.localPath,!path.isEmpty,FileManager.default.fileExists(atPath: path) {
                            container.image = UIImage(contentsOfFile: path)
                        } else {
                            if let url = body.thumbnailLocalPath,!url.isEmpty,FileManager.default.fileExists(atPath: url) {
                                container.image = UIImage(contentsOfFile: url)
                            } else {
                                container.image(with: body.thumbnailRemotePath, placeHolder: Appearance.chat.imagePlaceHolder)
                            }
                        }
                    }
                }
                if let body = (entity.message.body as? ChatVideoMessageBody) {
                    self.play.isHidden = false
                    self.play.center = self.content.center
                    if entity.message.direction == .receive {
                        if let url = (entity.message.body as? ChatVideoMessageBody)?.thumbnailLocalPath {
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
                    } else {
                        if let path = body.thumbnailLocalPath,!path.isEmpty,FileManager.default.fileExists(atPath: path) {
                            container.image = UIImage(contentsOfFile: path)
                            self.play.isHidden = false
                        } else {
                            self.play.isHidden = true
                            if let thumbnailLocalPath = body.thumbnailLocalPath,FileManager.default.fileExists(atPath: thumbnailLocalPath) {
                                container.image = UIImage(contentsOfFile: thumbnailLocalPath)
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
                                }
                            }
                        }
                    }
                }
            }
        default:
            self.play.isHidden = true
            if let container = self.content as? UILabel {
                if entity.message.body.type == .text {
                    container.attributedText = entity.content
                }
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
