//
//  ChatThreadListController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objcMembers open class ChatThreadListController: UIViewController {
    
    public private(set) var threads = [EaseChatThread]() {
        didSet {
            DispatchQueue.main.async {
                if self.threads.count <= 0 {
                    self.topicList.backgroundView = self.empty
                } else {
                    self.topicList.backgroundView = nil
                }
            }
        }
    }
    
    private var cursor = ""
    
    private let pageSize = 20
    
    public private(set) var groupId = ""
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(showLeftItem: true,textAlignment: .left,hiddenAvatar: true).backgroundColor(.white)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: self.topicList.bounds,emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: { [weak self] in

        }).backgroundColor(.clear)
    }()
    
    public private(set) lazy var topicList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: ScreenHeight-NavigationHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).separatorStyle(.none).showsVerticalScrollIndicator(false).tableFooterView(UIView()).backgroundColor(.clear)
    }()
    
    public private(set) lazy var loadingView: LoadingView = {
        self.createLoading()
    }()
    
    /**
     Creates a loading view.
     
     - Returns: A `LoadingView` instance.
     */
    @objc open func createLoading() -> LoadingView {
        LoadingView(frame: self.view.bounds)
    }
    
    public required init(groupId: String) {
        self.groupId = groupId
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.topicList,self.loadingView])
        self.navigation.title = "All Threads"
        // Do any additional setup after loading the view.
        self.requestThreadList()
        self.switchTheme(style: Theme.style)
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
    }
    
    open func requestThreadList() {
        self.loadingView.stopAnimating()
        self.loadingView.startAnimating()
        ChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.groupId, completion: { groupInfo, error in
            if error == nil, let group = groupInfo {
                if group.owner == ChatUIKitContext.shared?.currentUserId ?? "" {
                    ChatClient.shared().threadManager?.getChatThreadsFromServer(withParentId: self.groupId, cursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
                        guard let `self` = self else { return }
                        self.loadingView.stopAnimating()
                        self.handleThreadRequest(result: result, error: error)
                    })
                } else {
                    ChatClient.shared().threadManager?.getJoinedChatThreadsFromServer(withParentId: self.groupId, cursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
                        guard let `self` = self else { return }
                        self.loadingView.stopAnimating()
                        self.handleThreadRequest(result: result, error: error)
                    })
                }
            } else {
                self.loadingView.stopAnimating()
                consoleLogInfo("requestGroupDetail error:\(error?.errorDescription ?? "")", type: .debug)
            }
        })
    }
    
    open func handleThreadRequest(result: CursorResult<GroupChatThread>?, error: ChatError?) {
        if error == nil {
            self.cursor = result?.cursor ?? ""
            if let threads = result?.list {
                self.threads.append(contentsOf: threads.map({
                    let thread = EaseChatThread()
                    thread.thread = $0
                    return thread
                }))
            } else {
                self.threads = []
            }
        } else {
            self.topicList.backgroundView = self.empty
            consoleLogInfo("requestThreadList error:\(error?.errorDescription ?? "")", type: .debug)
        }
        self.topicList.reloadData()
        self.requestThreadMessage()
    }
    
    private func requestThreadMessage() {
        ChatClient.shared().threadManager?.getLastMessageFromSever(withChatThreads: self.threads.map({ $0.thread.threadId }), completion: { messageMap, error in
            if error == nil, let messageMap = messageMap {
                for (threadId, message) in messageMap {
                    if let index = self.threads.firstIndex(where: { $0.thread.threadId == threadId }) {
                        self.threads[index].lastMessage = message
                    }
                }
                self.topicList.reloadData()
            } else {
                consoleLogInfo("requestThreadMessage error:\(error?.errorDescription ?? "")", type: .debug)
            }
        })
    }
    
    /**
     Handles the navigation bar click events.
     
     - Parameters:
     - type: The type of navigation bar click event.
     - indexPath: The index path associated with the event (optional).
     */
    @objc open func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        default:
            break
        }
    }
    
    @objc open func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension ChatThreadListController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.threads.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatThreadCell") as? ChatThreadCell
        if cell == nil {
            cell = ChatThreadCell(style: .default, reuseIdentifier: "ChatThreadCell")
        }
        if let thread = self.threads[safe: indexPath.row] {
            cell?.refresh(chatThread: thread)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let thread = self.threads[safe: indexPath.row] {
            let vc = ChatThreadViewController(chatThread: thread.thread,parentMessageId: thread.thread.messageId)
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row <= self.threads.count - 1,!self.cursor.isEmpty,self.threads.count%self.pageSize == 0 {
            self.requestThreadList()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        var unknownInfoIds = [String]()
//        if let visiblePaths = self.topicList.indexPathsForVisibleRows {
//            for indexPath in visiblePaths {
//                if let lastMessage = self.threads[safe: indexPath.row]?.lastMessage {
//                    unknownInfoIds.append(self.threads[safe: indexPath.row]?.thread.threadId ?? "")
//                }
//            }
//        }
    }
}

//MARK: - ThemeSwitchProtocol
extension ChatThreadListController: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
}

@objcMembers open class EaseChatThread: NSObject {
    public var thread: GroupChatThread = GroupChatThread()
    
    public var lastMessage: ChatMessage?
}
