import UIKit

public let MessageInputBarHeight = CGFloat(52)

@objc public enum MoreMessagePosition: UInt {
    case left
    case center
    case right
}

@objc public enum MessageOperation: UInt {
    case pin
    case copy
    case edit
    case reply
    case delete
    case recall
    case translate
    case originalText
    case forward
    case multiSelect
    case createTopic
}

@objc public protocol MessageListViewActionEventsDelegate: NSObjectProtocol {
    
    /// The method will call on message list pull to refreshing.
    func onMessageListPullRefresh()
    
    func onMessageListLoadMore()
    
    /// The method will call on message reply content clicked.
    /// - Parameter message: ``ChatMessage``
    func onMessageReplyClicked(message: MessageEntity)
    
    /// The method will call on message content clicked.
    /// - Parameter message: ``MessageEntity``
    func onMessageContentClicked(message: MessageEntity)
    
    /// The method will call on message content long pressed.
    /// - Parameter message: ``MessageCell``
    func onMessageContentLongPressed(cell: MessageCell)
    
    /// The method will call on message avatar clicked
    /// - Parameter profile: ``ChatUserProfileProtocol``
    func onMessageAvatarClicked(profile: ChatUserProfileProtocol)
    
    /// The method will call on message avatar long pressed.
    /// - Parameter profile: ``ChatUserProfileProtocol``
    func onMessageAvatarLongPressed(profile: ChatUserProfileProtocol)
    
    /// The method will call on input box event occur.
    /// - Parameter type: ``MessageInputBarActionType``
    /// - Parameter type: NSAttributedString of textfield.
    func onInputBoxEventsOccur(action type: MessageInputBarActionType,attributeText: NSAttributedString?)
    
    /// The method will call on failure message status view clicked.
    /// - Parameter entity: ``MessageEntity``
    func onFailureMessageRetrySend(entity: MessageEntity)
    
    /// Message visible on scroll in screen
    /// - Parameter entity: ``MessageEntity``
    func onMessageVisible(entity: MessageEntity)
    
    /// Message topic view clicked.
    /// - Parameter entity: ``MessageEntity``
    func onMessageTopicClicked(entity: MessageEntity)
    
    /// Message reaction&`...` clicked.
    /// - Parameters:
    ///   - reaction: ``MessageReaction`` object,if nil is `...` clicked.
    ///   - entity: ``MessageEntity``
    func onMessageReactionClicked(reaction: MessageReaction?,entity: MessageEntity)
    
    /// When message multi select bar clicked.
    /// - Parameters:
    ///   - operation: ``MessageMultiSelectedBottomBarOperation``
    func onMessageMultiSelectBarClicked(operation: MessageMultiSelectedBottomBarOperation)
    
    /// More messages button clicked.
    func onMoreMessagesClicked()
    
    
}

@objc public protocol IMessageListViewDriver: NSObjectProtocol {
    
    /// Latest message id.
    var firstMessageId: String {get}
    
    /// Reply message id.
    var replyMessageId: String {get}
    
    var dataSource: [ChatMessage] {get}
    
    /// Whether scroll view is scrolled to bottom.
    var scrolledBottom: Bool {get}
    
    /// Add action events listener of ``MessageListView``.
    /// - Parameter actionHandler: The object of conform ``MessageListViewActionEventsDelegate``.
    func addActionHandler(actionHandler: MessageListViewActionEventsDelegate)
    
    /// Remove action events listener of ``MessageListView``.
    /// - Parameter actionHandler: The object of conform ``MessageListViewActionEventsDelegate``.
    func removeEventHandler(actionHandler: MessageListViewActionEventsDelegate)
    
    /// Message list on first load show db messages .
    /// - Parameter messages: ``[ChatMessage]``
    func refreshMessages(messages: [ChatMessage])
    
    /// Message list pull to load more db messages.
    /// - Parameter messages: ``ChatMessage``
    func insertMessages(messages: [ChatMessage])
    
    /// Process messages according to operation type.
    /// - Parameter operation: ``MessageOperation``
    /// - Parameter message: ``ChatMessage``
    func processMessage(operation: MessageOperation,message: ChatMessage)
    
    /// Display new message.
    /// - Parameter message: ``ChatMessage``
    func showMessage(message: ChatMessage)
    
    /// Update message.
    /// - Parameter message: ``ChatMessage``
    /// - Parameter status: ``ChatMessageStatus``
    func updateMessageStatus(message: ChatMessage,status: ChatMessageStatus)
    
    /// Update status on message attachment state changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    func updateMessageAttachmentStatus(message: ChatMessage)
    
    ///  Add mention user to textfield on needed.
    /// - Parameter user: ``NSAttributedString``
    func addMentionUserToField(user: ChatUserProfileProtocol)
    
    /// Update audio message  on play status changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - play: play or stop
    func updateAudioMessageStatus(message: ChatMessage,play: Bool)
        
    /// Chat thread of the group message on changed.
    /// - Parameter entity: ``ChatMessage``
    func updateGroupMessageChatThreadChanged(message: ChatMessage)
    
