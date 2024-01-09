//
//  GroupInfoViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/24.
//

import UIKit

@objc open class GroupInfoViewController: UIViewController {
    
    private var editIndex = IndexPath(row: 1, section: 0)
    
    private var chatGroup = ChatGroup()
    
    private let service: GroupService = GroupServiceImplement()
    
    private let ownerOptions = [ActionSheetItem(title: "group_details_extend_button_disband".chat.localize, type: .destructive, tag: "disband_group"),ActionSheetItem(title: "group_details_extend_button_transfer".chat.localize, type: .destructive, tag: "transfer_owner")]
    
    private let memberOptions = [ActionSheetItem(title: "group_details_extend_button_leave".chat.localize, type: .destructive, tag: "quit_group")]
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true, textAlignment: .left, rightImages: self.chatGroup.isDisabled ? []:[UIImage(named: "more_detail", in: .chatBundle, with: nil)!] ,hiddenAvatar: true).backgroundColor(.clear)
    }()
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    private lazy var jsons: [[Dictionary<String,Any>]] = {
        [[["title":"group_details_button_members".chat.localize,"detail":"\(self.chatGroup.occupantsCount)","withSwitch": false,"switchValue":false],["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.chatGroup.groupId] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]],[["title":"group_details_button_name".chat.localize,"detail":"\(String(describing: self.chatGroup.groupName ?? ""))","withSwitch": false,"switchValue":false],["title":"group_details_button_description".chat.localize,"detail":self.chatGroup.description ?? "group_details_button_description".chat.localize,"withSwitch": false,"switchValue":false]]]
    }()
    
    public private(set) lazy var datas: [[DetailInfo]] = {
        self.jsons.map {
            $0.map {
                let info = DetailInfo()
                info.setValuesForKeys($0)
                return info
            }
        }
    }()
    
    public private(set) lazy var header: DetailInfoHeader = {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 284), showMenu: true, placeHolder: UIImage(named: "group", in: .chatBundle, with: nil)).backgroundColor(.clear)
    }()
    
    public private(set) lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).tableHeaderView(self.header).sectionHeaderHeight(30).backgroundColor(.clear)
    }()
    
    @objc public var nameClosure: ((String,String) -> Void)?
    
    @objc required public init(group: String,nameChanged: @escaping (String,String) -> Void) {
        self.nameClosure = nameChanged
        self.chatGroup = ChatGroup(id: group)
        super.init(nibName: nil, bundle: nil)
        self.fetchGroupInfo(groupId: group)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchGroupInfo(groupId: String) {
        self.service.fetchGroupInfo(groupId: groupId) { [weak self] group, error in
            guard let `self` = self else { return }
            if error == nil, let group = group {
                self.chatGroup = group
            } else {
                self.chatGroup = ChatGroup(id: groupId)
            }
            let showName = self.chatGroup.groupName.isEmpty ? groupId:self.chatGroup.groupName
            self.header.nickName.text = showName
            self.header.userState = .offline
            self.header.detailText = groupId
            self.menuList.reloadData()
        }
        let userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
        EaseChatUIKitContext.shared?.groupMemberAttributeCache?.fetchCacheValue(groupId: groupId, userIds: [userId], key: "nickname", completion: { [weak self] error, attributes in
            if error == nil,let nickname = attributes?.first {
                self?.fillAlias(nickname: nickname)
            } else {
                consoleLogInfo("fetchMembersAttribute  nickname error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    private func fillAlias(nickname: String) {
        for sections in self.datas {
            for row in sections {
                if row.title == "group_details_button_alias".chat.localize {
                    row.detail = nickname
                    self.menuList.reloadData()
                    return
                }
            }
        }
    }
    
    @MainActor @objc public func updateUserState(state: UserState) {
        self.header.userState = state
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.view.addSubViews([self.navigation,self.menuList])
        // Do any additional setup after loading the view.
        //click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        self.headerActions()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func headerActions() {
        if let chat = Appearance.contact.detailExtensionActionItems.first(where: { $0.featureIdentify == "Chat" }) {
            chat.actionClosure = { [weak self] _ in
                self?.alreadyChat()
            }
        }
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    private func alreadyChat() {
        ChatClient.shared().chatManager?.ackConversationRead(self.chatGroup.groupId)
        if let count = self.navigationController?.viewControllers.count {
            if self.navigationController?.viewControllers[safe: count - 2] is MessageListController {
                if let root = self.navigationController?.viewControllers[safe: count - 3] {
                    self.navigationController?.popToViewController(root, animated: true)
                    ControllerStack.toDestination(vc: ComponentsRegister.shared.MessageViewController.init(conversationId: self.chatGroup.groupId,chatType: .group))
                }
            } else {
                ControllerStack.toDestination(vc: ComponentsRegister.shared.MessageViewController.init(conversationId: self.chatGroup.groupId,chatType: .group))
            }
        } else {
            if let presentingVC = self.presentingViewController {
                if presentingVC is MessageListController {
                    presentingVC.dismiss(animated: false) {
                        UIViewController.currentController?.present(ComponentsRegister.shared.MessageViewController.init(conversationId: self.chatGroup.groupId,chatType: .group), animated: true)
                    }
                } else {
                    let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: self.chatGroup.groupId,chatType: .group)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            } else {
                let desiredViewController = ComponentsRegister.shared.MessageViewController.init(conversationId: self.chatGroup.groupId,chatType: .group)
                ControllerStack.toDestination(vc: desiredViewController)
            }
            
        }
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: self.chatGroup.permissionType == .owner ? self.ownerOptions:self.memberOptions) { [weak self] item in
                guard let `self` = self else { return }
                switch item.tag {
                case "disband_group": self.disband()
                case "transfer_owner": self.transfer()
                case "quit_group": self.leave()
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    private func disband() {
        DialogManager.shared.showAlert(title: "group_details_extend_button_disband_alert_title".chat.localize, content: "group_details_extend_button_disband_alert_subtitle".chat.localize, showCancel: true, showConfirm: true) { [weak self] _ in
            self?.service.disband(groupId: self?.chatGroup.groupId ?? "") { error in
                if error == nil {
                    NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_leaveGroup"), object: self?.chatGroup.groupId ?? "")
                    self?.pop()
                } else {
                    consoleLogInfo("disband error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
        
    }
    
    private func transfer() {
        let vc =
        ComponentsRegister.shared.GroupParticipantController.init(groupId: self.chatGroup.groupId, operation: .transferOwner)
        vc.mentionClosure = { [weak self] in
            self?.transferConfirm(profile: $0)
        }
        ControllerStack.toDestination(vc: vc)
    }
    
    private func transferConfirm(profile: EaseProfileProtocol) {
        DialogManager.shared.showAlert(title: "", content: "group_details_extend_button_transfer".chat.localize+"to ".chat.localize+"\(profile.nickname)?", showCancel: true, showConfirm: true) { [weak self] text in
            guard let `self` = self else { return }
            self.service.transfer(groupId: self.chatGroup.groupId, userId: profile.id, completion: { group, error in
                if error == nil {
                    NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_leaveGroup"), object: profile.id)
                    self.pop()
                } else {
                    consoleLogInfo("transfer owner error:\(error?.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    private func leave() {
        DialogManager.shared.showAlert(title: "group_details_extend_button_leave_alert_title".chat.localize, content: "group_details_extend_button_leave_alert_subtilte".chat.localize, showCancel: true, showConfirm: true) { [weak self] _ in
            self?.service.leave(groupId: self?.chatGroup.groupId ?? "") { error in
                if error == nil {
                    self?.pop()
                } else {
                    consoleLogInfo("disband error:\(error?.errorDescription ?? "")", type: .error)
                }
            }
        }
        
    }

}


extension GroupInfoViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        self.datas.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas[safe: section]?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        section <= 0 ? UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30)).backgroundColor(Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95):nil
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoListCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "DetailInfoListCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.section]?[safe: indexPath.row] {
            cell?.refresh(info: info)
        }
        cell?.switchMenu.isEnabled = !self.chatGroup.isDisabled
        cell?.valueChanged = { [weak self] in
            self?.switchChanged(isOn: $0, indexPath: $1)
        }
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let info = self.datas[safe: indexPath.section]?[safe: indexPath.row] {
            self.editIndex = indexPath
            switch info.title {
            case "group_details_button_name".chat.localize: self.edit(type: .name, detail: info.detail)
            case "group_details_button_alias".chat.localize: self.edit(type: .alias, detail: info.detail)
            case "group_details_button_members".chat.localize: self.viewParticipants()
            case "group_details_button_description".chat.localize: self.edit(type: .description, detail: info.detail)
            case "contact_details_button_clearchathistory".chat.localize: self.cleanHistoryMessages()
            default:
                break
            }
        }
        
    }
    
    private func viewParticipants() {
        let vc = ComponentsRegister.shared.GroupParticipantController.init(groupId: self.chatGroup.groupId)
        ControllerStack.toDestination(vc: vc)
    }
    
    private func cleanHistoryMessages() {
        ChatClient.shared().chatManager?.getConversationWithConvId(self.chatGroup.groupId)?.deleteAllMessages(nil)
        NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_clean_history_messages"), object: self.chatGroup.groupId)
    }
    
    private func edit(type: GroupInfoEditType,detail: String) {
        if self.chatGroup.isDisabled {
            DialogManager.shared.showAlert(title: "", content: "Group was disabled".chat.localize, showCancel: false, showConfirm: true) { _ in
                
            }
            return
        }
        let vc = GroupInfoEditViewController(groupId: self.chatGroup.groupId, type: type, rawText: detail) { [weak self] result in
            self?.handleEditCallback(text: result, type: type)
        }
        ControllerStack.toDestination(vc: vc)
    }
    
    private func handleEditCallback(text: String,type: GroupInfoEditType) {
        if type == .name {
            self.nameClosure?(self.chatGroup.groupId,text)
            EaseChatUIKitContext.shared?.onGroupNameUpdated?(self.chatGroup.groupId,text)
            self.header.nickName.text = text
        }
        self.datas[safe: self.editIndex.section]?[safe: self.editIndex.row]?.detail = text
        self.menuList.reloadRows(at: [self.editIndex], with: .fade)
    }
    
    private func switchChanged(isOn: Bool,indexPath: IndexPath) {
        if let name = self.datas[safe: indexPath.section]?[safe: indexPath.row]?.title {
            self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.chatGroup.groupId] = isOn ? 1:0
            if name == "contact_details_switch_donotdisturb".chat.localize {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "EaseUIKit_do_not_disturb_changed"), object: nil,userInfo: ["id":self.chatGroup.groupId ?? "","value":isOn])
            }
        }
    }
}

extension GroupInfoViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}
