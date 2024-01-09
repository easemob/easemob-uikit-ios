//
//  ContactInfoViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

@objc open class ContactInfoViewController: UIViewController {
    
    public let service = ContactServiceImplement()
    
    public private(set) var profile: EaseProfileProtocol = EaseProfile()
    
    @objc public var removeContact: (() -> Void)?
    
    private var contacts = [String]()
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    public private(set) lazy var datas: [DetailInfo] = {
        [["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.profile.id] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]].map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(showLeftItem: true,rightImages: self.showMenu ? [UIImage(named: "more_detail", in: .chatBundle, with: nil)!]:[],hiddenAvatar: true)
    }()
    
    public private(set) lazy var header: DetailInfoHeader = {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 264), showMenu: self.showMenu, placeHolder: UIImage(named: "single", in: .chatBundle, with: nil)).backgroundColor(.clear)
    }()
    
    lazy var showMenu: Bool = {
        if self.profile.id == EaseChatUIKitContext.shared?.currentUserId ?? "" {
            return false
        } else {
            if !self.contacts.contains(self.profile.id) {
                return false
            }
            return true
        }
    }()
    
    public private(set) lazy var addContact: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 105, y: 0, width: self.view.frame.width-210, height: 50)).cornerRadius(4).font(UIFont.theme.headlineSmall).textColor(UIColor.theme.neutralColor98, .normal).title("Add Contact".chat.localize, .normal).addTargetFor(self, action: #selector(addAction), for: .touchUpInside)
    }()
    
    public private(set) lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).tableHeaderView(self.header).backgroundColor(.clear)
    }()
    
    @objc public required init(profile: EaseProfileProtocol) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        if self.profile.id == EaseChatUIKitContext.shared?.currentUserId ?? "",let user = EaseChatUIKitContext.shared?.currentUser {
            self.profile = user
        }
        self.fetchAllContactIds()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fetchAllContactIds() {
        if let allContacts = ChatClient.shared().contactManager?.getContacts() {
            if allContacts.count > 0 {
                self.contacts = allContacts
                self.setup()
            } else {
                ChatClient.shared().contactManager?.getContactsFromServer(completion: { [weak self] contacts, error in
                    if error == nil {
                        self?.contacts = contacts ?? []
                        self?.setup()
                    }
                })
            }
        }
    }
    
    @MainActor @objc public func updateUserState(state: UserState) {
        self.header.userState = state
    }
    
    private func setup() {
        self.view.addSubViews([self.navigation,self.menuList])
        if !self.profile.avatarURL.isEmpty {
            self.header.avatarURL = self.profile.avatarURL
        }
        self.header.nickName.text = self.profile.nickname
        self.header.userState = .offline
        self.header.detailText = self.profile.id
        if !self.showMenu {
            let userId = EaseChatUIKitContext.shared?.currentUserId ?? ""
            self.datas.removeAll()
            if self.profile.id != userId {
                self.menuList.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)).backgroundColor(.clear)
                self.menuList.tableFooterView?.addSubview(self.addContact)
            }
            self.menuList.reloadData()
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Click of the navigation
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
    
    private func alreadyChat() {
        ChatClient.shared().chatManager?.ackConversationRead(self.profile.id)
        if let count = self.navigationController?.viewControllers.count {
            if let previousViewController = self.navigationController?.viewControllers[safe: count - 2] as? MessageListController {
                if let root = self.navigationController?.viewControllers[safe: count - 3] {
                    self.navigationController?.popToViewController(root, animated: true)
                    ControllerStack.toDestination(vc: ComponentsRegister.shared.MessageViewController.init(conversationId: self.profile.id))
                }
            } else {
                ControllerStack.toDestination(vc: ComponentsRegister.shared.MessageViewController.init(conversationId: self.profile.id))
            }
        } else {
            if let presentingVC = self.presentingViewController {
                if presentingVC is MessageListController {
                    presentingVC.dismiss(animated: false) {
                        UIViewController.currentController?.present(ComponentsRegister.shared.MessageViewController.init(conversationId: self.profile.id), animated: true)
                    }
                } else {
                    let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: self.profile.id)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            } else {
                let desiredViewController = ComponentsRegister.shared.MessageViewController.init(conversationId: self.profile.id)
                ControllerStack.toDestination(vc: desiredViewController)
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
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: Appearance.contact.moreActions) { [weak self] item  in
                guard let `self` = self else { return }
                self.service.removeContact(userId: self.profile.id, removeChannel: true) { [weak self] error, userId in
                    if error == nil {
                        self?.removeContact?()
                        self?.pop()
                    } else {
                        consoleLogInfo("ContactInfoViewController delete contact error:\(error?.errorDescription ?? "")", type: .error)
                    }
                }
            }
        default:
            break
        }
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc private func addAction() {
        self.service.addContact(userId: self.profile.id, invitation: "") { [weak self] error, userId in
            if error == nil {
                self?.pop()
            } else {
                self?.showToast(toast: "Add Contact".chat.localize+"\(error?.errorDescription ?? "")")
            }
        }
    }

}

extension ContactInfoViewController: UITableViewDelegate,UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.datas.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoListCell") as? DetailInfoListCell
        if cell == nil {
            cell = DetailInfoListCell(style: .default, reuseIdentifier: "DetailInfoListCell")
        }
        cell?.indexPath = indexPath
        if let info = self.datas[safe: indexPath.row] {
            cell?.refresh(info: info)
        }
        cell?.valueChanged = { [weak self] in
            self?.switchChanged(isOn: $0, indexPath: $1)
        }
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = .clear
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        ChatClient.shared().chatManager?.getConversationWithConvId(self.profile.id)?.deleteAllMessages(nil)
        NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_clean_history_messages"), object: self.profile.id)
    }
    
    private func switchChanged(isOn: Bool,indexPath: IndexPath) {
        if let name = self.datas[safe: indexPath.row]?.title {
            self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.profile.id] = isOn ? 1:0
            if name == "contact_details_switch_donotdisturb".chat.localize {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "EaseUIKit_do_not_disturb_changed"), object: nil,userInfo: ["id":self.profile.id,"value":isOn])
            }
        }
    }
}

extension ContactInfoViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.addContact.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
}
