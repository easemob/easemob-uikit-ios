import UIKit
import Combine

/// Tag used for identifying the avatar view in the message cell.
public let avatarTag = 900

/// Tag used for identifying the reply view in the message cell.
public let replyTag = 199

/// Tag used for identifying the bubble view in the message cell.
public let bubbleTag = 200

public let topicTag = 201

public let reactionTag = 202

/// Tag used for identifying the status view in the message cell.
public let statusTag = 168

public let checkBoxTag = 189

/// Enum representing the style of a message cell.
@objc public enum MessageCellStyle: UInt {
    case text
    case image
    case video
    case location
    case voice
    case file
    case cmd
    case contact
    case alert
    case combine
}

/// Enum representing the different areas that can be clicked in a message cell.
@objc public enum MessageCellClickArea: UInt {
    case avatar
    case reply
    case bubble
    case topic
    case reaction
    case status
    case checkbox
    case cell
}

@objc public enum MessageContentDisplayStyle: UInt {
    case withReply = 1
    case withAvatar = 2
    case withNickName = 4
    case withDateAndTime = 8
    case withMessageThread = 16
    case withMessageReaction = 32
}
    
@objc public enum MessageBubbleDisplayStyle: UInt {
    case withArrow
    case withMultiCorner
}

/// The amount of space between the message bubble and the cell.
let message_bubble_space = CGFloat(1)

@objcMembers open class MessageCell: UITableViewCell {
    
    private var longGestureEnabled: Bool = true
    
    public var entity = ComponentsRegister.shared.MessageRenderEntity.init()
    
    public private(set) var towards = BubbleTowards.left
    
    public var editMode = false
    
    public var clickAction: ((MessageCellClickArea,MessageEntity) -> Void)?
    
    public var reactionClicked: ((MessageReaction,MessageEntity) -> Void)?
    
    public var longPressAction: ((MessageCellClickArea,MessageEntity,MessageCell) -> Void)?
    
    public private(set) lazy var checkbox: UIImageView = {
        self.createCheckbox()
    }()
    
    @objc open func createCheckbox() -> UIImageView {
        UIImageView(frame: CGRect(x: 12, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).contentMode(.scaleAspectFit).backgroundColor(.clear).tag(checkBoxTag)
    }
    
    public private(set) lazy var avatar: ImageView = {
        self.createAvatar()
    }()
    
    /**
     Creates an avatar image view.
     
     - Returns: An instance of `ImageView` configured with the necessary properties.
     */
    @objc open func createAvatar() -> ImageView {
        ImageView(frame: .zero).contentMode(.scaleAspectFill).backgroundColor(.clear).tag(avatarTag)
    }
    
    public private(set) lazy var nickName: UILabel = {
        self.createNickName()
    }()
    
    @objc open func createNickName() -> UILabel {
        UILabel(frame: .zero).backgroundColor(.clear).font(UIFont.theme.labelSmall)
    }
    
    public private(set) lazy var replyContent: MessageReplyView = {
        self.createReplyContent()
    }()
    
    @objc open func createReplyContent() -> MessageReplyView {
        MessageReplyView(frame: .zero).backgroundColor(.clear).tag(replyTag)
    }
    
    public private(set) lazy var bubbleWithArrow: MessageBubbleWithArrow = {
        self.createBubbleWithArrow()
    }()
    
    @objc open func createBubbleWithArrow() -> MessageBubbleWithArrow {
        MessageBubbleWithArrow(frame: .zero, forward: self.towards).tag(bubbleTag)
    }
    
    public private(set) lazy var bubbleMultiCorners: MessageBubbleMultiCorner = {
        self.createBubbleMultiCorners()
    }()
    
    @objc open func createBubbleMultiCorners() -> MessageBubbleMultiCorner {
        MessageBubbleMultiCorner(frame: .zero, forward: self.towards).tag(bubbleTag)
    }
    
    public private(set) lazy var status: UIImageView = {
        self.statusView()
    }()
    
    @objc open func statusView() -> UIImageView {
        UIImageView(frame: .zero).backgroundColor(.clear).tag(statusTag)
    }
    
    public private(set) lazy var messageDate: UILabel = {
        self.createMessageDate()
    }()
    
    @objc open func createMessageDate() -> UILabel {
        UILabel(frame: .zero).font(UIFont.theme.bodySmall).backgroundColor(.clear)
    }
    
    public private(set) lazy var topicView: MessageTopicView = {
        self.createTopicView()
    }()
    
    @objc open func createTopicView() -> MessageTopicView {
        MessageTopicView(frame: .zero).backgroundColor(.clear).cornerRadius(.extraSmall).tag(topicTag)
    }
    
    public private(set) lazy var reactionView: MessageReactionView = {
        self.createReactionView()
    }()
    
    @objc open func createReactionView() -> MessageReactionView {
        MessageReactionView(frame: .zero).backgroundColor(.clear).cornerRadius(.extraSmall).tag(reactionTag)
    }
    
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /// ``MessageCell`` required init method.
    /// - Parameters:
    ///   - towards: ``BubbleTowards`` is towards of the bubble.
    ///   - reuseIdentifier: Cell reuse identifier.
    @objc(initWithTowards:reuseIdentifier:)
    required public init(towards: BubbleTowards,reuseIdentifier: String) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.towards = towards
        self.contentView.addSubview(self.checkbox)
        self.addGestureTo(view: self.checkbox, target: self)
        if Appearance.chat.contentStyle.contains(.withNickName) {
            self.contentView.addSubview(self.nickName)
        }
        if Appearance.chat.contentStyle.contains(.withReply) {
            self.contentView.addSubview(self.replyContent)
            self.addGestureTo(view: self.replyContent, target: self)
        }
        if Appearance.chat.contentStyle.contains(.withAvatar) {
            self.contentView.addSubview(self.avatar)
            self.addGestureTo(view: self.avatar, target: self)
            self.longPressGestureTo(view: self.bubbleWithArrow, target: self)
        }
        if Appearance.chat.bubbleStyle == .withArrow {
            self.contentView.addSubview(self.bubbleWithArrow)
            self.longPressGestureTo(view: self.bubbleWithArrow, target: self)
        } else {
            self.contentView.addSubview(self.bubbleMultiCorners)
            self.longPressGestureTo(view: self.bubbleMultiCorners, target: self)
        }
        if Appearance.chat.contentStyle.contains(.withMessageThread) {
            self.contentView.addSubview(self.topicView)
            self.addGestureTo(view: self.topicView, target: self)
        }
        if Appearance.chat.contentStyle.contains(.withMessageReaction) {
            self.contentView.addSubview(self.reactionView)
            self.reactionView.reactionClosure = { [weak self] in
                guard let `self` = self else { return }
                if $0 == nil {
                    self.clickAction?(.reaction,self.entity)
                } else {
                    self.reactionClicked?($0!,self.entity)
                }
            }
        }
        if Appearance.chat.contentStyle.contains(.withDateAndTime) {
            self.contentView.addSubview(self.messageDate)
        }
        self.contentView.addSubview(self.status)
        self.addGestureTo(view: self.status, target: self)
        Theme.registerSwitchThemeViews(view: self)
        self.replyContent.isHidden = true
        self.switchTheme(style: Theme.style)
    }
    
