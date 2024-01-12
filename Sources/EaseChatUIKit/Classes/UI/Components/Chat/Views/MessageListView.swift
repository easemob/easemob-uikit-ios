import UIKit

@objc public enum MessageOperation: UInt {
    case copy
    case edit
    case reply
    case delete
    case recall
}

@objc public protocol MessageListViewActionEventsDelegate: NSObjectProtocol {
    
    /// The method will call on message list pull to refreshing.
    func onMessageListPullRefresh()
    
    /// The method will call on message reply content clicked.
    /// - Parameter message: ``ChatMessage``
    func onMessageReplyClicked(message: MessageEntity)
    
    /// The method will call on message content clicked.
    /// - Parameter message: ``MessageEntity``
    func onMessageContentClicked(message: MessageEntity)
    
    /// The method will call on message content long pressed.
    /// - Parameter message: ``MessageEntity``
    func onMessageContentLongPressed(message: MessageEntity)
    
    /// The method will call on message avatar clicked
    /// - Parameter profile: ``EaseProfileProtocol``
    func onMessageAvatarClicked(profile: EaseProfileProtocol)
    
    /// The method will call on message avatar long pressed.
    /// - Parameter profile: ``EaseProfileProtocol``
    func onMessageAvatarLongPressed(profile: EaseProfileProtocol)
    
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
}

@objc public protocol IMessageListViewDriver: NSObjectProtocol {
    
    var firstMessageId: String {get}
    
    var replyMessageId: String {get}
    
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
    func addMentionUserToField(user: EaseProfileProtocol)
    
    /// Update audio message  on play status changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - play: play or stop
    func updateAudioMessageStatus(message: ChatMessage,play: Bool)
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
    
    private var replyId = ""
    
