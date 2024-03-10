//
//  SearchHistoryMessagesViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/15.
//

import UIKit

@objcMembers open class SearchHistoryMessagesViewController: UITableViewController {

    private var searchKeyWord = ""
    
    public var rawDatas = [ChatMessage]()
    
    private var selectClosure: ((ChatMessage) -> Void)?
    
    private var service: ChatService?
    
    public private(set) var searchResults = [ChatMessage]()
    
    public private(set) lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.showsCancelButton = true
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
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil)) {
            
        }
    }()
    
    /// ``SearchHistoryMessagesViewController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - conversationId: ID of the conversation.
    ///   - action: Select row callback.
    @objc public required init(conversationId: String,action: @escaping (ChatMessage) -> Void) {
        self.service = ChatServiceImplement(to: conversationId)
        self.selectClosure = action
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.searchController.isActive = false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView(UIView()).rowHeight(Appearance.contact.rowHeight).tableHeaderView(self.searchController.searchBar)
        self.tableView.keyboardDismissMode = .onDrag
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    

    // MARK: - Table view data source

    open override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.searchResults.count <= 0 {
            self.tableView.backgroundView = self.empty
        } else {
            self.tableView.backgroundView = nil
        }
        return self.searchResults.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "EaseUIKit_SearchHistoryMessageCell") as? SearchHistoryMessageCell
        if cell == nil {
            cell = SearchHistoryMessageCell(style: .default, reuseIdentifier: "EaseUIKit_SearchHistoryMessageCell")
        }
        if let item = self.searchResults[safe: indexPath.row] {
            let conversation = EaseChatUIKitContext.shared?.conversationsCache?[item.conversationId]
            let info = ConversationInfo()
            info.id = item.conversationId
            info.nickname = conversation?.nickname ?? item.conversationId
            cell?.refresh(message: item,info: info,keyword: self.searchKeyWord)
        }
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        return cell ?? UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
//        self.searchController.isActive = false
        if let item = self.searchResults[safe: indexPath.row] {
            let vc = SearchResultMessagesController(conversationId: item.conversationId, chatType: item.chatType == .chat ? .chat:.group, searchMessageId: item.messageId)
            self.navigationController?.pushViewController(vc, animated: true)
//            self.selectClosure?(item)
        }
        self.tableView.reloadData()
    }

}


extension SearchHistoryMessagesViewController: UISearchResultsUpdating,UISearchControllerDelegate,UISearchBarDelegate {

    public func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        self.searchKeyWord = searchText
        self.service?.searchMessage(keyword: self.searchKeyWord, pageSize: 999, userId: "", completion: { [weak self] error, messages in
            if error == nil {
                self?.rawDatas.removeAll()
                self?.rawDatas.append(contentsOf: messages)
                self?.filterResultsWithSearchString(searchText)
            } else {
                consoleLogInfo("search message error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
        
    }
    
    @objc open func filterResultsWithSearchString(_ searchText: String) {
        self.searchResults = self.rawDatas.filter({ message in
            let showName = message.showType
            return (showName.lowercased() as NSString).range(of: searchText).location != NSNotFound && (showName.lowercased() as NSString).range(of: searchText).length >= 0 && message.body.type == .text
        })
        self.tableView.reloadData()
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
        
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension SearchHistoryMessagesViewController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.searchController.searchBar.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.searchController.searchBar.barStyle = style == .dark ? .black:.default
        self.tableView.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.tableView.reloadData()
    }
    
    
}
