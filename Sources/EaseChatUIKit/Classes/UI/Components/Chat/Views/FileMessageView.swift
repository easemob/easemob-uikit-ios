//
//  FileMessageView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/7.
//

import UIKit

@objc open class FileMessageView: UIView {
    
    public private(set) var towards = BubbleTowards.left
    
    public var fileSizeReceiveColor: UIColor {
        Theme.style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5
    }
    
    public var fileSizeSendColor: UIColor {
        Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor95
    }

    public private(set) lazy var content: UILabel = {
        UILabel(frame: CGRect(x: self.towards == .left ? 12:self.frame.width-12-20-12, y: 5, width: self.frame.width - self.frame.height - 16 - 16 - 12, height: 24)).backgroundColor(.clear).numberOfLines(1).font(UIFont.theme.labelLarge).lineBreakMode(.byTruncatingMiddle)
    }()
    
    public private(set) lazy var fileSize: UILabel = {
        UILabel(frame: CGRect(x: self.content.frame.minX, y: self.content.frame.maxY, width: self.frame.width - self.frame.height - 16 - 16 - 12, height: 18)).backgroundColor(.clear).numberOfLines(1).font(UIFont.theme.bodyMedium)
    }()
    
    public private(set) lazy var fileIcon: UIImageView = {
        UIImageView(frame: .zero).backgroundColor(.clear).contentMode(.scaleAspectFit).cornerRadius(Appearance.chat.bubbleStyle == .withArrow ? 4:8)
    }()
    
    public private(set) lazy var fileIconView: UIImageView = {
        UIImageView(frame: CGRect(x: 6, y: 6, width: self.fileIcon.frame.height-12, height: self.fileIcon.frame.height-12)).backgroundColor(.clear).contentMode(.scaleAspectFit).cornerRadius(Appearance.chat.bubbleStyle == .withArrow ? 4:8)
    }()
    
    @objc required public init(frame: CGRect,towards: BubbleTowards) {
        super.init(frame: frame)
        self.towards = towards
        self.addSubViews([self.content,self.fileSize,self.fileIcon])
        self.fileIcon.addSubview(self.fileIconView)
        Theme.registerSwitchThemeViews(view: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func refresh(entity: MessageEntity) {
        self.towards = entity.message.direction == .receive ? .left:.right
        self.fileIcon.frame = CGRect(x: self.towards == .right ? 8:self.frame.width - (self.frame.height - 16) - 8, y: 8, width: self.frame.height - 16, height: self.frame.height - 16)
        self.fileIconView.frame = CGRect(x: 6, y: 6, width: self.fileIcon.frame.height-12, height: self.fileIcon.frame.height-12)
        self.content.frame = CGRect(x: self.towards == .left ? 12:self.fileIcon.frame.maxX+12, y: 5, width: self.frame.width - (self.frame.height - 16) - 16 - 12, height: 24)
        self.fileSize.frame = CGRect(x: self.content.frame.minX, y: self.content.frame.maxY, width: self.content.frame.width, height: 18)
        self.fileIcon.cornerRadius(.extraSmall)
        self.switchTheme(style: Theme.style)
        if self.towards == .right {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
            self.fileSize.textColor = self.fileSizeSendColor
        } else {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5
            self.fileSize.textColor = self.fileSizeReceiveColor
        }
        self.content.text = entity.message.showContent
        if let body = entity.message.body as? ChatFileMessageBody {
            self.fileSize.text = "\(self.formatFileSize(Int(body.fileLength)))"
        }
    }
    
    func formatFileSize(_ fileSize: Int) -> String {
        let kilobyte = 1024
        let megabyte = kilobyte * kilobyte
        
        if fileSize < kilobyte {
            return "\(fileSize) B"
        } else if fileSize < megabyte {
            let sizeInKB = Double(fileSize) / Double(kilobyte)
            return String(format: "%.2f KB", sizeInKB)
        } else {
            let sizeInMB = Double(fileSize) / Double(megabyte)
            return String(format: "%.2f MB", sizeInMB)
        }
    }
}

extension FileMessageView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        
        self.fileIcon.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor98
        var image = UIImage(named: "file_message_icon", in: .chatBundle, with: nil)
        if style == .dark {
            image = image?.withTintColor(UIColor.theme.neutralColor6)
        }
        self.fileIconView.image = image
    }
}
