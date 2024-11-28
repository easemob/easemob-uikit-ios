
import UIKit

@objc open class ConversationListCell: UITableViewCell {

    public private(set) lazy var avatar: ImageView = {
        self.createAvatar()
    }()
    
    @objc open func createAvatar() -> ImageView {
        ImageView(frame: CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)).contentMode(.scaleAspectFill)
    }
    
    public private(set) lazy var nickName: UIButton = {
        self.createNickName()
    }()
    
    @objc open func createNickName() -> UIButton {
        UIButton(type: .custom).frame(CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)).isUserInteractionEnabled(false).backgroundColor(.clear)
    }
    
    public private(set) lazy var date: UILabel = {
        self.createDate()
    }()
    
    @objc open func createDate() -> UILabel {
        UILabel(frame: CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor5).backgroundColor(.clear).textAlignment(.right)
    }
    
    public private(set) lazy var content: UILabel = {
        self.createContent()
    }()
    
    @objc open func createContent() -> UILabel {
        UILabel(frame: CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 20)).backgroundColor(.clear)
    }
    
    public private(set) lazy var badge: UILabel = {
        self.createBadge()
    }()
    
    @objc open func createBadge() -> UILabel {
        UILabel(frame: CGRect(x: self.contentView.frame.width-48, y: self.nickName.frame.maxY+5, width: 32, height: 18)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryLightColor).textColor(UIColor.theme.neutralColor98).font(UIFont.theme.labelSmall).textAlignment(.center)
    }
    
    public private(set) lazy var dot: UIView = {
        self.createDot()
    }()
    
    @objc open func createDot() -> UIView {
        UIView(frame: CGRect(x: self.contentView.frame.width-28, y: self.nickName.frame.maxY+10, width: 8, height: 8)).cornerRadius(.large).backgroundColor(UIColor.theme.primaryLightColor)
    }
    
    public private(set) lazy var separatorLine: UIView = {
        self.createSeparatorLine()
    }()
    
    @objc open func createSeparatorLine() -> UIView {
        UIView(frame: CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5))
    }
    
    @objc required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.avatar,self.nickName,self.date,self.content,self.badge,self.dot,self.separatorLine])
        self.nickName.contentHorizontalAlignment = .left
        self.nickName.semanticContentAttribute = .forceLeftToRight
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.avatar.frame = CGRect(x: 16, y: (self.contentView.frame.height-50)/2.0, width: 50, height: 50)
        self.nickName.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.avatar.frame.minX+4, width: self.contentView.frame.width-self.avatar.frame.maxX-12-16-50, height: 16)
        self.date.frame = CGRect(x: self.contentView.frame.width-66, y: self.nickName.frame.minY+2, width: 50, height: 16)
        self.content.frame = CGRect(x: self.avatar.frame.maxX+12, y: self.nickName.frame.maxY+2, width: self.contentView.frame.width-12-12-16-80, height: 20)
        var badgeWidth: CGFloat = 18
        if let badgeText = self.badge.text {
            if badgeText.count > 2 {
                badgeWidth = 32
            } else if badgeText.count > 1 {
                badgeWidth = 24
            }
        }
        self.badge.frame = CGRect(x: self.contentView.frame.width - badgeWidth - 16,
                                  y: self.nickName.frame.maxY + 5,
                                  width: badgeWidth,
                                  height: 18)
        self.dot.frame =  CGRect(x: self.date.frame.maxX-12, y: self.nickName.frame.maxY+10, width: 8, height: 8)
        self.separatorLine.frame =  CGRect(x: self.nickName.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.nickName.frame.minX, height: 0.5)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc(refreshWithInfo:)
    open func refresh(info: ConversationInfo) {
        var contentColor = UIColor.clear
        if info.pinned {
            contentColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        }
        self.contentView.backgroundColor =  contentColor
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.avatar.image(with: info.avatarURL, placeHolder: info.type == .chat ? Appearance.conversation.singlePlaceHolder:Appearance.conversation.groupPlaceHolder)
        var nickName = info.id
        if !info.nickname.isEmpty {
            nickName = info.nickname
        }
        if !info.remark.isEmpty {
            nickName = info.remark
        }
        let nameAttribute = NSMutableAttributedString {
            AttributedText(nickName).font(UIFont.theme.titleMedium).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
            
        }
        let image = UIImage(named: "bell_slash", in: .chatBundle, with: nil)
        if Theme.style == .dark {
            image?.withTintColor(UIColor.theme.neutralColor5)
        }
        if info.doNotDisturb {
            nameAttribute.append(NSAttributedString {
                ImageAttachment(image, bounds: CGRect(x: 0, y: -4, width: 18, height: 18))
            })
        }
        self.nickName.setAttributedTitle(nameAttribute, for: .normal)
        self.content.attributedText = info.showContent
        self.date.text = info.lastMessage?.showDate ?? Date().chat.dateString(Appearance.conversation.dateFormatToday)
        self.badge.text = info.unreadCount > 99 ? "99+":"\(info.unreadCount)"
        if info.doNotDisturb {
            self.badge.isHidden = true
            self.dot.isHidden = info.unreadCount <= 0
        } else {
            self.badge.isHidden = info.unreadCount <= 0
            self.dot.isHidden = true
        }
        self.setNeedsLayout()
    }
    
   
}

