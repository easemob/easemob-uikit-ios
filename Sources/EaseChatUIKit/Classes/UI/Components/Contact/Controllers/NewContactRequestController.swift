//
//  NewRequestViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objc open class NewContactRequestController: UIViewController {
        
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Double>()) private var newFriends
    
    private let contactService = ContactServiceImplement()
    
    public private(set) lazy var datas: [NewContactRequest] = {
        self.fillDatas()
    }()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        self.createNavigation()
    }()
    
    @objc open func createNavigation() -> EaseChatNavigationBar {
        EaseChatNavigationBar( showLeftItem: true, textAlignment: .left, hiddenAvatar: true)
    }
    
    public private(set) lazy var requestList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height), style: .plain).tableFooterView(UIView()).delegate(self).dataSource(self).rowHeight(Appearance.contact.rowHeight).backgroundColor(.clear).separatorStyle(.none)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.requestList.frame.width, height: self.requestList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: {
            
        }).backgroundColor(.clear)
    }()
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.title = "New Request".chat.localize
        self.datas.sort { $0.time > $1.time }
        self.view.addSubViews([self.navigation,self.requestList])
        // Do any additional setup after loading the view.
        //Back button click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        if self.datas.count <= 0 {
            self.requestList.backgroundView = self.empty
        } else {
            self.requestList.backgroundView = nil
        }
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc open func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        default: break
        }
    }
    
    @objc open func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc open func fillDatas() -> [NewContactRequest] {
        self.newFriends.map {
            let request = NewContactRequest()
            request.userId = $0.key
            request.time = $0.value
            return request
        }
    }
    
}

extension NewContactRequestController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cellForRowAt(indexPath: indexPath)
    }
    
    @objc open func cellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        var cell = self.requestList.dequeueReusableCell(withIdentifier: "NewContactRequestCell") as? NewContactRequestCell
        if cell == nil {
            cell = NewContactRequestCell(style: .default, reuseIdentifier: "NewContactRequestCell")
        }
        if let request = self.datas[safe: indexPath.row] {
            cell?.refresh(request: request)
        }
        cell?.agreeClosure = { [weak self] in
            self?.agreeFriendRequest(userId: $0)
        }
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell ?? NewContactRequestCell()
    }
    
    /**
     Agrees to a friend request from a user.

     - Parameters:
         - userId: The ID of the user who sent the friend request.

     This method sends a request to the contact service to agree to the friend request from the specified user. If the request is successful, the user is added as a new friend and a chat conversation is created. The conversation includes a custom message with a greeting.

     - Note: This method assumes that the `contactService` property is already initialized.

     - Parameter userId: The ID of the user who sent the friend request.
     */
    @objc open func agreeFriendRequest(userId: String) {
        self.contactService.agreeFriendRequest(from: userId) { error, userId in
            if error != nil,error?.code == .userAlreadyLoginAnother {
                consoleLogInfo("agreeFriendRequest error: \(error?.errorDescription ?? "")", type: .error)
            } else {
                self.newFriends.removeValue(forKey: userId)
                let conversation = ChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true)
                let ext = ["something":("You have added".chat.localize+" "+userId+" "+"to say hello".chat.localize)]
                let message = ChatMessage(conversationID: userId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
                conversation?.insert(message, error: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "New Friend Chat") , object: nil, userInfo: nil)
                self.datas.removeAll()
                self.datas = self.fillDatas()
                self.datas.sort { $0.time > $1.time }
                if self.datas.count <= 0 {
                    self.requestList.backgroundView = self.empty
                } else {
                    self.requestList.backgroundView = nil
                }
                
                self.requestList.reloadData()
            }
        }
    }
}


extension NewContactRequestController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