    /// Reload topic content
    /// - Parameter message: ``ChatMessage``
    func reloadTopic(message: ChatMessage)
    
    /// Reload reaction content.
    /// - Parameter message: ``ChatMessage``
    func reloadReaction(message: ChatMessage)
    
    /// Update state on chat thread load messages finished.
    /// - Parameter finished: Bool
    func updateThreadLoadMessagesFinished(finished: Bool)
    
    /// Update state on chat thread load messages finished.
    func endRefreshing()
    
    /// Stop audio messages play.
    func stopAudioMessagesPlay()
    
    /// Update message on message list.
    func readAllMessages()
    
    /// Highlight message on message list.
    /// - Parameter message: ``ChatMessage``
    func highlightMessage(message: ChatMessage)
}

@objc public enum MessageListType: UInt8 {
    case normal
    case history
    case thread
}

@objc open class MessageListView: UIView {
        
    private var eventHandlers: NSHashTable<MessageListViewActionEventsDelegate> = NSHashTable<MessageListViewActionEventsDelegate>.weakObjects()
    
    /// Add UI actions handler.
    /// - Parameter actionHandler: ``MessageListViewActionEventsDelegate``
    public func addActionHandler(actionHandler: MessageListViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }
    
    /// Remove UI action handler.
    /// - Parameter actionHandler: ``MessageListViewActionEventsDelegate``
    public func removeEventHandler(actionHandler: MessageListViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }
    
    public private(set) var messages: [MessageEntity] = []
    
    public private(set) var canMention = false
    
