//
//  MessageReactionsDetailController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objcMembers open class MessageReactionsDetailController: UIViewController,PresentedViewType {
    
    public var presentedViewComponent: PresentedViewComponent? = PresentedViewComponent(contentSize: Appearance.pageContainerConstraintsSize,destination: .bottomBaseline)
    
    public private(set) var cursor = ""
    
    public private(set) var message = ChatMessage()
    
    public private(set) var reactions: [MessageReaction] = []
    
    public private(set) var users = [ChatUserProfileProtocol]()
    
    public private(set) var selectedReaction = ""
    
    private var needRefresh: (() -> Void)?
    
    public private(set) lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: 63, height: 28)
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 8
        flow.headerReferenceSize = CGSize(width: 16, height: 28)
        flow.footerReferenceSize = CGSize(width: 16, height: 28)
        flow.scrollDirection = .horizontal
        return flow
    }()
    
    
    public private(set) lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.view.frame.width/2.0-18, y: 6, width: 36, height: 5)).cornerRadius(2.5).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    public private(set) lazy var reactionsList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 0, y: self.indicator.frame.maxY+13, width: self.view.frame.width, height: 28), collectionViewLayout: self.layout).backgroundColor(.clear).registerCell(ReactionDetailCell.self, forCellReuseIdentifier: "ReactionDetailCell").dataSource(self).delegate(self).showsHorizontalScrollIndicator(false).showsVerticalScrollIndicator(false)
    }()
    
    public private(set) lazy var reactionUserList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.reactionsList.frame.maxY+8, width: self.view.frame.width, height: self.view.frame.height-60), style: .plain).backgroundColor(.clear).rowHeight(60).separatorStyle(.none).dataSource(self).delegate(self).tableFooterView(UIView())
    }()
    
    @objc required public init(message: ChatMessage,actionClosure: @escaping () -> Void) {
        self.message = message
        self.needRefresh = actionClosure
        super.init(nibName: nil, bundle: nil)
        if let reactionList = message.reactionList {
            reactionList.first?.selected = true
            self.reactions = reactionList
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.indicator,self.reactionsList,self.reactionUserList])
        self.reactionUserList.bounces = false
        self.reactionsList.bounces = false
        if let firstReaction = self.reactions.first?.reaction {
            self.selectedReaction = firstReaction
        }
        self.messageReactionUsers()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc open func messageReactionUsers() {
        if self.selectedReaction.isEmpty {
            consoleLogInfo("selected reaction can't be empty", type: .error)
            return
        }
        if self.cursor.isEmpty {
            self.users.removeAll()
        }
        ChatClient.shared().chatManager?.getReactionDetail(self.message.messageId, reaction: self.selectedReaction, cursor: self.cursor, pageSize: 20, completion: { [weak self] reaction, cursor, error in
            guard let `self` = self else { return }
            if error == nil {
                if let userList = reaction.userList {
                    self.users.append(contentsOf: userList.map({
                        let profile = ChatUserProfile()
                        profile.id = $0
                        if self.message.chatType == .groupChat {
                            var user = ChatUIKitContext.shared?.chatCache?[self.message.from]
                            if $0 == ChatUIKitContext.shared?.currentUserId ?? "" {
                                user = ChatUIKitContext.shared?.currentUser
                            }
                            profile.nickname = user?.nickname ?? ""
                            profile.avatarURL = user?.avatarURL ?? ""
                        } else {
                            var user = ChatUIKitContext.shared?.chatCache?[$0]
                            if $0 == ChatUIKitContext.shared?.currentUserId ?? "" {
                                user = ChatUIKitContext.shared?.currentUser
                            } else {
                                if user == nil {
                                    user = ChatUIKitContext.shared?.userCache?[$0]
                                    if user == nil {
                                        user = ChatUIKitContext.shared?.userCache?[$0]
                                    }
                                }
                            }
                            profile.nickname = user?.nickname ?? ""
                            profile.avatarURL = user?.avatarURL ?? ""
                        }
                        return profile
                    }))
                    let index = self.users.firstIndex { $0.id == ChatUIKitContext.shared?.currentUserId ?? "" }
                    if let idx = index {
                        self.users.remove(at: idx)
                        if let currentUser = ChatUIKitContext.shared?.currentUser {
                            self.users.insert(currentUser, at: 0)
                        }
                    }
                    self.reactionUserList.reloadData()
                }
                self.cursor = cursor ?? ""
            } else {
                consoleLogInfo("get reaction users error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isKind(of: UICollectionView.self) {
            return
        }
        self.requestDisplayInfos()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.requestDisplayInfos()
        }
    }
    
    @objc open func requestDisplayInfos() {
        var unknownInfoIds = [String]()
        if let visiblePaths = self.reactionUserList.indexPathsForVisibleRows {
            for indexPath in visiblePaths {
                if let nickName = self.users[safe: indexPath.row]?.nickname,nickName.isEmpty {
                    if let unknownId = self.users[safe: indexPath.row]?.id {
                        unknownInfoIds.append(unknownId)
                    }
                }
            }
        }
        if ChatUIKitContext.shared?.userProfileProvider != nil {
            if !unknownInfoIds.isEmpty {
                Task {
                    let profiles = await ChatUIKitContext.shared?.userProfileProvider?.fetchProfiles(profileIds: unknownInfoIds) ?? []
                    self.fillCache(profiles: profiles)
                    DispatchQueue.main.async {
                        self.processCacheProfiles(values: profiles)
                    }
                }
            }
        } else {
            ChatUIKitContext.shared?.userProfileProviderOC?.fetchProfiles(profileIds: unknownInfoIds, completion: { [weak self] profiles in
                guard let `self` = self else { return }
                self.fillCache(profiles: profiles)
                self.processCacheProfiles(values: profiles)
            })
        }
    }
    
    private func fillCache(profiles: [ChatUserProfileProtocol]) {
        for profile in profiles {
            if let profile = ChatUIKitContext.shared?.userCache?[profile.id] {
                profile.nickname = profile.nickname
                profile.remark = profile.remark
                profile.avatarURL = profile.avatarURL
            } else {
                ChatUIKitContext.shared?.userCache?[profile.id] = profile
            }
        }
    }
    
    private func processCacheInfos(values: [String]) {
        for user in self.users {
            for value in values {
                if value == user.id {
                    user.nickname = value
                }
            }
        }
        self.reactionUserList.reloadData()
    }
    
    private func processCacheProfiles(values: [ChatUserProfileProtocol]) {
        for user in self.users {
            for value in values {
                if value.id == user.id {
                    user.nickname = value.nickname
                    user.avatarURL = value.avatarURL
                    user.remark = value.remark
                }
            }
        }
        self.reactionUserList.reloadData()
    }

}


extension MessageReactionsDetailController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.reactions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionDetailCell", for: indexPath) as? ReactionDetailCell
        if let reaction = self.reactions[safe: indexPath.row] {
            cell?.refresh(reaction: reaction)
        }
        return cell ?? ReactionDetailCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 16, height: 28)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 16, height: 28)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        for reaction in self.reactions {
            reaction.selected = false
        }
        collectionView.reloadData()
        if let reaction = self.reactions[safe: indexPath.row] {
            reaction.selected = true
            if let emoji = reaction.reaction {
                self.selectedReaction = emoji
                self.cursor = ""
                self.users.removeAll()
                self.messageReactionUsers()
            }
        }
    }
}

extension MessageReactionsDetailController:UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.users.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ReactionUserCell") as? ReactionUserCell
        if cell == nil {
            cell = ReactionUserCell(style: .default, reuseIdentifier: "ReactionUserCell")
        }
        cell?.selectionStyle = .none
        if let user = self.users[safe: indexPath.row] {
            cell?.refresh(profile: user)
        }
        return cell ?? ReactionUserCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user = self.users[safe: indexPath.row],user.id == ChatUIKitContext.shared?.currentUserId ?? "" {
            ChatClient.shared().chatManager?.removeReaction(self.selectedReaction, fromMessage: self.message.messageId, completion: { [weak self] error in
                guard let `self` = self else { return }
                if error == nil {
                    self.users.removeAll { $0.id == ChatUIKitContext.shared?.currentUserId ?? "" }
                    self.needRefresh?()
                } else {
                    consoleLogInfo("removeReaction error:\(error?.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.users.count - 3 {
            if !self.cursor.isEmpty {
                self.messageReactionUsers()
            }
        }
    }
    
}

extension MessageReactionsDetailController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
    
}
