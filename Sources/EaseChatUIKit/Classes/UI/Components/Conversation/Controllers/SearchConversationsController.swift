//
//  SearchConversationController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/14.
//

import UIKit

@objc open class SearchConversationsController: UIViewController {
    
    private var active = false {
        didSet {
            if self.active == false {
                self.searchResults.removeAll()
            }
        }
    }
    
    private var datas: [ConversationInfo] = []  {
        didSet {
            DispatchQueue.main.async {
                if self.datas.count <= 0  {
                    self.searchList.backgroundView = self.empty
                } else {
                    self.searchList.backgroundView = nil
                }
            }
        }
    }
    
    private var searchResults: [ConversationInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                if self.active {
                    if self.searchResults.count <= 0  {
                        self.searchList.backgroundView = self.empty
                    } else {
                        self.searchList.backgroundView = nil
                    }
                }
            }
        }
    }
    
    private var searchText = ""
    
    private var chatClosure: ((ConversationInfo) -> Void)?
    
    public private(set) lazy var searchHeader: SearchHeaderBar = {
        SearchHeaderBar(frame: CGRect(x: 0, y: StatusBarHeight+10, width: ScreenWidth, height: 44), displayStyle: .other).backgroundColor(.clear)
    }()
    
    public private(set) lazy var searchList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.searchHeader.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.searchHeader.frame.maxY-BottomBarHeight-10), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).separatorStyle(.none).rowHeight(Appearance.conversation.rowHeight).backgroundColor(.clear)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.searchList.frame.width, height: self.searchList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil)) {
            
        }
    }()
    
    @objc(initWithSearchInfos:toChat:)
    public required init(searchInfos: [ConversationInfo],toChat: @escaping (ConversationInfo) -> Void) {
        self.datas = searchInfos
        self.chatClosure = toChat
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.view.addSubViews([self.searchHeader,self.searchList])
        self.searchList.keyboardDismissMode = .onDrag
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.searchHeader.textChanged = { [weak self] in
            guard let `self` = self else { return }
            self.searchText = $0.lowercased()
            self.searchResults = self.datas.filter({ $0.nickname.lowercased().contains(self.searchText) || $0.id.lowercased().contains(self.searchText) || $0.remark.lowercased().contains(self.searchText)})
            self.searchList.reloadData()
        }
        self.searchHeader.textFieldState = { [weak self] in
            self?.active = $0 == .began
        }
        self.searchHeader.actionClosure = { [weak self] in
            self?.active = false
            self?.searchText = ""
            self?.searchList.reloadData()
            if $0 == .cancel {
                self?.pop()
            }
        }
        
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchHeader.searchField.becomeFirstResponder()
    }

}

extension SearchConversationsController: UITableViewDelegate,UITableViewDataSource {
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.active ? self.searchResults.count:self.datas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ConversationSearchCell") as? ConversationSearchCell
        if cell == nil {
            cell = ConversationSearchCell(style: .default, reuseIdentifier: "ConversationSearchCell")
        }
        if self.active {
            if let info = self.searchResults[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: self.searchText)
            }
        } else {
            if let info = self.datas[safe: indexPath.row] {
                cell?.refresh(info: info, keyword: self.searchText)
            }
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.active {
            if let info = self.searchResults[safe: indexPath.row] {
                self.chatClosure?(info)
            }
        } else {
            if let info = self.datas[safe: indexPath.row] {
                self.chatClosure?(info)
            }
        }
    }
    
}

extension SearchConversationsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.searchList.reloadData()
    }
}
