//
//  GroupParticipantsRemoveController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/27.
//

import UIKit

@objc open class GroupParticipantsRemoveController: UIViewController {
    
    public let service: GroupService = GroupServiceImplement()
    
    private var deleteClosure: (([String]) -> Void)?
    
    public private(set) var chatGroup = ChatGroup()
    
    public var participants: [ChatUserProfileProtocol] = []
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        self.createNavigation()
    }()
    
    @objc open func createNavigation() -> ChatNavigationBar {
        ChatNavigationBar(textAlignment: .left,rightTitle: "conversation_left_slide_menu_delete".chat.localize)
    }
    
    public private(set) lazy var participantsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-self.navigation.frame.maxY), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(60).backgroundColor(.clear).separatorStyle(.none)
    }()
    
    @objc required public init(group: ChatGroup,profiles: [ChatUserProfileProtocol],removeClosure: @escaping ([String]) -> Void) {
        self.chatGroup = group
        profiles.forEach { $0.selected = false }
        self.participants = profiles
        self.deleteClosure = removeClosure
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigation.title = "remove_participants".chat.localize
        self.navigation.rightItem.textColor(UIColor.theme.errorColor5, .normal)
        self.navigation.rightItem.title("Remove".chat.localize, .normal)
        self.navigation.rightItem.isEnabled = false
        self.view.addSubViews([self.participantsList,self.navigation])
        // Do any additional setup after loading the view.
        //Back button click of the navigation
        
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
    
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc open func navigationClick(type: ChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightTitle: self.rightAction()
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

    @objc open func rightAction() {
        let userIds = self.participants.filter { $0.selected == true }.map { $0.id }
        let nickNames = self.participants.filter { $0.selected == true }.map { $0.nickname }
        var removeAlert = "\("group_delete_members_alert".chat.localize) \(userIds.count) \("group members".chat.localize) "
        if nickNames.count > 1 {
            removeAlert += "\(nickNames.first ?? "") , \(nickNames[1])"
        } else {
            removeAlert += "\(nickNames.first ?? "")"
        }
        DialogManager.shared.showAlert(title: "", content: removeAlert, showCancel: true, showConfirm: true) { [weak self] _ in
            guard let `self` = self else { return }
            self.service.remove(userIds: userIds, from: self.chatGroup.groupId) { [weak self] group, error in
                if error != nil {
                    consoleLogInfo("\(error?.errorDescription ?? "")", type: .error)
                } else {
                    self?.deleteClosure?(userIds)
                    self?.pop()
                }
            }
        }
        
    }

}

extension GroupParticipantsRemoveController: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.participants.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.cellForRowAt(indexPath: indexPath)
    }
    
    @objc open func cellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        var cell = self.participantsList.dequeueReusableCell(withIdentifier: "GroupParticipantsSelectCell") as? GroupParticipantsSelectCell
        if cell == nil {
            cell = GroupParticipantsSelectCell(style: .default, reuseIdentifier: "GroupParticipantsSelectCell")
        }
        if let profile = self.participants[safe: indexPath.row] {
            cell?.refresh(profile: profile, keyword: "")
        }
        cell?.selectionStyle = .none
        return cell ?? GroupParticipantCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.didSelectRowAt(indexPath: indexPath)
    }
    
    @objc open func didSelectRowAt(indexPath: IndexPath) {
        if let profile = self.participants[safe: indexPath.row] {
            profile.selected = !profile.selected
            self.participantsList.reloadData()
        }
        let count = self.participants.filter({ $0.selected }).count
        if count > 0 {
            self.navigation.rightItem.isEnabled = true
            self.navigation.rightItem.title("Remove".chat.localize+"(\(count))", .normal)
        } else {
            self.navigation.rightItem.title("Remove".chat.localize, .normal)
            self.navigation.rightItem.isEnabled = false
        }
    }
}

extension GroupParticipantsRemoveController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