    @objc public func addGestureTo(view: UIView,target: Any?) {
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: target, action: #selector(clickAction(gesture:))))
    }
    
    @objc public func longPressGestureTo(view: UIView,target: Any?) {
        view.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: target, action: #selector(longPressAction(gesture:)))
        view.addGestureRecognizer(longPress)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first {
            if self.editMode {
                self.clickAction?(.cell,self.entity)
            }
        }
    }
    
    @objc open func clickAction(gesture: UITapGestureRecognizer) {
        if let tag = gesture.view?.tag {
            switch tag {
            case statusTag:
                self.clickAction?(.status,self.entity)
            case replyTag:
                self.clickAction?(.reply,self.entity)
            case bubbleTag:
                self.clickAction?(.bubble,self.entity)
            case avatarTag:
                self.clickAction?(.avatar,self.entity)
            case topicTag:
                self.clickAction?(.topic,self.entity)
            case checkBoxTag:
                self.clickAction?(.checkbox,self.entity)
            default:
                self.clickAction?(.cell,self.entity)
                break
            }
        }
    }
    
    @objc open func longPressAction(gesture: UILongPressGestureRecognizer) {
        if let tag = gesture.view?.tag {
            switch gesture.state {
            case .began:
                switch tag {
                case bubbleTag:
                    self.longPressAction?(.bubble,self.entity,self)
                case avatarTag:
                    self.longPressAction?(.avatar,self.entity,self)
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    private func addRotation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = 999
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        
        self.status.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
        
    /// Refresh cell with ``MessageEntity``
    /// - Parameter entity: ``MessageEntity``
    @objc(refreshWithEntity:)
    open func refresh(entity: MessageEntity) {
        self.towards = entity.message.direction == .send ? .right:.left
        self.entity = entity
        self.updateAxis(entity: entity)
        
        if !self.checkbox.isHidden {
            self.checkbox.image = UIImage(named: entity.selected ? "select":"unselect", in: .chatBundle, with: nil)
        }
        if entity.message.direction == .send {
            self.nickName.isHidden = true
        } else {
            if entity.message.chatType == .groupChat {
                //remark > nickname > userId
                self.nickName.text = entity.showUserName
                self.nickName.isHidden = false
            } else {
                self.nickName.isHidden = true
            }
        }
        //reply
        self.replyContent.isHidden = entity.replyContent == nil
        self.replyContent.isHidden = entity.replySize.height <= 0
        if entity.replySize.height > 0 {
            self.replyContent.refresh(entity: entity)
        }
        //avatar
        self.avatar.cornerRadius(Appearance.avatarRadius)
        self.avatar.image = Appearance.avatarPlaceHolder
        if let user = entity.message.user {
            if !user.avatarURL.isEmpty {
                self.avatar.image(with: user.avatarURL, placeHolder: Appearance.avatarPlaceHolder)
            } else {
                self.avatar.image = Appearance.avatarPlaceHolder
            }
        }
        //message status
        self.status.image = entity.stateImage
        if entity.state == .sending {
            self.addRotation()
        } else {
            self.status.layer.removeAllAnimations()
        }
        
        //topic
        self.topicView.refresh(entity: entity)
        self.topicView.isHidden = entity.message.chatThread == nil
        
        //reaction
        self.reactionView.refresh(entity: entity)
        self.reactionView.isHidden = (entity.message.reactionList?.count ?? 0 <= 0)
        
        //date
        let date = entity.message.showDetailDate
        self.messageDate.text = date
        
    }
    
    
    /// Update cell subviews axis with ``MessageEntity``
    /// - Parameter entity: ``MessageEntity``
    @objc(updateAxisWithEntity:)
    open func updateAxis(entity: MessageEntity) {
        self.topicView.isHidden = entity.message.chatThread == nil
        let reactions = entity.message.reactionList?.count ?? 0
        let reactionContentHeight = entity.reactionContentHeight()
        let reactionWidth = entity.reactionMenuWidth()
        self.reactionView.isHidden = reactions <= 0
        self.checkbox.isHidden = !self.editMode
        if entity.message.direction == .receive {
            if self.editMode {
                self.checkbox.frame = CGRect(x: 12, y: entity.height - 14 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 28 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: 28, height: 28)
            }
            self.avatar.frame = CGRect(x: self.editMode ? self.checkbox.frame.maxX+12:12, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 34 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: 28, height: 28)
            self.nickName.frame = CGRect(x:  Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:(self.editMode ? self.checkbox.frame.maxX+12:12), y: 10, width: limitBubbleWidth, height: 16)
            self.messageDate.textAlignment = .left
            self.nickName.textAlignment = .left
            if Appearance.chat.contentStyle.contains(.withReply) {
                self.replyContent.frame = CGRect(x:  Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:(self.editMode ? self.checkbox.frame.maxX+12:12), y: Appearance.chat.contentStyle.contains(where: { $0 == .withNickName }) ? self.nickName.frame.maxY-1:12, width: entity.replySize.width, height: entity.replySize.height)
            }
            self.bubbleWithArrow.towards = self.towards
            self.bubbleMultiCorners.towards = self.towards
            if Appearance.chat.bubbleStyle == .withArrow {
                self.bubbleWithArrow.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+8:(self.editMode ? self.checkbox.frame.maxX+8:8), y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: entity.bubbleSize.width+5, height: entity.bubbleSize.height+message_bubble_space*2)
            } else {
                self.bubbleMultiCorners.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+8:(self.editMode ? self.checkbox.frame.maxX+8:8), y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleMultiCorners.updateBubbleCorner()
            }
            self.status.isHidden = true
            self.status.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? (self.avatar.frame.maxX+entity.bubbleSize.width+4):((self.editMode ? self.checkbox.frame.maxX+12:12)+entity.bubbleSize.width+4), y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 20 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0), width: 20, height: 20)
            if Appearance.chat.contentStyle.contains(.withMessageThread) {
                self.topicView.frame = CGRect(x: (Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minX:self.bubbleMultiCorners.frame.minX), y: (Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.maxY:self.bubbleMultiCorners.frame.maxY)+2, width: limitBubbleWidth, height: topicHeight-2)
            }
            if Appearance.chat.contentStyle.contains(.withMessageReaction) {
                self.reactionView.frame = CGRect(x: Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.minX:self.bubbleMultiCorners.frame.minX, y: entity.height-(Appearance.chat.contentStyle.contains(.withDateAndTime) ? 24:2)-(Appearance.chat.contentStyle.contains(.withMessageReaction) ? reactionContentHeight:2), width: reactionWidth+30, height: reactionContentHeight)
            }
            self.messageDate.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.maxX+12:(self.editMode ? self.checkbox.frame.maxX+12:12), y: entity.height-24, width: 120, height: 16)
        } else {
            self.status.isHidden = false
            if self.editMode {
                self.checkbox.frame = CGRect(x: 12, y: entity.height - 14 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 28 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: 28, height: 28)
            }
            self.avatar.frame = CGRect(x: ScreenWidth-40, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 34 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: 28, height: 28)
            self.nickName.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-limitBubbleWidth-12:ScreenWidth-limitBubbleWidth-12, y: 10, width: limitBubbleWidth, height: 16)
            self.messageDate.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? (self.avatar.frame.minX-12-120):(ScreenWidth-132), y: entity.height-16, width: 120, height: 16)
            self.messageDate.textAlignment = .right
            self.nickName.textAlignment = .right
            if Appearance.chat.contentStyle.contains(.withReply) {
                self.replyContent.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.replySize.width-12:ScreenWidth-12-entity.replySize.width, y: Appearance.chat.contentStyle.contains(where: { $0 == .withNickName }) ? self.nickName.frame.maxY-1:12, width: entity.replySize.width, height: entity.replySize.height)
            }
            self.bubbleWithArrow.towards = (entity.message.direction == .receive ? .left:.right)
            self.bubbleMultiCorners.towards = (entity.message.direction == .receive ? .left:.right)
            if Appearance.chat.bubbleStyle == .withArrow {
                self.bubbleWithArrow.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-8:ScreenWidth-entity.bubbleSize.width-8, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
            } else {
                self.bubbleMultiCorners.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-8:ScreenWidth-entity.bubbleSize.width-8, y: entity.height - 16 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - entity.bubbleSize.height - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0), width: entity.bubbleSize.width, height: entity.bubbleSize.height+message_bubble_space*2)
                self.bubbleMultiCorners.towards = entity.message.direction == .send ? .right:.left
                self.bubbleMultiCorners.updateBubbleCorner()
            }

            self.status.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? self.avatar.frame.minX-entity.bubbleSize.width-12-20-4:ScreenWidth-entity.bubbleSize.width-12-20-4, y: entity.height - 8 - (Appearance.chat.contentStyle.contains(where: { $0 == .withDateAndTime }) ? 16:2) - 22 - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageReaction }) ? reactionContentHeight:0) - (Appearance.chat.contentStyle.contains(where: { $0 == .withMessageThread }) ? (self.topicView.isHidden ? 0:topicHeight):0), width: 20, height: 20)
            self.replyContent.cornerRadius(Appearance.chat.imageMessageCorner)
            if Appearance.chat.contentStyle.contains(.withMessageThread) {
                self.topicView.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? (self.avatar.frame.minX-limitBubbleWidth):(ScreenWidth-limitBubbleWidth-12), y: (Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.maxY:self.bubbleMultiCorners.frame.maxY)+2, width: limitImageWidth, height: topicHeight)
            }
            if Appearance.chat.contentStyle.contains(.withMessageReaction) {
                self.reactionView.frame = CGRect(x: (Appearance.chat.bubbleStyle == .withArrow ? self.bubbleWithArrow.frame.maxX:self.bubbleMultiCorners.frame.maxX)-reactionWidth-30, y: entity.height-(Appearance.chat.contentStyle.contains(.withDateAndTime) ? 24:2)-(Appearance.chat.contentStyle.contains(.withMessageReaction) ? reactionContentHeight:2), width: reactionWidth+30, height: reactionContentHeight)
            }
            self.messageDate.frame = CGRect(x: Appearance.chat.contentStyle.contains(where: { $0 == .withAvatar }) ? (self.avatar.frame.minX-12-120):(ScreenWidth-132), y: entity.height-24, width: 120, height: 16)
            
        }
    }
    
    
    @objc func updateMessageStatus(entity: MessageEntity) {
        self.status.image = entity.stateImage
        if entity.state != .sending {
            self.status.layer.removeAllAnimations()
            self.status.stopAnimating()
        } else {
            self.addRotation()
        }
    }
    
    open func renderCheck(entity: MessageEntity) {
        self.checkbox.isHidden = !self.editMode
        
        if !self.checkbox.isHidden {
            self.checkbox.image = UIImage(named: entity.selected ? "select":"unselect", in: .chatBundle, with: nil)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


/**
 An extension of `MessageCell` that conforms to the `ThemeSwitchProtocol`.
 It provides a method to switch the theme of the cell.
 */
extension MessageCell: ThemeSwitchProtocol {
    /**
     Switches the theme of the cell.
     
     - Parameter style: The style of the theme to switch to.
     */
    open func switchTheme(style: ThemeStyle) {
        self.replyContent.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.nickName.textColor = style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5
        self.messageDate.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor7
        self.topicView.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
    }
}


public extension MessageCell {
    
    func contentViewIfPresent() -> UIView? {
        if let content = self.value(forKey: "content") as? UIView {
            return content
        }
        return nil
    }
}
