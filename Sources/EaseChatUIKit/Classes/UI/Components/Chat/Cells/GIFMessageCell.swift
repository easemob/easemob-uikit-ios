//
//  GIFMessageCell.swift
//  ChatUIKit
//
//  Created by Trae AI on 2023/12/5.
//

import UIKit
import FLAnimatedImage

/// A custom view that wraps FLAnimatedImageView for displaying GIF images
@objc open class GIFAnimatedImageView: UIView {
    
    public private(set) lazy var animatedImageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(animatedImageView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        animatedImageView.frame = self.bounds
    }
    
    /// Loads a GIF from the specified path
    /// - Parameter path: The file path of the GIF
    public func loadGif(from path: String) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                let image = FLAnimatedImage(animatedGIFData: data)
                DispatchQueue.main.async {
                    self?.animatedImageView.animatedImage = image
                }
            }
        }
    }
}

@objc open class GIFMessageCell: MessageCell {
    
    public private(set) lazy var content: GIFAnimatedImageView = {
        self.createContent()
    }()
    
    @objc open func createContent() -> GIFAnimatedImageView {
        GIFAnimatedImageView(frame: .zero).backgroundColor(.clear).tag(bubbleTag).cornerRadius(Appearance.chat.imageMessageCorner)
    }

    @objc public required init(towards: BubbleTowards, reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(self.content)
        self.bubbleWithArrow.isHidden = true
        self.bubbleMultiCorners.isHidden = true
        self.addGestureTo(view: self.content, target: self)
        self.longPressGestureTo(view: self.content, target: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        self.content.frame = CGRect(x: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minX:self.bubbleMultiCorners.frame.minX, y: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minY:self.bubbleMultiCorners.frame.minY, width: entity.bubbleSize.width, height: entity.bubbleSize.height)
        if let body = (entity.message.body as? ChatImageMessageBody), body.isGif {
            if entity.message.direction == .receive {
                if let thumbnailLocalPath = body.thumbnailLocalPath, !thumbnailLocalPath.isEmpty, FileManager.default.fileExists(atPath: thumbnailLocalPath) {
                    self.content.loadGif(from: thumbnailLocalPath)
                } else {
                    if (body.thumbnailDownloadStatus != .downloading) {
                        ChatClient.shared().chatManager?.downloadMessageThumbnail(entity.message, progress: nil)
                    }
                }
            } else {
                if let path = body.thumbnailLocalPath, !path.isEmpty, FileManager.default.fileExists(atPath: path) {
                    self.content.loadGif(from: path)
                } else {
                    if let localPath = body.localPath, !localPath.isEmpty, FileManager.default.fileExists(atPath: localPath) {
                        self.content.loadGif(from: localPath)
                    } else {
                        if (body.thumbnailDownloadStatus != .downloading) {
                            ChatClient.shared().chatManager?.downloadMessageThumbnail(entity.message, progress: nil)
                        }
                    }
                }
            }
        }
    }
    
    open override func switchTheme(style: ThemeStyle) {
        super.switchTheme(style: style)
        self.content.backgroundColor = style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
        self.content.layer.borderColor = (style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9).cgColor
        self.content.layer.borderWidth = 1
    }
}