extension ConversationListCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.nickName.setTitleColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1, for: .normal)
//        self.content.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.date.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.badge.backgroundColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.dot.backgroundColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
    
    
}

@objcMembers open class ConversationInfo:NSObject, ChatUserProfileProtocol {
    open func toJsonObject() -> Dictionary<String, Any>? {
        [:]
    }
    
    public var remark: String = ""
    
    public var selected: Bool = false
    
    public var type: ChatUserProfileProviderType = .chat
    
    public var id: String = ""
    
    public var avatarURL: String = ""
    
    public var nickname: String = ""
    
    public var lastMessage: ChatMessage? = ChatMessage()
    
    public var unreadCount: UInt = 0
    
    public var doNotDisturb = false
    
    public var pinned = false
    
    public var mentioned: Bool {
        get {
            let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.id)
            if conversation?.ext == nil {
                let mention = !(conversation?.lastReceivedMessage()?.mention ?? "").isEmpty
                conversation?.ext = ["EaseChatUIKit_mention":mention]
                return mention
            }
            return (conversation?.ext["EaseChatUIKit_mention"] as? Bool) ?? false
        }
        set {
            let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(self.id)
            var ext = conversation?.ext ?? [:]
            if ext.isEmpty {
                ext["EaseChatUIKit_mention"] = newValue
                conversation?.ext = ext
            } else {
                conversation?.ext["EaseChatUIKit_mention"] = newValue
            }
        }
    }
    
    public lazy var showContent: NSAttributedString = {
        self.contentAttribute()
    }()
    
    @objc open func contentAttribute() -> NSAttributedString {
        guard let message = self.lastMessage else { return NSAttributedString() }
        var text = NSMutableAttributedString()
        if let dic = message.ext?["ease_chat_uikit_user_info"] as? Dictionary<String,Any> {
            let profile = ChatUserProfile()
            profile.setValuesForKeys(dic)
            profile.id = message.from
            profile.modifyTime = message.timestamp
            ChatUIKitContext.shared?.chatCache?[message.from] = profile
            if ChatUIKitContext.shared?.userCache?[message.from] == nil {
                ChatUIKitContext.shared?.userCache?[message.from] = profile
            } else {
                ChatUIKitContext.shared?.userCache?[message.from]?.nickname = profile.nickname
                ChatUIKitContext.shared?.userCache?[message.from]?.avatarURL = profile.avatarURL
            }
        }
        
        let from = message.from
        let mentionText = "Mentioned".chat.localize
        var user = ChatUIKitContext.shared?.userCache?[from]
        var nickName = user?.remark ?? ""
        if nickName.isEmpty {
            nickName = user?.nickname ?? ""
        }
        if nickName.isEmpty {
            nickName = from
        }
        if message.body.type == .text {
            var result = message.showType
            for (key,value) in ChatEmojiConvertor.shared.oldEmojis {
                result = result.replacingOccurrences(of: key, with: value)
            }
            text.append(NSAttributedString {
                AttributedText(result).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyLarge)
            })
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chat.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol,imageBounds: CGRect(x: 0, y: -3, width: 16, height: 16))
                    text.addAttribute(.font, value: UIFont.theme.bodyLarge, range: NSMakeRange(0, text.length))
                    text.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSMakeRange(0, text.length))
                }
            }
            if self.mentioned {
                let showText = NSMutableAttributedString {
                    AttributedText("[\(mentionText)] ").foregroundColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor).font(Font.theme.bodyMedium)
                    AttributedText(nickName + ": ").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
                }
                
                let show = NSMutableAttributedString(attributedString: text)
                show.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSRange(location: 0, length: show.length))
                show.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: show.length))
                showText.append(show)
                return showText
            } else {
                let showText = NSMutableAttributedString {
                    AttributedText(message.chatType != .chat ? nickName + ": ":"").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(Font.theme.bodyMedium)
                }
                showText.append(text)
                showText.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor6, range: NSRange(location: 0, length: showText.length))
                showText.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: showText.length))
                return showText
            }
        } else {
            let showText = NSMutableAttributedString {
                AttributedText((message.chatType == .chat ? message.showType:(nickName+":"+message.showType))).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyMedium)
            }
            return showText
        }
    }
    
    open func convertMessage(message: ChatMessage) -> MessageEntity {
        let entity = ComponentsRegister.shared.MessageRenderEntity.init()
        entity.state = self.convertStatus(message: message)
        entity.message = message
        _ = entity.showTranslation
        _ = entity.content
        _ = entity.replyTitle
        _ = entity.replyContent
        _ = entity.bubbleSize
        _ = entity.height
        _ = entity.replySize
        return entity
    }
    
    open func convertStatus(message: ChatMessage) -> ChatMessageStatus {
        switch message.status {
        case .succeed:
            return .succeed
        case .pending:
            return .sending
        case .delivering:
            return .delivered
        default:
            if message.isReadAcked {
                return .read
            }
            return .failure
        }
    }
    
    required public override init() {
        
    }
    
}
