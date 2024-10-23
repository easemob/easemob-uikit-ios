//
//  VideoMessageCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/5.
//

import UIKit

@objc open class VideoMessageCell: MessageCell {

    public private(set) lazy var content: ImageView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> ImageView {
        ImageView(frame: .zero).tag(bubbleTag).cornerRadius(Appearance.chat.imageMessageCorner)
    }
    
    public private(set) lazy var play: UIImageView = {
        self.createPlay()
    }()
    
    @objc open func createPlay() -> UIImageView {
        UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 64, height: 64))).image(UIImage(named: "video_message_play", in: .chatBundle, with: nil)).contentMode(.scaleAspectFit)
    }

    @objc required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.bubbleWithArrow.isHidden = true
        self.bubbleMultiCorners.isHidden = true
        self.contentView.addSubview(self.content)
        self.addGestureTo(view: self.content, target: self)
        self.longPressGestureTo(view: self.content, target: self)
        self.content.addSubview(self.play)
        self.play.isHidden = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        self.content.frame = CGRect(x: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minX:self.bubbleMultiCorners.frame.minX, y: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minY:self.bubbleMultiCorners.frame.minY, width: entity.bubbleSize.width, height: entity.bubbleSize.height)
        self.play.center = CGPoint(x: entity.bubbleSize.width/2.0, y: entity.bubbleSize.height/2.0)
        if let body = (entity.message.body as? ChatVideoMessageBody) {
            if entity.message.direction == .receive {
                if let url = (entity.message.body as? ChatVideoMessageBody)?.thumbnailLocalPath,FileManager.default.fileExists(atPath: url) {
                    self.content.image = UIImage(contentsOfFile: url)
                    self.play.isHidden = false
                } else {
                    if let thumbnailRemotePath = body.thumbnailRemotePath {
                        self.content.image(with: thumbnailRemotePath, placeHolder: Appearance.chat.videoPlaceHolder) { [weak self] image in
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
                    self.content.image = UIImage(contentsOfFile: path)
                    self.play.isHidden = false
                } else {
                    self.play.isHidden = true
                    if let thumbnailLocalPath = body.thumbnailLocalPath,FileManager.default.fileExists(atPath: thumbnailLocalPath) {
                        self.content.image = UIImage(contentsOfFile: thumbnailLocalPath)
                        self.play.isHidden = false
                    } else {
                        if let thumbnailRemotePath = body.thumbnailRemotePath {
                            self.content.image(with: thumbnailRemotePath, placeHolder: Appearance.chat.videoPlaceHolder) { [weak self] image in
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
    
    open override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
        self.content.backgroundColor = style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
        self.content.layerProperties(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9, 1)
    }

}
