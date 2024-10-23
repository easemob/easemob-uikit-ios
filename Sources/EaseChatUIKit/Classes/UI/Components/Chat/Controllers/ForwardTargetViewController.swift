//
//  ForwardTargetViewController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/2/19.
//

import UIKit

@objcMembers open class ForwardTargetViewController: UIViewController {
    
    public private(set) var messages = [ChatMessage]()
    
    private var combineForward = true
    
    private var index = 0
    
    private var page = 0
    
    private var pageSize = 20
    
    private var searchKeyWord = ""
    
    private var searchMode = false
        
    private var datas = [ChatUserProfileProtocol]() {
        didSet {
            DispatchQueue.main.async {
                if self.datas.count <= 0 {
                    self.targetsList.backgroundView = self.empty
                } else {
                    self.targetsList.backgroundView = nil
                }
            }
        }
    }
    
    private var forwarded = false
    
    private var searchResults = [ChatUserProfileProtocol]()
    
    public private(set) lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.view.frame.width/2.0-18, y: 6, width: 36, height: 5)).cornerRadius(2.5).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    public private(set)  lazy var toolBar: PageContainerTitleBar = {
        PageContainerTitleBar(frame: CGRect(x: 0, y: self.indicator.frame.maxY + 4, width: self.view.frame.width, height: 44), choices: ["Contact".chat.localize,"Group".chat.localize]) { [weak self] in
            self?.index = $0
            if $0 == 0 {
                self?.targetsList.tableHeaderView = self?.searchController.searchBar
            } else {
                self?.targetsList.tableHeaderView = nil
            }
            self?.fillDatas(refresh: true)
        }
    }()
    
    public private(set) lazy var targetsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.toolBar.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-self.toolBar.frame.maxY-StatusBarHeight), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).separatorStyle(.none).showsVerticalScrollIndicator(false).tableFooterView(UIView()).backgroundColor(.clear).tableHeaderView(self.searchController.searchBar)
    }()
    
    public private(set) lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsSearchResultsController = true
        searchController.showsSearchResultsController = true
        searchController.automaticallyShowsScopeBar = false
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.delegate = self
        return searchController
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: self.targetsList.bounds,emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: { [weak self] in

        }).backgroundColor(.clear)
    }()
    
    public var dismissClosure: ((Bool) -> Void)?
        
    private var noMoreGroup = false
    
    public required init(messages: [ChatMessage],combine: Bool = true) {
        self.messages = messages
        self.combineForward = combine
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dismissClosure?(self.forwarded)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
        self.view.addSubViews([self.indicator,self.toolBar,self.targetsList])
        // Do any additional setup after loading the view.
        self.targetsList.keyboardDismissMode = .onDrag
        self.fillDatas(refresh: true)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open func fillDatas(refresh: Bool) {
        if refresh {
            if self.index == 0 {
                self.fetchContacts()
            } else {
                self.page = 0
                self.datas.removeAll()
                self.fetchGroups()
            }
        } else {
            if self.index == 1 {
                self.fetchGroups()
            }
        }
    }
   
    open func fetchContacts() {
        if !UserDefaults.standard.bool(forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier) {
            ChatClient.shared().contactManager?.getAllContactsFromServer(completion: { [weak self] contacts, error in
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "EaseChatUIKit_contact_fetch_server_finished"+saveIdentifier)
                    if let contacts = ChatClient.shared().contactManager?.getAllContacts() {
                        self?.datas.removeAll()
                        self?.datas = contacts.map {
                            let profile = ChatUserProfile()
                            profile.id = $0.userId
                            profile.nickname = ChatUIKitContext.shared?.userCache?[$0.userId]?.nickname ?? ""
                            profile.remark = $0.remark ?? ""
                            profile.avatarURL = ChatUIKitContext.shared?.userCache?[$0.userId]?.avatarURL ?? ""
                            return profile
                        }
                        self?.targetsList.reloadData()
                    }
                } else {
                    consoleLogInfo("ForwardTargetViewController fetchContacts error:\(error?.errorDescription ?? "")", type: .error)
                }
            })
        } else {
            let contacts = ChatClient.shared().contactManager?.getAllContacts() ?? []
            self.datas.removeAll()
            self.datas = contacts.map {
                let profile = ChatUserProfile()
                profile.id = $0.userId
                profile.nickname = ChatUIKitContext.shared?.userCache?[$0.userId]?.nickname ?? ""
                profile.remark = $0.remark ?? ""
                profile.avatarURL = ChatUIKitContext.shared?.userCache?[$0.userId]?.avatarURL ?? ""
                return profile
            }
            self.targetsList.reloadData()
        }
    }
    
    open func fetchGroups() {
        ChatClient.shared().groupManager?.getJoinedGroupsFromServer(withPage: self.page, pageSize: self.pageSize, needMemberCount: false, needRole: false, completion: { [weak self] groups, error in
            if error == nil {
                if let groups = groups,let size = self?.pageSize {
                    if groups.count < size {
                        self?.noMoreGroup = true
                    }
                    self?.datas.append(contentsOf: groups.map {
                        let profile = ChatUserProfile()
                        profile.id = $0.groupId
                        profile.nickname = $0.groupName
                        profile.avatarURL = ChatUIKitContext.shared?.groupCache?[$0.groupId]?.avatarURL ?? ""
                        return profile
                    })
                    self?.targetsList.reloadData()
                }
                self?.page += 1
            } else {
                consoleLogInfo("ForwardTargetViewController fetchGroups error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
        
    }
}

extension ForwardTargetViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.searchController.searchBar.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.searchController.searchBar.barStyle = style == .dark ? .black:.default
        self.searchController.searchBar.searchTextField.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.targetsList.reloadData()
    }
    
    
}

extension ForwardTargetViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchMode {
            return self.searchResults.count
        } else {
            return self.datas.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ForwardTargetCell") as? ForwardTargetCell
        if cell == nil {
            cell = ForwardTargetCell(style: .default, reuseIdentifier: "ForwardTargetCell")
        }
        cell?.selectionStyle = .none
        if self.searchMode {
            if let info = self.searchResults[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: self.searchKeyWord, forward: .normal)
            }
        } else {
            if let info = self.datas[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: "", forward: .normal)
            }
        }
        
        cell?.actionClosure = { [weak self] in
            if let forwardIndexPath = tableView.indexPath(for: $0) {
                self?.forwardMessages(indexPath: forwardIndexPath)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.index == 1,indexPath.row > self.datas.count - 2,!self.noMoreGroup {
            self.fetchGroups()
        }
    }
    
    @objc open func forwardMessages(indexPath: IndexPath) {
        var body = self.messages.first?.body ?? ChatMessageBody()
        if self.combineForward {
            body = ChatCombineMessageBody(title: "Chat History".chat.localize, summary: self.forwardSummary(), compatibleText: "[Chat History]", messageIdList: self.messages.filter({ChatClient.shared().chatManager?.getMessageWithMessageId($0.messageId)?.status == .succeed}).map({ $0.messageId }))
        }
        
        var conversationId = ""
        if self.searchMode {
            conversationId = self.searchResults[indexPath.row].id
        } else {
            conversationId = self.datas[indexPath.row].id
        }
        let message =  ChatMessage(conversationID: conversationId, body: body, ext: ChatUIKitContext.shared?.currentUser?.toJsonObject())
        message.chatType = self.index == 0 ? .chat:.groupChat
        ChatClient.shared().chatManager?.send(message, progress: nil, completion: { [weak self] successMessage, error in
            guard let `self` = self else { return }
            if error == nil {
                self.forwarded = true
                if let cell = self.targetsList.cellForRow(at: indexPath) as? ForwardTargetCell {
                    var profile = ChatUserProfile()
                    if let user = (self.searchMode ? self.searchResults:self.datas)[safe: indexPath.row] as? ChatUserProfile {
                        profile = user
                    }
                    cell.refresh(info: profile, keyword: self.searchKeyWord, forward: .forwarded)
                }
            } else {
                consoleLogInfo("ForwardTargetViewController forwardMessages error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func forwardSummary() -> String {
        var summary = ""
        for (index,message) in self.messages.enumerated() {
            if index <= 3 {
                let nickname = message.user?.nickname ?? message.from
                if index == 0 {
                    summary += (nickname+":"+message.showType+"\n")
                } else {
                    if index <= 3 {
                        summary += (nickname+":"+message.showType+"\n")
                    }
                }
            } else {
                break
            }
        }
        return summary
    }
    
}

extension ForwardTargetViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    public func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        self.searchKeyWord = searchController.searchBar.text?.lowercased() ?? ""
        if let searchText = searchController.searchBar.text?.lowercased() {
            self.searchResults = self.datas.filter({ user in
                let showName = user.nickname.isEmpty ? user.id:user.nickname
                return (showName.lowercased() as NSString).range(of: searchText).location != NSNotFound && (showName.lowercased() as NSString).range(of: searchText).length >= 0
            })
        }
        self.targetsList.reloadData()
    }
    
    public func willPresentSearchController(_ searchController: UISearchController) {
        self.searchController = searchController
    }
    
    public func didPresentSearchController(_ searchController: UISearchController) {
        
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    public func didDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    public func presentSearchController(_ searchController: UISearchController) {
        self.searchMode = true
        UIView.animate(withDuration: 0.25) {
            self.indicator.alpha = 0
            self.toolBar.alpha = 0
            self.targetsList.frame = CGRect(x: 0, y: 10, width: self.view.frame.width, height: self.view.frame.height-10)
        }
        self.targetsList.reloadData()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchMode = false
        self.searchResults.removeAll()
        UIView.animate(withDuration: 0.25) {
            self.indicator.alpha = 1
            self.toolBar.alpha = 1
            self.toolBar.frame =  CGRect(x: 0, y: self.indicator.frame.maxY + 4, width: self.view.frame.width, height: 44)
            self.targetsList.frame = CGRect(x: 0, y: self.toolBar.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-self.toolBar.frame.maxY-StatusBarHeight)
        }
        self.targetsList.reloadData()
    }
    
    
}
