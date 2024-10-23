//
//  SearchHistoryMessagesViewController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/15.
//

import UIKit

@objcMembers open class SearchHistoryMessagesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    private var searchKeyWord = ""
    
    public var rawDatas = [ChatMessage]() {
        didSet {
            DispatchQueue.main.async {
                if self.rawDatas.count <= 0  {
                    self.searchList.backgroundView = self.empty
                } else {
                    self.searchList.backgroundView = nil
                }
            }
        }
    }
    
    private var selectClosure: ((ChatMessage) -> Void)?
    
    private var service: ChatService?
    
    private var type: ChatConversationType = .chat
    
    private var active = false {
        didSet {
            if self.active == false {
                self.searchResults.removeAll()
            }
        }
    }
    
    
    public private(set) var searchResults = [ChatMessage]()
    
    public private(set) lazy var searchHeader: SearchHeaderBar = {
        SearchHeaderBar(frame: CGRect(x: 0, y: StatusBarHeight+10, width: ScreenWidth, height: 44), displayStyle: .other).backgroundColor(.clear)
    }()
    
    public private(set) lazy var searchList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.searchHeader.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.searchHeader.frame.maxY-BottomBarHeight-10), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none).rowHeight(Appearance.contact.rowHeight).backgroundColor(.clear)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.searchList.frame.width, height: self.searchList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil)) {
            
        }
    }()
    
    /// ``SearchHistoryMessagesViewController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - conversationId: ID of the conversation.
    ///   - action: Select row callback.
    @objc public required init(conversationId: String,action: @escaping (ChatMessage) -> Void) {
        self.service = ChatServiceImplement(to: conversationId)
        self.selectClosure = action
        self.type = ChatClient.shared().chatManager?.getConversationWithConvId(conversationId)?.type ?? .chat
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.searchList.keyboardDismissMode = .onDrag
        
        self.view.addSubViews([self.searchHeader,self.searchList])
        self.searchList.keyboardDismissMode = .onDrag
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.searchHeader.textChanged = { [weak self] in
            guard let `self` = self else { return }
            self.searchKeyWord = $0.lowercased()
            self.searchMessage()
        }
        self.searchHeader.textFieldState = { [weak self] in
            self?.active = $0 == .began
        }
        self.searchHeader.actionClosure = { [weak self] in
            self?.active = false
            self?.searchKeyWord = ""
            self?.searchList.reloadData()
            if $0 == .cancel {
                self?.pop()
            }
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchHeader.searchField.becomeFirstResponder()
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.active ? self.searchResults.count:self.rawDatas.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "EaseUIKit_SearchHistoryMessageCell") as? SearchHistoryMessageCell
        if cell == nil {
            cell = SearchHistoryMessageCell(style: .default, reuseIdentifier: "EaseUIKit_SearchHistoryMessageCell")
        }
        if let item = (self.active ? self.searchResults:self.rawDatas)[safe: indexPath.row] {
            if let info = item.user {
                info.remark = ChatUIKitContext.shared?.userCache?[item.from]?.remark ?? ""
                cell?.refresh(message: item,info: info,keyword: self.searchKeyWord)
            }
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        self.active = false
        if let item = (self.active ? self.searchResults:self.rawDatas)[safe: indexPath.row] {
            let vc = SearchResultMessagesController(conversationId: item.conversationId, chatType: item.chatType == .chat ? .chat:.group, searchMessageId: item.messageId)
            self.navigationController?.pushViewController(vc, animated: true)
//            self.selectClosure?(item)
        }
    }

}


extension SearchHistoryMessagesViewController {
    
    func searchMessage() {
        self.service?.searchMessage(keyword: self.searchKeyWord, pageSize: 999, userId: "", completion: { [weak self] error, messages in
            if error == nil {
                self?.rawDatas.removeAll()
                self?.rawDatas.append(contentsOf: messages)
                self?.filterResultsWithSearchString()
            } else {
                consoleLogInfo("search message error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func filterResultsWithSearchString() {
        self.searchResults = self.rawDatas.filter({ message in
            let showName = message.showType
            return (showName.lowercased() as NSString).range(of: self.searchKeyWord).location != NSNotFound && (showName.lowercased() as NSString).range(of: self.searchKeyWord).length >= 0 && message.body.type == .text
        })
        self.searchList.reloadData()
    }
    
    
    
    
}

extension SearchHistoryMessagesViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.searchList.reloadData()
    }
    
    
}
