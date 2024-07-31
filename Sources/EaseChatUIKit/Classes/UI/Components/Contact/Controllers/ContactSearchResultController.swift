//
//  ContactSearchResultController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objcMembers open class ContactSearchResultController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private var searchText = ""
    
    public var rawDatas = [EaseProfileProtocol]() {
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
    
    private var selectClosure: ((EaseProfileProtocol) -> Void)?
    
    private var service: ContactServiceProtocol = ContactServiceImplement()
    
    public private(set) var searchResults = [EaseProfileProtocol]()
    
    private var active = false {
        didSet {
            if self.active == false {
                self.searchResults.removeAll()
            }
        }
    }
    
    
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
    
    public private(set) var headerStyle = ContactListHeaderStyle.contact
    
    
    /// ``ContactListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``
    ///   - action: Select row callback.
    @objc public required init(headerStyle: ContactListHeaderStyle = .contact,action: @escaping (EaseProfileProtocol) -> Void) {
        self.headerStyle = headerStyle
        self.selectClosure = action
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.view.addSubViews([self.searchHeader,self.searchList])
        self.searchList.keyboardDismissMode = .onDrag
        self.loadAllContacts()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.searchHeader.textChanged = { [weak self] in
            guard let `self` = self else { return }
            self.searchText = $0.lowercased()
            self.searchResults = self.rawDatas.filter({ $0.nickname.lowercased().contains(self.searchText) || $0.id.lowercased().contains(self.searchText) || $0.remark.contains(self.searchText) })
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
    
    @objc public func loadAllContacts() {
        self.service.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                let infos = contacts.map({
                    let profile = EaseProfile()
                    profile.id = $0.userId
                    profile.nickname = EaseChatUIKitContext.shared?.userCache?[$0.userId]?.nickname ?? ""
                    profile.avatarURL = EaseChatUIKitContext.shared?.userCache?[$0.userId]?.avatarURL ?? ""
                    profile.remark = EaseChatUIKitContext.shared?.userCache?[$0.userId]?.remark ?? ""
                    return profile
                })
                self?.rawDatas.removeAll()
                self?.searchResults.removeAll()
                self?.rawDatas = infos
            } else {
                consoleLogInfo("ContactSearchResultController loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.active ? self.searchResults.count:self.rawDatas.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(with: ComponentsRegister.shared.ContactsCell.self, reuseIdentifier: "EaseUIKit_ContactsCell_Search")
        if cell == nil {
            cell = ComponentsRegister.shared.ContactsCell.init(displayStyle: (self.headerStyle == .newGroup || self.headerStyle == .addGroupParticipant) ? .withCheckBox:.normal,identifier: "EaseUIKit_ContactsCell_Search")
        }
        cell?.backgroundColor = .clear
        if self.active {
            if let info = self.searchResults[safe: indexPath.row] {
                cell?.refresh(profile: info, keyword: self.searchText)
            }
        } else {
            if let info = self.rawDatas[safe: indexPath.row] {
                cell?.refresh(profile: info, keyword: self.searchText)
            }
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.active {
            if let info = self.searchResults[safe: indexPath.row] {
                self.selectClosure?(info)
            }
        } else {
            if let info = self.rawDatas[safe: indexPath.row] {
                self.selectClosure?(info)
            }
        }
    }
}


extension ContactSearchResultController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.searchList.reloadData()
    }
}