    open override var frame: CGRect {
        didSet {
            self.oldFrame = self.frame
            self.messageList.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-BottomBarHeight-MessageInputBarHeight)
            self.inputBar.resetFrame(newFrame: CGRect(x: 0, y: self.frame.height-MessageInputBarHeight-BottomBarHeight, width: self.frame.width, height: MessageInputBarHeight))
            self.editBottomBar.frame = CGRect(x: 0, y: self.frame.height-MessageInputBarHeight-BottomBarHeight, width: self.frame.width, height: 52)
            self.replyBar.frame = CGRect(x: 0, y: self.inputBar.frame.minY-MessageInputBarHeight, width: self.frame.width, height: 53)
        }
    }
    
    public var editMode = false {
        didSet {
            DispatchQueue.main.async {
                self.editBottomBar.isHidden = !self.editMode
                if self.editMode {
                    self.bringSubviewToFront(self.editBottomBar)
                } else {
                    self.sendSubviewToBack(self.editBottomBar)
                }
                self.messageList.reloadData()
            }
        }
    }
    
    private var replyId = ""
    
    private var CellTypes: [MessageCell.Type] = []
    
    public private(set) lazy var messageList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-BottomBarHeight-MessageInputBarHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none).backgroundColor(.clear).tag(111)
    }()
    
    private var oldFrame = CGRect.zero
        
    public private(set) lazy var inputBar: MessageInputBar = {
        MessageInputBar(frame: CGRect(x: 0, y: self.frame.height-MessageInputBarHeight-BottomBarHeight, width: self.frame.width, height: MessageInputBarHeight), text: "", placeHolder: Appearance.chat.inputPlaceHolder)
    }()
    
    public private(set) lazy var editBottomBar: MessageMultiSelectedBottomBar = {
        MessageMultiSelectedBottomBar(frame: CGRect(x: 0, y: self.frame.height-MessageInputBarHeight-BottomBarHeight, width: self.frame.width, height: 52))
    }()
        
    public private(set) lazy var replyBar: MessageInputReplyView = {
        MessageInputReplyView(frame: CGRect(x: 0, y: self.inputBar.frame.minY-MessageInputBarHeight, width: self.frame.width, height: 53))
    }()
    
    private var moreMessagesCount = 0  {
        willSet {
            DispatchQueue.main.async {
                self.moreMessages.isHidden = newValue <= 0
                if self.replyBar.isHidden  {
                    self.moreMessages.frame = CGRect(x: self.moreMessageAxisX, y: self.inputBar.frame.minY-44, width: 180, height: 36)
                } else {
                    self.moreMessages.frame = CGRect(x: self.moreMessageAxisX, y: self.replyBar.frame.minY-44, width: 180, height: 36)
                }
            }
            
        }
    }
    
    public private(set) lazy var moreMessages: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.moreMessageAxisX, y: self.inputBar.frame.minY-44, width: 180, height: 36)).font(UIFont.theme.labelMedium).title("    \(self.moreMessagesCount) "+"new messages".chat.localize, .normal).addTargetFor(self, action: #selector(scrollTableViewToBottom), for: .touchUpInside)
    }()
    
    public private(set) var showType = MessageListType.normal
    
    /// More messages button `X` position.
    private var moreMessageAxisX: CGFloat {
        switch Appearance.chat.moreMessageAlertPosition {
        case .left:
            return 12
        case .center:
            return (self.frame.width-180)/2.0
        case .right:
            return self.frame.width-192
        }
    }
    
    public private(set) var threadMessagesLoadFinished = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Init method
    /// - Parameters:
    ///   - frame: ``CGRect``
    ///   - mention: Whether to enable the mention function of UI.
    ///   - historyResult: Whether to enable the history result.
    @objc required public init(frame: CGRect,mention: Bool,showType: MessageListType = .normal) {
        super.init(frame: frame)
        self.CellTypes.append(contentsOf: ComponentsRegister.shared.customCellClasses)
        self.oldFrame = frame
        self.canMention = mention
        self.showType = showType
        self.messageList.keyboardDismissMode = .onDrag
        self.messageList.allowsSelection = false
        if Appearance.chat.contentStyle.contains(.withReply) {
            if showType != .history {
                self.addSubViews([self.messageList,self.inputBar,self.replyBar,self.moreMessages,self.editBottomBar])
            } else {
                self.addSubViews([self.messageList,self.inputBar,self.replyBar,self.editBottomBar])
            }
        } else {
            if showType != .history {
                self.addSubViews([self.messageList,self.inputBar,self.moreMessages,self.editBottomBar])
            } else {
                self.addSubViews([self.messageList,self.inputBar,self.editBottomBar])
            }
        }
        self.moreMessages.isHidden = true
        self.editBottomBar.isHidden = true
        self.messageList.refreshControl = UIRefreshControl()
        self.messageList.refreshControl?.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        self.replyBar.isHidden = true
        self.inputBarEvents()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        
        self.moreMessages.layer.masksToBounds = false
        let shadowPath0 = UIBezierPath(roundedRect: self.moreMessages.bounds, cornerRadius: 4)
        self.moreMessages.layer.shadowPath = shadowPath0.cgPath
        self.moreMessages.layer.shadowColor = UIColor(red: 0.275, green: 0.306, blue: 0.325, alpha: 0.15).cgColor
        self.moreMessages.layer.shadowOpacity = 1
        self.moreMessages.layer.shadowRadius = 8
        self.moreMessages.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.moreMessages.layer.cornerRadius = Appearance.avatarRadius == .large ? self.moreMessages.frame.height/2.0:CGFloat(Appearance.avatarRadius.rawValue)
        
        self.processInputBarAxisYChanged()
        
        self.processInputBarFirstResponder()
        
        self.editBottomBar.operationClosure = { [weak self] in
            self?.bottomMultiSelectedBarEvents(operation: $0)
        }
        if showType == .thread {
            self.editBottomBar.trash.isHidden = true
        }
        NotificationCenter.default.addObserver(forName: Notification.Name("EaseChatUIKit_clean_history_messages"), object: nil, queue: .main) { [weak self] notification in
            if let conversationId = notification.object as? String {
                if self?.messages.first?.message.conversationId ?? "" == conversationId {
                    self?.replyId = ""
                    self?.replyBar.isHidden = true
                    self?.messages.removeAll()
                    self?.messageList.reloadData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: cache_update_notification), object: nil, queue: .main) {  [weak self] notification in
            self?.messageList.reloadData()
        }
    }
    
    func getLastVisibleCellCoordinate() -> CGRect {
        guard let visibleIndexPaths = self.messageList.indexPathsForVisibleRows else { return .zero }
        if let lastIndexPath = visibleIndexPaths.last {
            let cellRect = self.messageList.rectForRow(at: lastIndexPath)
            let cellCoordinate = self.messageList.convert(cellRect.origin, to: self)
            return CGRect(origin: cellCoordinate, size: cellRect.size)
        }
        return .zero
    }
    
    private func processInputBarAxisYChanged() {
        self.inputBar.axisYChanged = { [weak self] value in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.replyBar.frame = CGRect(x: 0, y: self.inputBar.frame.minY-MessageInputBarHeight, width: self.frame.width, height: 53)
                    if self.replyBar.isHidden  {
                        self.moreMessages.frame = CGRect(x: self.moreMessageAxisX, y: self.inputBar.frame.minY-44, width: 180, height: 36)
                    } else {
                        self.moreMessages.frame = CGRect(x: self.moreMessageAxisX, y: self.replyBar.frame.minY-44, width: 180, height: 36)
                    }
                }
            }
        }
    }
    
    private func processInputBarFirstResponder() {
        self.inputBar.textViewFirstResponder = { [weak self] firstResponder in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.25) {
                let oldFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-BottomBarHeight-MessageInputBarHeight)
                self.messageList.frame = oldFrame
                let space = -(ScreenHeight <= 667 ? 28:0)-(self.inputBar.extensionMenus.isHidden ? 0:(self.inputBar.extensionMenus.frame.height <= 132 ? 20:-60))
                if firstResponder {
                    self.messageList.frame = CGRect(x: 0, y: 0, width: self.messageList.frame.width, height: self.frame.height-self.inputBar.keyboardHeight-16-BottomBarHeight-CGFloat(space))
                
                } else {
                    if self.inputBar.frame.height > MessageInputBarHeight {
                        self.messageList.frame = CGRect(x: 0, y: 0, width: self.messageList.frame.width, height: self.frame.height-self.inputBar.frame.height-BottomBarHeight)
                    } else {
                        self.messageList.frame = oldFrame
                    }
                }
                
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                if lastIndexPath.row >= 0 {
                    self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                }
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bottomMultiSelectedBarEvents(operation: MessageMultiSelectedBottomBarOperation) {
        for handler in self.eventHandlers.allObjects {
            handler.onMessageMultiSelectBarClicked(operation: operation)
        }
    }
    
    private func inputBarEvents() {
        self.inputBar.actionClosure = { [weak self] in
            self?.inputBarAction(type: $0, attributeText: $1)
        }
    }
    
    private func inputBarAction(type: MessageInputBarActionType, attributeText: NSAttributedString?) {
        switch type {
        case .attachment,.audio:
            self.replyId = ""
            self.replyBar.isHidden = true
            self.inputBar.hiddenInput()
        default:
            break
        }
        for handler in self.eventHandlers.allObjects {
            if type == .mention || type == .cancelMention {
                if self.canMention {
                    handler.onInputBoxEventsOccur(action: type, attributeText: attributeText)
                }
            } else {
                handler.onInputBoxEventsOccur(action: type, attributeText: attributeText)
            }
        }
    }
    
    @objc private func pullRefresh() {
        for handler in self.eventHandlers.allObjects {
            handler.onMessageListPullRefresh()
        }
    }
    
    @objc public func scrollTableViewToBottom() {
        if !self.threadMessagesLoadFinished,self.showType == .thread {
            return
        }
        self.inputBar.hiddenInput()
        if self.moreMessagesCount > 0 {
            self.moreMessagesCount = 0
            for handler in self.eventHandlers.allObjects {
                handler.onMoreMessagesClicked()
            }
        }
        if self.messages.count  > 1 {
            self.messageList.reloadData()
            let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
            if lastIndexPath.row >= 0 {
                self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let lastIndexPath = self.messageList.indexPathsForVisibleRows?.last, lastIndexPath.row == self.messages.count - 1,self.moreMessagesCount > 0 {
            self.moreMessagesCount = 0
            for handler in self.eventHandlers.allObjects {
                handler.onMoreMessagesClicked()
            }
        }
        if self.inputBar.collapsedState == false {
            self.inputBar.hiddenInput()
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.inputBar.collapsedState == false {
            self.inputBar.hiddenInput()
        }
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        if self.inputBar.collapsedState == false {
            self.inputBar.hiddenInput()
        }
    }
}

extension MessageListView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.moreMessages.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.moreMessages.layerProperties(style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9, 0.5)
        self.moreMessages.setTitleColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, for: .normal)
        self.moreMessages.image(UIImage(named: "more_messages", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor), .normal)
        self.messageList.reloadData()
    }
    
    
}

