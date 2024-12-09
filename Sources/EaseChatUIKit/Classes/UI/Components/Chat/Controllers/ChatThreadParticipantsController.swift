//
//  ChatThreadParticipantsController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objcMembers open class ChatThreadParticipantsController: UIViewController {
    
    private var cursor = ""
        
    private var pageSize = 20
    
    private var owner = false
    
    public private(set) var profile = GroupChatThread()
    /**
     The array of participants in the group.
     */
    public private(set) var participants: [ChatUserProfileProtocol] = []
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        self.createNavigation()
    }()
    
    /// Creates and returns a navigation bar for the ChatThreadParticipantsController.
    /// - Returns: An instance of EaseChatNavigationBar.
    @objc open func createNavigation() -> ChatNavigationBar {
        ChatNavigationBar(show: CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),showLeftItem: true, textAlignment: .left ,hiddenAvatar: true).backgroundColor(.clear)
    }

    
    public private(set) lazy var participantsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.height, width: self.view.frame.width, height: self.view.frame.height-self.navigation.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).backgroundColor(.clear).separatorStyle(.none)
    }()
    
    public required init(chatThread: GroupChatThread) {
        self.profile = chatThread
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.participantsList])
        self.navigation.title = "topic_members".chat.localize
        // Do any additional setup after loading the view.
        //click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        self.requestGroupDetail()
        self.fetchParticipants()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        // Do any additional setup after loading the view.
    }
    
    @objc open func requestGroupDetail() {
        ChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.profile.parentId, completion: { [weak self] group, error in
            if error == nil {
                if group?.owner ?? "" == ChatUIKitContext.shared?.currentUserId ?? "" {
                    self?.owner = true
                }
            } else {
                consoleLogInfo("requestGroupDetail error:\(error?.errorDescription ?? "")", type: .error)
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

    open func fetchParticipants() {
        ChatClient.shared().threadManager?.getChatThreadMemberListFromServer(withId: self.profile.threadId, cursor: self.cursor, pageSize: self.pageSize, completion: { [weak self] result, error in
            guard let `self` = self else { return }
            if error == nil {
                if let list = result?.list {
                    if self.cursor.isEmpty {
                        self.participants.removeAll()
                        self.participants = list.map({
                            let profile = ChatUserProfile()
                            let id = $0 as String
                            profile.id = id
                            if let user = ChatUIKitContext.shared?.userCache?[id] {
                                profile.nickname = user.nickname
                            }
                            if let user = ChatUIKitContext.shared?.chatCache?[id] {
                                profile.nickname = user.nickname
                            }
                            
                            return profile
                        })
                    } else {
                        self.participants.append(contentsOf: list.map({
                            let profile = ChatUserProfile()
                            let id = $0 as String
                            profile.id = id
                            if let user = ChatUIKitContext.shared?.userCache?[id] {
                                profile.nickname = user.nickname
                            }
                            if let user = ChatUIKitContext.shared?.chatCache?[id] {
                                profile.nickname = user.nickname
                            }
                            
                            return profile
                        }))
                    }
                }
                self.cursor = result?.cursor ?? ""
                self.participantsList.reloadData()
            } else {
                consoleLogInfo("GroupParticipantsController fetch error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
}

extension ChatThreadParticipantsController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.participants.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cellForRowAt(indexPath: indexPath)
    }
    
    @objc open func cellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        var cell = self.participantsList.dequeueReusableCell(withIdentifier: "GroupParticipantCell") as? GroupParticipantCell
        if cell == nil {
            cell = GroupParticipantCell(displayStyle: .normal, identifier: "GroupParticipantCell")
        }
        if let profile = self.participants[safe: indexPath.row] {
            cell?.refresh(profile: profile, keyword: "")
        }
        cell?.selectionStyle = .none
        return cell ?? GroupParticipantCell()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        var unknownInfoIds = [String]()
//        if let visiblePaths = self.participantsList.indexPathsForVisibleRows {
//            for indexPath in visiblePaths {
//                if let nickName = self.participants[safe: indexPath.row]?.nickname,nickName.isEmpty {
//                    unknownInfoIds.append(self.participants[safe: indexPath.row]?.id ?? "")
//                }
//            }
//        }

        
    }
    
    private func processCacheInfos(values: [String]) {
        for participant in self.participants {
            for value in values {
                if value == participant.id {
                    participant.nickname = value
                }
            }
        }
        self.participantsList.reloadData()
    }
    
    private func processCacheProfiles(values: [ChatUserProfileProtocol]) {
        for participant in self.participants {
            for value in values {
                if value.id == participant.id {
                    participant.nickname = value.nickname
                    participant.avatarURL = value.avatarURL
                }
            }
        }
        self.participantsList.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.owner {
            DialogManager.shared.showActions(actions: [ActionSheetItem(title: "remove_participants".chat.localize, type: .destructive, tag: "RemoveMember")]) { [weak self] item in
                if item.tag == "RemoveMember" {
                    self?.removeMember(user: self?.participants[safe: indexPath.row] ?? ChatUserProfile())
                }
            }
        }
    }
                                                   
    open func removeMember(user: ChatUserProfileProtocol) {
        ChatClient.shared().threadManager?.removeMember(fromChatThread: user.id, threadId: self.profile.threadId, completion: { error in
            if error == nil {
                self.participants.removeAll(where: { $0.id == user.id })
                self.participantsList.reloadData()
            } else {
                consoleLogInfo("GroupParticipantsController remove error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= self.participants.count-3,self.cursor.isEmpty {
            self.fetchParticipants()
        }
    }
}

extension ChatThreadParticipantsController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
