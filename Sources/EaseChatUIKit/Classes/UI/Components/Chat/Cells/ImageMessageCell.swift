//
//  ImageMessageCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/5.
//

import UIKit

@objc open class ImageMessageCell: MessageCell {
    
    public private(set) lazy var content: ImageView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> ImageView {
        ImageView(frame: .zero).backgroundColor(.clear).tag(bubbleTag).cornerRadius(Appearance.chat.imageMessageCorner)
    }

    @objc public required init(towards: BubbleTowards, reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.content)
        self.bubbleWithArrow.isHidden = true
        self.bubbleMultiCorners.isHidden = true
        self.addGestureTo(view: self.content, target: self)
        self.longPressGestureTo(view: self.content,target: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        self.content.frame = CGRect(x: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minX:self.bubbleMultiCorners.frame.minX, y: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minY:self.bubbleMultiCorners.frame.minY, width: entity.bubbleSize.width, height: entity.bubbleSize.height)
        if let body = (entity.message.body as? ChatImageMessageBody) {
            if entity.message.direction == .receive {
                if let url = body.thumbnailLocalPath,!url.isEmpty,FileManager.default.fileExists(atPath: url) {
                    self.content.image = UIImage(contentsOfFile: url)
                } else {
                    self.content.image(with: body.thumbnailRemotePath, placeHolder: Appearance.chat.imagePlaceHolder)
                }
            } else {
                if let path = body.localPath,!path.isEmpty,FileManager.default.fileExists(atPath: path) {
                    self.content.image = UIImage(contentsOfFile: path)
                } else {
                    if let url = body.thumbnailLocalPath,!url.isEmpty,FileManager.default.fileExists(atPath: url) {
                        self.content.image = UIImage(contentsOfFile: url)
                    } else {
                        self.content.image(with: body.thumbnailRemotePath, placeHolder: Appearance.chat.imagePlaceHolder)
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
