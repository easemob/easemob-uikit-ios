//
//  NewRequestViewController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objc open class NewContactRequestController: UIViewController {
        
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Array<Dictionary<String,Any>>>()) private var newFriends
    
    public let contactService = ContactServiceImplement()
    
    public lazy var datas: [NewContactRequest] = {
        self.fillDatas()
    }()
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        self.createNavigation()
    }()
    
    @objc open func createNavigation() -> ChatNavigationBar {
        ChatNavigationBar( showLeftItem: true, textAlignment: .left, hiddenAvatar: true)
    }
    
    public private(set) lazy var requestList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height), style: .plain).tableFooterView(UIView()).delegate(self).dataSource(self).rowHeight(Appearance.contact.rowHeight).backgroundColor(.clear).separatorStyle(.none)
    }()
    
    public private(set) lazy var empty: EmptyStateView = {
        EmptyStateView(frame: CGRect(x: 0, y: 0, width: self.requestList.frame.width, height: self.requestList.frame.height),emptyImage: UIImage(named: "empty",in: .chatBundle, with: nil), onRetry: {
            
        }).backgroundColor(.clear)
    }()
    

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
        self.requestProfiles()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc open func requestProfiles() {
        if ChatUIKitContext.shared?.userProfileProvider != nil {
            let userIds = self.datas.map { $0.userId }
            Task(priority: .background) {
                let profiles = await ChatUIKitContext.shared?.userProfileProvider?.fetchProfiles(profileIds: userIds) ?? []
                for profile in profiles {
                    if let info = self.datas.first(where: { $0.userId == profile.id }) {
                        info.nickname = profile.nickname
                        info.avatarURL = profile.avatarURL
                    }
                }
                DispatchQueue.main.async {
                    self.requestList.reloadData()
                }
            }
        } else {
            if ChatUIKitContext.shared?.userProfileProviderOC != nil {
                ChatUIKitContext.shared?.userProfileProviderOC?.fetchProfiles(profileIds: self.datas.map { $0.userId }, completion: { [weak self] profiles in
                    for profile in profiles {
                        if let info = self?.datas.first(where: { $0.userId == profile.id }) {
                            info.nickname = profile.nickname
                            info.avatarURL = profile.avatarURL
                        }
                    }
                    DispatchQueue.main.async {
                        self?.requestList.reloadData()
                    }
                })
            }
        }
    }
    
    @objc open func navigationClick(type: ChatNavigationBarClickEvent,indexPath: IndexPath?) {
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
        self.newFriends[saveIdentifier]?.map {
            let request = NewContactRequest()
            request.userId = ($0["userId"] as? String) ?? ""
            request.time = ($0["timestamp"] as? TimeInterval) ?? 0
            request.avatarURL = ChatUIKitContext.shared?.userCache?[request.userId]?.avatarURL ?? ""
            request.nickname = ChatUIKitContext.shared?.userCache?[request.userId]?.nickname ?? ""
            return request
        } ?? []
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var unknownInfoIds = [String]()
        var unknownInfoMaps = [String:IndexPath]()
        if let visiblePaths = self.requestList.indexPathsForVisibleRows {
            for indexPath in visiblePaths {
                if let nickName = self.datas[safe: indexPath.row]?.nickname,nickName.isEmpty {
                    unknownInfoIds.append(self.self.datas[safe: indexPath.row]?.userId ?? "")
                    unknownInfoMaps[self.datas[safe: indexPath.row]?.userId ?? ""] = indexPath
                }
                if let avatarURL = self.datas[safe: indexPath.row]?.avatarURL,avatarURL.isEmpty {
                    unknownInfoIds.append(self.self.datas[safe: indexPath.row]?.userId ?? "")
                    unknownInfoMaps[self.datas[safe: indexPath.row]?.userId ?? ""] = indexPath
                }
            }
        }
        
        if ChatUIKitContext.shared?.userProfileProvider != nil {
            Task(priority: .background) {
                let profiles = await ChatUIKitContext.shared?.userProfileProvider?.fetchProfiles(profileIds: unknownInfoIds) ?? []
                self.refreshProfiles(profiles: profiles, unknownInfoMaps: unknownInfoMaps)
            }
        } else {
            ChatUIKitContext.shared?.userProfileProviderOC?.fetchProfiles(profileIds: unknownInfoIds, completion: { [weak self] profiles in
                self?.refreshProfiles(profiles: profiles, unknownInfoMaps: unknownInfoMaps)
            })
        }
    }
    
    @objc open func refreshProfiles(profiles: [ChatUserProfileProtocol],unknownInfoMaps: [String:IndexPath]) {
        var refreshIndexPaths = [IndexPath]()
        for profile in profiles {
            if let indexPath = unknownInfoMaps[profile.id] {
                self.datas[indexPath.row].nickname = profile.nickname
                self.datas[indexPath.row].avatarURL = profile.avatarURL
                refreshIndexPaths.append(indexPath)
            }
        }
        DispatchQueue.main.async {
            self.requestList.reloadRows(at: refreshIndexPaths, with: .none)
        }
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
        self.contactService.agreeFriendRequest(from: userId) { [weak self] error, userId in
            guard let self = self else { return }
            if error != nil,error?.code == .userAlreadyLoginAnother {
                consoleLogInfo("agreeFriendRequest error: \(error?.errorDescription ?? "")", type: .error)
            } else {
                self.newFriends[saveIdentifier]?.removeAll { ($0["userId"] as? String) ?? "" == userId }
                let conversation = ChatClient.shared().chatManager?.getConversation(userId, type: .chat, createIfNotExist: true)
                let ext = ["something":("You have added".chat.localize+" "+userId+" "+"to say hello".chat.localize)]
                let message = ChatMessage(conversationID: userId, body: ChatCustomMessageBody(event: EaseChatUIKit_alert_message, customExt: nil), ext: ext)
                conversation?.insert(message, error: nil)
                
                self.datas.removeAll()
                self.datas = self.fillDatas()
                self.datas.sort { $0.time > $1.time }
                if self.datas.count <= 0 {
                    self.requestList.backgroundView = self.empty
                } else {
                    self.requestList.backgroundView = nil
                }
                self.requestFriendInfo(userId: userId)
                self.requestList.reloadData()
            }
        }
    }
    
    @objc open func requestFriendInfo(userId: String) {
        ChatClient.shared().userInfoManager?.fetchUserInfo(byId: [userId], type: [0,1],completion: { infoMap, error in
            if error != nil {
                consoleLogInfo("requestFriendInfo error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
}


extension NewContactRequestController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