extension MessageListView: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let entity = self.messages[safe: indexPath.row] {
            return entity.height
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.registerMessageCell(tableView: tableView, indexPath: indexPath)
        if self.CellTypes.count > 0 {
            self.CellTypes.removeFirst()
        }
        if let info = self.messages[safe: indexPath.row] {
            cell?.editMode = self.editMode
            cell?.refresh(entity: info)
            info.previewFinished = { [weak self] in
                self?.refreshPreviewResult(entity: $0)
            }
        }
        cell?.clickAction = { [weak self] in
            self?.handleClick(area: $0, entity: $1)
        }
        cell?.longPressAction = { [weak self] in
            self?.handleLongPressed(area: $0, entity: $1, cell: $2)
        }
        cell?.reactionClicked = { [weak self] in
            self?.processReactionEmojiClick(reaction: $0, entity: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell(style: .default, reuseIdentifier: "defaulteCell")
    }
    
    @objc open func refreshPreviewResult(entity: MessageEntity) {
        if let idx = self.messages.firstIndex(where: { $0.message.messageId == entity.message.messageId }) {
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.showType == .thread {
            if indexPath.row > self.messages.count - 4,!self.threadMessagesLoadFinished {
                for handler in self.eventHandlers.allObjects {
                    handler.onMessageListLoadMore()
                }
            }
        }
        for listener in self.eventHandlers.allObjects {
            if let entity = self.messages[safe: indexPath.row] {
                listener.onMessageVisible(entity: entity)
            }
        }
        
    }
    
    private func getMessageCell<T: MessageCell>(
        cellClass: T.Type,
        towards: BubbleTowards,
        identifier: String
    ) -> T? {
        var cell = self.messageList.dequeueReusableCell(with: cellClass, reuseIdentifier: identifier)
        if cell == nil {
            cell = cellClass.init(towards: towards, reuseIdentifier: identifier)
        }
        return cell
    }
    
    private func registerMessageCell(tableView: UITableView,indexPath: IndexPath) -> MessageCell? {
        if let message = self.messages[safe: indexPath.row]?.message {
            let towards: BubbleTowards = message.direction.rawValue == 0 ? .right:.left
            switch message.body.type {
            case .text:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatTextMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatTextMessageCell")
            case .image:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatImageMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatImageMessageCell")
            case .video:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatVideoMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatVideoMessageCell")
            case .voice:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatAudioMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatAudioMessageCell")
            case .file:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatFileMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatFileMessageCell")
            case .combine:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatCombineCell, towards: towards, identifier: "EaseChatUIKit.ChatCombineCell")
            case .location:
                return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatLocationCell, towards: towards, identifier: "EaseChatUIKit.ChatLocationCell")
            case .custom:
                if let body = message.body as? ChatCustomMessageBody {
                    switch body.event {
                    case EaseChatUIKit_user_card_message:
                        return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatContactMessageCell, towards: towards, identifier: "EaseChatUIKit.ChatContactMessageCell")
                    case EaseChatUIKit_alert_message:
                        return self.getMessageCell(cellClass: ComponentsRegister.shared.ChatAlertCell, towards: towards, identifier: "EaseChatUIKit.ChatAlertCell")
                    default:
                        if let cellClass = ComponentsRegister.shared.customCellMaps[body.event] {
                            let identifier = String(describing: body.event)
                            return self.getMessageCell(cellClass: cellClass, towards: towards, identifier: identifier)
                        }
                        return nil
                    }
                } else {
                    return nil
                }
            default:
                if let cellClass = self.CellTypes.first {
                    let identifier = String(describing: cellClass.self)
                    return self.getMessageCell(cellClass: cellClass, towards: towards, identifier: identifier)
                }
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func handleClick(area: MessageCellClickArea,entity: MessageEntity) {
        if self.editMode {
            entity.selected = !entity.selected
            if let idx = self.messages.firstIndex(where: { $0.message.messageId == entity.message.messageId }) {
                (self.messageList.cellForRow(at: IndexPath(row: idx, section: 0)) as? MessageCell)?.renderCheck(entity: entity)
            }
            return
        }
        switch area {
        case .avatar:
            if ComponentViewsActionHooker.shared.chat.bubbleClicked != nil {
                if let user = entity.message.user {
                    ComponentViewsActionHooker.shared.chat.avatarClicked?(user)
                } else {
                    let user = ChatUserProfile()
                    user.id = entity.message.from
                    ComponentViewsActionHooker.shared.chat.avatarClicked?(user)
                }
            } else {
                for handler in self.eventHandlers.allObjects {
                    if let user = entity.message.user {
                        handler.onMessageAvatarClicked(profile: user)
                    } else {
                        let user = ChatUserProfile()
                        user.id = entity.message.from
                        handler.onMessageAvatarClicked(profile: user)
                    }
                }
            }
            
        case .reply:
            if ComponentViewsActionHooker.shared.chat.replyClicked != nil {
                ComponentViewsActionHooker.shared.chat.replyClicked?(entity)
            } else {
                if let quoteMessage = entity.message.quoteMessage {
                    self.highlightMessage(message: quoteMessage)
                    for handler in self.eventHandlers.allObjects {
                        handler.onMessageReplyClicked(message: entity)
                    }
                }
            }
        case .bubble:
            if ComponentViewsActionHooker.shared.chat.bubbleClicked != nil {
                ComponentViewsActionHooker.shared.chat.bubbleClicked?(entity)
            } else {
                for handler in self.eventHandlers.allObjects {
                    handler.onMessageContentClicked(message: entity)
                }
                
            }
        case .status:
            if entity.state == .failure {
                for handler in self.eventHandlers.allObjects {
                    handler.onFailureMessageRetrySend(entity: entity)
                }
            }
        case .topic:
            for handler in self.eventHandlers.allObjects {
                handler.onMessageTopicClicked(entity: entity)
            }
        case .reaction:
            for handler in self.eventHandlers.allObjects {
                handler.onMessageReactionClicked(reaction: nil, entity: entity)
            }
        case .cell:
            if entity.message.body.type == .custom {
                if ComponentViewsActionHooker.shared.chat.bubbleClicked != nil {
                    ComponentViewsActionHooker.shared.chat.bubbleClicked?(entity)
                } else {
                    for handler in self.eventHandlers.allObjects {
                        handler.onMessageContentClicked(message: entity)
                    }
                    
                }
            }
        default:
            break
        }
        
    }
    
    private func processReactionEmojiClick(reaction: MessageReaction?,entity: MessageEntity) {
        if self.editMode {
            return
        }
        for handler in self.eventHandlers.allObjects {
            handler.onMessageReactionClicked(reaction: reaction, entity: entity)
        }
    }
        
    private func handleLongPressed(area: MessageCellClickArea,entity: MessageEntity,cell: MessageCell) {
        if area == .bubble {
            if ComponentViewsActionHooker.shared.chat.bubbleLongPressed != nil {
                ComponentViewsActionHooker.shared.chat.bubbleLongPressed?(entity)
            } else {
                for handler in self.eventHandlers.allObjects {
                    handler.onMessageContentLongPressed(cell: cell)
                }
            }
        } else {
            if ComponentViewsActionHooker.shared.chat.avatarLongPressed != nil {
                if let user = entity.message.user {
                    ComponentViewsActionHooker.shared.chat.avatarLongPressed?(user)
                } else {
                    let user = ChatUserProfile()
                    user.id = entity.message.from
                    ComponentViewsActionHooker.shared.chat.avatarLongPressed?(user)
                }
            } else {
                for handler in self.eventHandlers.allObjects {
                    if let user = entity.message.user {
                        handler.onMessageAvatarLongPressed(profile: user)
                    } else {
                        let user = ChatUserProfile()
                        user.id = entity.message.from
                        handler.onMessageAvatarLongPressed(profile: user)
                    }
                    
                }
            }
        }
    }
    
}

extension MessageListView: IMessageListViewDriver {
    public func readAllMessages() {
        self.messages.forEach { $0.state = .read }
        self.messageList.beginUpdates()
        self.messageList.reloadRows(at: self.messageList.indexPathsForVisibleRows ?? [], with: .automatic)
        self.messageList.endUpdates()
    }
    
    public func highlightMessage(message: ChatMessage) {
        if message.status == .failed {
            return
        }
        if let highlightIndex = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messageList.scrollToRow(at: IndexPath(row: highlightIndex, section: 0), at: .middle, animated: true)
            if let cell = self.messageList.cellForRow(at: IndexPath(row: highlightIndex, section: 0)) {
                UIView.animate(withDuration: 1, delay: 0.5) {
                    cell.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
                    cell.contentView.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
                } completion: { finished in
                    cell.backgroundColor = .clear
                    cell.contentView.backgroundColor = .clear
                }
            }
            
        }
    }
    
    public func stopAudioMessagesPlay() {
        var indexPaths = [IndexPath]()
        for (index,entity) in self.messages.enumerated() {
            if entity.playing,entity.message.body.type == .voice {
                entity.playing = false
                let audioIndex = IndexPath(row: index, section: 0)
                if let visibleIndexes = self.messageList.indexPathsForVisibleRows,visibleIndexes.contains(audioIndex) {
                    indexPaths.append(audioIndex)
                }
            }
        }
        if indexPaths.count > 0 {
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: indexPaths, with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    public func endRefreshing() {
        self.messageList.refreshControl?.endRefreshing()
    }
    
    public func updateThreadLoadMessagesFinished(finished: Bool) {
        self.threadMessagesLoadFinished = finished
    }
    
    
    public var scrolledBottom: Bool {
        let contentHeight = self.messageList.contentSize.height
        let tableViewHeight = self.messageList.bounds.size.height
        let yOffset = self.messageList.contentOffset.y
        return Int(ceilf(Float(yOffset))) >= Int(ceilf(Float(contentHeight - tableViewHeight)))
    }
    
    
    public var dataSource: [ChatMessage] {
        self.messages.map { $0.message }
    }
    
    public func reloadReaction(message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            if let indexPath = self.messageList.indexPathsForVisibleRows?.first(where: { $0.row == index }),indexPath.row >= 0 {
                let entity = self.convertMessage(message: message)
                let reactionWidth = entity.reactionMenuWidth()
                if reactionWidth < reactionMaxWidth-30 {
                    if let reactions = message.reactionList {
                        if (reactions.count == 1 && reactions.count > entity.visibleReactionToIndex) || reactions.count <= 0 {
                            self.messages.replaceSubrange(index...index, with: [entity])
                            self.messageList.beginUpdates()
                            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            self.messageList.endUpdates()
                        } else {
                            if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
                                if let indexPath = self.messageList.indexPathsForVisibleRows?.first(where: { $0.row == index }){
                                    if let cell = self.messageList.cellForRow(at: indexPath) as? MessageCell {
                                        cell.updateAxis(entity: entity)
                                        cell.reactionView.refresh(entity: entity)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public func reloadTopic(message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            if let indexPath = self.messageList.indexPathsForVisibleRows?.first(where: { $0.row == index }),indexPath.row >= 0 {
                self.messages.replaceSubrange(index...index, with: [self.convertMessage(message: message)])
                self.messageList.reloadData()
            }
        }
    }
    
    public func updateGroupMessageChatThreadChanged(message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            if let indexPath = self.messageList.indexPathsForVisibleRows?.first(where: { $0.row == index }),let entity = self.messages[safe: index] {
                entity.topicContent = nil
                entity.topicContent = entity.convertTopicContent()
                if let cell = self.messageList.cellForRow(at: indexPath) as? MessageCell {
                    cell.topicView.refresh(entity: entity)
                }
            }
        }
    }
    
    public var replyMessageId: String {
        self.replyId
    }
    
    public func insertMessages(messages: [ChatMessage]) {
        self.messageList.refreshControl?.endRefreshing()
        if self.showType == .thread {
            self.messages.append(contentsOf: messages.map({
                self.convertMessage(message: $0)
            }))
            self.messageList.reloadData()
        } else {
            let pullBeforeMessageId = self.messages.first?.message.messageId ?? ""
            self.messages.insert(contentsOf: messages.map({
                self.convertMessage(message: $0)
            }), at: 0)
            self.messageList.reloadData()
            if let beforeIndex = self.messages.firstIndex(where: { $0.message.messageId == pullBeforeMessageId }) {
                self.messageList.scrollToRow(at: IndexPath(row: beforeIndex, section: 0), at: .top, animated: false)
            }
            
        }
    }
    
    
    public var firstMessageId: String {
        self.messages.first?.message.messageId ?? ""
    }
    
    public func refreshMessages(messages: [ChatMessage]) {
        self.messageList.refreshControl?.endRefreshing()
        self.messages = messages.map({
            self.convertMessage(message: $0)
        })
        self.messageList.reloadData()
        if self.showType == .thread {
            if !self.threadMessagesLoadFinished {
                return
            }
        }
        if self.messages.count > 1 {
            if self.showType == .history {
                let firstIndexPath = IndexPath(row: 0, section: 0)
                self.messageList.scrollToRow(at: firstIndexPath, at: .top, animated: true)
            } else {
                if self.showType == .normal {
                    let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    if lastIndexPath.row >= 0 {
                        self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                    }
                }
            }
        }
    }
    
    public func updateAudioMessageStatus(message: ChatMessage, play: Bool) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            if let entity = self.messages[safe: index] {
                entity.playing = play
                if let cell = self.messageList.cellForRow(at: IndexPath(row: index, section: 0)) as? AudioMessageCell {
                    (cell.content as? AudioMessageView)?.refresh(entity: entity)
                }
            }
        }
    }
    
    public func updateMessageAttachmentStatus(message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages[index].state = self.convertStatus(message: message)
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    public func addMentionUserToField(user: ChatUserProfileProtocol) {
        let result = NSMutableAttributedString(attributedString: self.inputBar.inputField.attributedText)
        let key = NSAttributedString.Key("mentionInfo")
        var nickName = user.remark
        if nickName.isEmpty {
            nickName = user.nickname
            if nickName.isEmpty {
                nickName = user.id
            }
        }
        let newString = NSAttributedString(string: "@\(nickName) ", attributes: [.font: self.inputBar.inputField.font!, key: user, .foregroundColor: (Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)])
        if result.length > 0 && result.string.hasSuffix("@") {
            result.deleteCharacters(in: NSRange(location: result.length - 1, length: 1))
        }
        result.append(newString)
        let old = self.inputBar.inputField.typingAttributes
        self.inputBar.inputField.attributedText = result
        self.inputBar.inputField.typingAttributes = old
        self.inputBar.inputField.selectedRange = NSRange(location: result.length, length: 0)
        self.inputBar.inputField.becomeFirstResponder()
    }
    
    
    public func updateMessageStatus(message: ChatMessage, status: ChatMessageStatus) {
        if let index = self.messages.firstIndex(where: { $0.message.localTime == message.localTime }) {
            self.messages[safe: index]?.message = message
            self.messages[safe: index]?.state = status
            if let cell = self.messageList.cellForRow(at: IndexPath(row: index, section: 0)) as? MessageCell {
                cell.updateMessageStatus(entity: self.messages[index])
            }
        }
    }
    
    private func convertMessage(message: ChatMessage) -> MessageEntity {
        let entity = ComponentsRegister.shared.MessageRenderEntity.init()
        if message.status == .pending {
            message.status = .succeed
        }
        entity.state = self.convertStatus(message: message)
        entity.message = message
        _ = entity.replyTitle
        _ = entity.replyContent
        _ = entity.content
        entity.topicContent = entity.convertTopicContent()
        self.convertURLPreview(entity: entity)
        _ = entity.replySize
        _ = entity.bubbleSize
        _ = entity.height
        return entity
    }
    
    private func convertURLPreview(entity: MessageEntity) {
        if Appearance.chat.enableURLPreview {
            if let dic = entity.message.ext?["ease_chat_uikit_text_url_preview"] as? Dictionary<String,String> {
                if let status = dic["status"] {
                    entity.previewResult = status == "1" ? .success:.failure
                } else {
                    if entity.previewURL == dic["url"]{
                        if dic["title"]?.isEmpty ?? true {
                            entity.previewResult = .failure
                        } else {
                            entity.previewResult = .success
                        }
                    } else {
                        entity.previewResult = .failure
                    }
                }
            }
            if entity.containURL {
                let previewContent = URLPreviewManager.caches[entity.previewURL]
                previewContent?.towards = entity.message.direction == .send ? .right:.left
                if previewContent != nil,previewContent?.titleAttribute != nil {
                    entity.urlPreview = previewContent
                    entity.previewResult = .success
                } else {
                    entity.urlPreview = nil
                }
            }
            
            if entity.urlPreview == nil, entity.containURL, entity.previewResult == .parsing,!entity.previewURL.isEmpty {
                entity.previewStart()
            }
            
        }
    }
    
    private func convertStatus(message: ChatMessage) -> ChatMessageStatus {
        switch message.status {
        case .succeed:
            if message.isReadAcked {
                return .read
            }
            if message.isDeliverAcked {
                return .delivered
            }
            return .succeed
        case .pending:
            return .sending
        default:
            return .failure
        }
    }
    
    public func showMessage(message: ChatMessage) {
        if self.showType == .thread {
            if !self.threadMessagesLoadFinished {
                return
            }
        }
        if message.direction == .send {
            self.replyId = ""
        }
        if message.direction == .send {
            self.replyBar.isHidden = true
        }
        self.messageList.refreshControl?.endRefreshing()
        self.messages.append(self.convertMessage(message: message))
        let scrolledBottom = self.scrolledBottom
        self.messageList.reloadData()
        if self.messages.count > 1 {
            if message.direction == .send {
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                if lastIndexPath.row > 0 {
                    self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                }
                if self.moreMessagesCount > 0 {
                    self.moreMessagesCount = 0
                    for handler in self.eventHandlers.allObjects {
                        handler.onMoreMessagesClicked()
                    }
                }
            } else {
                if scrolledBottom {
                    let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    if lastIndexPath.row > 0 {
                        self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                    }
                } else {
                    self.moreMessagesCount += 1
                    self.moreMessages.setTitle("\(self.moreMessagesCount) "+"new messages".chat.localize, for: .normal)
                }
            }
            
        }
    }
    
    @objc open func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: self.messageList.contentSize.height - self.messageList.bounds.size.height + self.messageList.contentInset.bottom + MessageInputBarHeight)
        self.messageList.setContentOffset(bottomOffset, animated: true)
    }
    
    public func processMessage(operation: MessageOperation,message: ChatMessage) {
        self.inputBar.hiddenInput()
        self.replyBar.isHidden = true
        if message.direction == .send {
            self.replyId = ""
        }
        switch operation {
        case .copy: self.copyAction(message)
        case .edit: self.editAction(message)
        case .reply: self.replyAction(message)
        case .delete: self.deleteAction(message)
        case .recall: self.recallAction(message)
        case .translate: self.translateAction(message)
        case .originalText: self.showOriginalTextAction(message)
        default:  break
        }
    }
    
    private func showOriginalTextAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            let entity = ComponentsRegister.shared.MessageRenderEntity.init()
            entity.state = self.convertStatus(message: message)
            entity.message = message
            entity.showTranslation = false
            _ = entity.content
            self.convertURLPreview(entity: entity)
            _ = entity.replyTitle
            _ = entity.replyContent
            _ = entity.bubbleSize
            _ = entity.height
            _ = entity.replySize
            self.messages.replaceSubrange(index...index, with: [entity])
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    
    
    private func translateAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            let entity = ComponentsRegister.shared.MessageRenderEntity.init()
            entity.state = self.convertStatus(message: message)
            entity.message = message
            entity.showTranslation = true
            _ = entity.content
            self.convertURLPreview(entity: entity)
            _ = entity.replyTitle
            _ = entity.replyContent
            _ = entity.bubbleSize
            _ = entity.height
            _ = entity.replySize
            self.messages.replaceSubrange(index...index, with: [entity])
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    
    private func copyAction(_ message: ChatMessage) {
        if let body = message.body as? ChatTextMessageBody {
            UIPasteboard.general.string = body.text
            UIViewController.currentController?.showToast(toast: "Copied".chat.localize)
        }
    }
    
    
    private func editAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages.replaceSubrange(index...index, with: [self.convertMessage(message: message)])
            self.messageList.beginUpdates()
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
    }
    
    private func replyAction(_ message: ChatMessage) {
        self.replyBar.isHidden = false
        self.replyBar.refresh(message: message)
        self.replyId = message.messageId
        self.inputBar.show()
    }
    
    private func deleteAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages.remove(at: index)
            self.messageList.beginUpdates()
            self.messageList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.messageList.endUpdates()
        }
        var indexPaths = [IndexPath]()
        for (index,entity) in self.messages.enumerated() {
            if entity.message.quoteMessageId == message.messageId {
                if let entity = self.messages[safe: index], let message = ChatClient.shared().chatManager?.getMessageWithMessageId(entity.message.messageId) {
                    self.messages[index] = self.convertMessage(message: message)
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
            }
        }
        self.messageList.beginUpdates()
        self.messageList.reloadRows(at: indexPaths, with: .automatic)
        self.messageList.endUpdates()
    }
    
    private func recallAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages.replaceSubrange(index...index, with: [self.convertMessage(message: message)])
        }
        var indexPaths = [IndexPath]()
        for (index,entity) in self.messages.enumerated() {
            if entity.message.quoteMessageId == message.messageId {
                if let entity = self.messages[safe: index] ,let message = ChatClient.shared().chatManager?.getMessageWithMessageId(entity.message.messageId) {
                    self.messages[index] = self.convertMessage(message: message)
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
            }
        }
        self.messageList.reloadData()
    }
    
    
}