    public private(set) lazy var messageList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height-BottomBarHeight-52), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none).backgroundColor(.clear)
    }()
        
    public private(set) lazy var inputBar: MessageInputBar = {
        MessageInputBar(frame: CGRect(x: 0, y: self.frame.height-52-BottomBarHeight, width: self.frame.width, height: 52), text: "", placeHolder: "Aa")
    }()
    
    public private(set) lazy var replyBar: MessageInputReplyView = {
        MessageInputReplyView(frame: CGRect(x: 0, y: self.inputBar.frame.minY-52, width: self.frame.width, height: 53))
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc required public init(frame: CGRect,mention: Bool) {
        super.init(frame: frame)
        self.canMention = mention
        self.messageList.keyboardDismissMode = .onDrag
        self.messageList.allowsSelection = false
        if Appearance.chat.contentStyle.contains(.withReply) {
            self.addSubViews([self.messageList,self.inputBar,self.replyBar])
        } else {
            self.addSubViews([self.messageList,self.inputBar])
        }
        self.messageList.refreshControl = UIRefreshControl()
        self.messageList.refreshControl?.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        self.replyBar.isHidden = true
        self.inputBarEvents()
        self.inputBar.axisYChanged = { [weak self] value in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.replyBar.frame = CGRect(x: 0, y: value-52, width: self.frame.width, height: 53)
                }
            }
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
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if let info = self.messages[safe: indexPath.row] {
            cell?.refresh(entity: info)
        }
        cell?.clickAction = { [weak self] in
            self?.handleClick(area: $0, entity: $1)
        }
        cell?.longPressAction = { [weak self] in
            self?.handleLongPressed(area: $0, entity: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? MessageCell()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        for listener in self.eventHandlers.allObjects {
            if let entity = self.messages[safe: indexPath.row] {
                listener.onMessageVisible(entity: entity)
            }
        }
    }
    
    private func registerMessageCell(tableView: UITableView,indexPath: IndexPath) -> MessageCell? {
        if let message = self.messages[safe: indexPath.row]?.message {
            let towards: BubbleTowards = message.direction.rawValue == 0 ? .right:.left
            switch message.body.type {
            case .text:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatTextMessageCell, reuseIdentifier: "EaseChatUIKit.ChatTextMessageCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatTextMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatTextMessageCell")
                }
                return cell
            case .image:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatImageMessageCell, reuseIdentifier: "EaseChatUIKit.ChatImageMessageCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatImageMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatImageMessageCell")
                }
                return cell
            case .video:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatVideoMessageCell, reuseIdentifier: "EaseChatUIKit.ChatVideoMessageCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatVideoMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatVideoMessageCell")
                }
                return cell
            case .voice:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatAudioMessageCell, reuseIdentifier: "EaseChatUIKit.ChatAudioMessageCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatAudioMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatAudioMessageCell")
                }
                return cell
            case .file:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatFileMessageCell, reuseIdentifier: "EaseChatUIKit.ChatFileMessageCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatFileMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatFileMessageCell")
                }
                return cell
            case .combine:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatLocationCell, reuseIdentifier: "EaseChatUIKit.ChatLocationCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatLocationCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatLocationCell")
                }
                return cell
            case .location:
                var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatCombineCell, reuseIdentifier: "EaseChatUIKit.ChatCombineCell")
                if cell == nil {
                    cell = ComponentsRegister.shared.ChatCombineCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatCombineCell")
                }
                return cell
            case .custom:
                if let body = message.body as? ChatCustomMessageBody {
                    switch body.event {
                    case EaseChatUIKit_user_card_message:
                        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatContactMessageCell, reuseIdentifier: "EaseChatUIKit.ChatContactMessageCell")
                        if cell == nil {
                            cell = ComponentsRegister.shared.ChatContactMessageCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatContactMessageCell")
                        }
                        return cell
                    case EaseChatUIKit_alert_message:
                        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ChatAlertCell, reuseIdentifier: "EaseChatUIKit.ChatAlertCell")
                        if cell == nil {
                            cell = ComponentsRegister.shared.ChatAlertCell.init(towards: towards, reuseIdentifier: "EaseChatUIKit.ChatAlertCell")
                        }
                        return cell
                    default:
                        var cell: MessageCell?
                        for Class in ComponentsRegister.shared.customCellClasses {
                            let identifier = String(describing: Class.self)
                            cell = tableView.dequeueReusableCell(with: Class, reuseIdentifier: identifier)
                            if cell == nil {
                                cell = ComponentsRegister.shared.ChatCustomMessageCell.init(towards: towards, reuseIdentifier: identifier)
                            }
                            break
                        }
                        
                        return cell
                    }
                } else {
                    return nil
                }
            default:
                var cell: MessageCell?
                for Class in ComponentsRegister.shared.customCellClasses {
                    let identifier = String(describing: Class.self)
                    cell = tableView.dequeueReusableCell(with: Class, reuseIdentifier: identifier)
                    if cell == nil {
                        cell = ComponentsRegister.shared.ChatCustomMessageCell.init(towards: towards, reuseIdentifier: identifier)
                    }
                    break
                }
                
                return cell
            }
        } else {
            return nil
        }
    }
    
    private func handleClick(area: MessageCellClickArea,entity: MessageEntity) {
        switch area {
        case .avatar:
            if ComponentViewsActionHooker.shared.chat.bubbleClicked != nil {
                if let user = entity.message.user {
                    ComponentViewsActionHooker.shared.chat.avatarClicked?(user)
                } else {
                    let user = EaseProfile()
                    user.id = entity.message.from
                    ComponentViewsActionHooker.shared.chat.avatarClicked?(user)
                }
            } else {
                for handler in self.eventHandlers.allObjects {
                    if let user = entity.message.user {
                        handler.onMessageAvatarClicked(profile: user)
                    } else {
                        let user = EaseProfile()
                        user.id = entity.message.from
                        handler.onMessageAvatarClicked(profile: user)
                    }
                }
            }
            
        case .reply:
            if ComponentViewsActionHooker.shared.chat.replyClicked != nil {
                ComponentViewsActionHooker.shared.chat.replyClicked?(entity)
            } else {
                if let highlightIndex = self.messages.firstIndex(where: { $0.message.messageId == entity.message.quoteMessage?.messageId ?? "" }) {
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
                for handler in self.eventHandlers.allObjects {
                    handler.onMessageReplyClicked(message: entity)
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
        }
        
    }
    
    private func handleLongPressed(area: MessageCellClickArea,entity: MessageEntity) {
        if area == .bubble {
            if ComponentViewsActionHooker.shared.chat.bubbleLongPressed != nil {
                ComponentViewsActionHooker.shared.chat.bubbleLongPressed?(entity)
            } else {
                for handler in self.eventHandlers.allObjects {
                    handler.onMessageContentLongPressed(message: entity)
                }
            }
        } else {
            if ComponentViewsActionHooker.shared.chat.avatarLongPressed != nil {
                if let user = entity.message.user {
                    ComponentViewsActionHooker.shared.chat.avatarLongPressed?(user)
                } else {
                    let user = EaseProfile()
                    user.id = entity.message.from
                    ComponentViewsActionHooker.shared.chat.avatarLongPressed?(user)
                }
            } else {
                for handler in self.eventHandlers.allObjects {
                    if let user = entity.message.user {
                        handler.onMessageAvatarLongPressed(profile: user)
                    } else {
                        let user = EaseProfile()
                        user.id = entity.message.from
                        handler.onMessageAvatarLongPressed(profile: user)
                    }
                    
                }
            }
        }
    }
}

extension MessageListView: IMessageListViewDriver {
    public var replyMessageId: String {
        self.replyId
    }
    
    public func insertMessages(messages: [ChatMessage]) {
        self.messageList.refreshControl?.endRefreshing()
        self.messages.insert(contentsOf: messages.map({
            self.convertMessage(message: $0)
        }), at: 0)
        self.messageList.reloadData()
        if self.messages.count > 1 {
            let indexPath = IndexPath(row: 1, section: 0)
            if indexPath.row >= 0 {
                self.messageList.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        if self.messages.count > 1 {
            let lastIndexPath = IndexPath(row: self.messageList.numberOfRows(inSection: 0) - 1, section: 0)
            if lastIndexPath.row >= 0 {
                self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    public func updateAudioMessageStatus(message: ChatMessage, play: Bool) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            var indexPaths = [IndexPath]()
            indexPaths.append(IndexPath(row: index, section: 0))
            for entity in self.messages {
                if let otherIndex = self.messages.firstIndex(where: { $0.playing }) {
                    indexPaths.append(IndexPath(row: otherIndex, section: 0))
                }
                if entity.message.messageId != message.messageId {
                    entity.playing = false
                }
            }
            self.messages[safe: index]?.playing = play
            self.messageList.reloadRows(at: indexPaths, with: .none)
        }
    }
    
    public func updateMessageAttachmentStatus(message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    public func addMentionUserToField(user: EaseProfileProtocol) {
        let result = NSMutableAttributedString(attributedString: self.inputBar.inputField.attributedText)
        let key = NSAttributedString.Key("mentionInfo")
        let nickName = user.nickname.isEmpty ? user.id:user.nickname
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
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages[safe: index]?.state = status
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func convertMessage(message: ChatMessage) -> MessageEntity {
        let entity = ComponentsRegister.shared.MessageRenderEntity.init()
        entity.state = self.convertStatus(message: message)
        entity.message = message
        _ = entity.content
        _ = entity.replyTitle
        _ = entity.replyContent
        _ = entity.bubbleSize
        _ = entity.height
        _ = entity.replySize
        return entity
    }
    
    private func convertStatus(message: ChatMessage) -> ChatMessageStatus {
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
    
    public func showMessage(message: ChatMessage) {
        if message.direction == .send {
            self.replyBar.isHidden = true
        }
        self.messageList.refreshControl?.endRefreshing()
        self.messages.append(self.convertMessage(message: message))
        self.messageList.reloadData()
        if self.messages.count > 1 {
            let lastIndexPath = IndexPath(row: self.messageList.numberOfRows(inSection: 0) - 1, section: 0)
            if lastIndexPath.row > 0 {
                self.messageList.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
    
    public func processMessage(operation: MessageOperation,message: ChatMessage) {
        self.replyBar.isHidden = true
        self.replyId = ""
        switch operation {
        case .copy: self.copyAction(message)
        case .edit: self.editAction(message)
        case .reply: self.replyAction(message)
        case .delete: self.deleteAction(message)
        case .recall: self.recallAction(message)
        default:
            break
        }
    }
    
    private func copyAction(_ message: ChatMessage) {
        if let body = message.body as? ChatTextMessageBody {
            UIPasteboard.general.string = body.text
        }
    }
    
    
    private func editAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages.remove(at: index)
            self.messages.insert(self.convertMessage(message: message), at: index)
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func replyAction(_ message: ChatMessage) {
        self.replyBar.isHidden = false
        self.replyBar.refresh(message: message)
        self.replyId = message.messageId
    }
    
    private func deleteAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.messageId == message.messageId }) {
            self.messages.remove(at: index)
            self.messageList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func recallAction(_ message: ChatMessage) {
        if let index = self.messages.firstIndex(where: { $0.message.timestamp == message.timestamp }) {
            self.messages.remove(at: index)
            self.messages.insert(self.convertMessage(message: message), at: index)
            self.messageList.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
