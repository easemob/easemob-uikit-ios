//
//  ChatThreadCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/2/7.
//

import UIKit

@objcMembers open class ChatThreadCell: UITableViewCell {
    
    private var moreImage = UIImage(named: "thread_more", in: .chatBundle, with: nil)
    
    public private(set) lazy var threadName: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 13, width: self.contentView.frame.width-30-30, height: 20)).font(UIFont.theme.titleSmall)
    }()
    
    public private(set) lazy var messageCount: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.contentView.frame.width-44, y: 13, width: 30, height: 16)).font(UIFont.theme.labelSmall)
    }()
    
    public private(set) lazy var latestMessage: UILabel = {
        UILabel(frame: CGRect(x: 16, y: self.threadName.frame.maxY+2, width: self.contentView.frame.width-32, height: 18)).lineBreakMode(.byTruncatingTail)
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: 16, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-16, height: 0.5))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.threadName,self.messageCount,self.latestMessage,self.separatorLine])
        self.messageCount.contentHorizontalAlignment = .left
        self.messageCount.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.messageCount.frame.width - 6, bottom: 0, right: 0)
        self.messageCount.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.threadName.frame = CGRect(x: 16, y: 13, width: self.contentView.frame.width-30-30, height: 20)
        self.messageCount.frame = CGRect(x: self.contentView.frame.width-44, y: 13, width: 30, height: 16)
        self.latestMessage.frame = CGRect(x: 16, y: self.threadName.frame.maxY+2, width: self.contentView.frame.width-32, height: 18)
        self.separatorLine.frame = CGRect(x: 16, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-16, height: 0.5)
    
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    open func refresh(chatThread: EaseChatThread) {
        self.threadName.text = chatThread.thread.threadName
        self.messageCount.setTitle("\(chatThread.thread.messageCount)", for: .normal)
        self.messageCount.isHidden = chatThread.thread.messageCount <= 0 
        self.latestMessage.attributedText = self.renderMessageContent(message: chatThread.lastMessage)
    }
    
    open func renderMessageContent(message: ChatMessage?) -> NSAttributedString {
        if let topicMessage = message {
            var text = NSMutableAttributedString()
            let nickname = topicMessage.user?.nickname ?? topicMessage.from
            if topicMessage.body.type != .text {
                text.append(NSAttributedString {
                    AttributedText(nickname+":"+topicMessage.showType).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.labelSmall)
                })
                return text
            } else {
                var result = nickname+":"+topicMessage.showType
                for (key,value) in ChatEmojiConvertor.shared.oldEmojis {
                    result = result.replacingOccurrences(of: key, with: value)
                }
                text.append(NSAttributedString {
                    AttributedText(result).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.labelSmall)
                })
                let string = text.string as NSString
                for symbol in ChatEmojiConvertor.shared.emojis {
                    if string.range(of: symbol).location != NSNotFound {
                        let ranges = text.string.chat.rangesOfString(symbol)
                        text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol,imageBounds: CGRect(x: 0, y: -2, width: 14, height: 14))
                        text.addAttribute(.font, value: UIFont.theme.labelSmall, range: NSMakeRange(0, text.length))
                        text.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSMakeRange(0, text.length))
                    }
                }
            }
            return text
        } else {
            return NSAttributedString {
                AttributedText("No Messages".chat.localize).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyMedium)
            }
        }
    }
}


extension ChatThreadCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.moreImage = UIImage(named: "thread_more", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
        self.messageCount.setTitleColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, for: .normal)
        self.messageCount.setImage(self.moreImage, for: .normal)
        self.threadName.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
}
