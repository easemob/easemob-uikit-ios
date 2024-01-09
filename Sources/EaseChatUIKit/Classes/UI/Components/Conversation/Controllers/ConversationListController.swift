import UIKit


/// When you
@objc open class ConversationListController: UIViewController {
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar( showLeftItem: false,rightImages: [UIImage(named: "add", in: .chatBundle, with: nil)!])
    }()
    
    public private(set) lazy var search: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY+5, width: self.view.frame.width-32, height: 36)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).title(" Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var conversationList: ConversationList = {
        ConversationList(frame: CGRect(x: 0, y: self.search.frame.maxY+5, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight-49-(self.tabBarController?.tabBar.frame.height ?? 0)), style: .plain)
    }()
    
    public private(set) var viewModel: ConversationViewModel?
    
    /// ``ConversationListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    @objc(initWithProviderOC:)
    public required init(providerOC: EaseProfileProviderOC? = nil) {
        self.viewModel = ConversationViewModel(providerOC: providerOC)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// ``ConversationListController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - id: The id of the conversation.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    public required init(provider: EaseProfileProvider? = nil) {
        self.viewModel = ConversationViewModel(provider: provider)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Update navigation avatar url.
    /// - Parameter url: The url of avatar.
    @MainActor @objc(updateWithAvatarURL:)
    public func updateAvatarURL(_ url: String) {
        self.navigation.avatarURL = url
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.chatId = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.search,self.conversationList])
        self.navigation.title = "Chats"
        //Bind UI driver and service
        self.viewModel?.bind(driver: self.conversationList)
        //Conversation list click push to message list controller.
        self.viewModel?.toChat = { [weak self] in
            self?.toChat(indexPath: $0, info: $1)
        }
        //click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        //If you want to listen for notifications about the success or failure of some requests and other events, you can add the following listeners
//        ConversationListController().viewModel.registerEventsListener(listener: <#T##ConversationEmergencyListener#>)
//        ConversationListController().viewModel.unregisterEventsListener(listener: <#T##ConversationEmergencyListener#>)
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
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
    
    private func toChat(indexPath: IndexPath,info: ConversationInfo) {
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: info.id, chatType: info.type == .chat ? .chat:.group)
        ControllerStack.toDestination(vc: vc)
    }
    
    @objc private func searchAction() {
        var search: SearchConversationsController?
        search = SearchConversationsController(searchInfos: self.conversationList.datas) {
            search?.navigationController?.popViewController(animated: false)
            self.toChat(indexPath: IndexPath(), info: $0)
        }
        if let vc = search {
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: Appearance.conversation.listMoreActions) { item in
                switch item.tag {
                case "SelectContacts": self.selectContact()
                case "AddContact": self.addContact()
                case "CreateGroup": self.createGroup()
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    private func selectContact() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .newChat,provider: nil)
        vc.confirmClosure = { [weak self] users in
            if let profile = users.first {
                vc.dismiss(animated: true) {
                    self?.chatToContact(profile: profile)
                }
            }
        }
        self.present(vc, animated: true)
    }
    
    private func chatToContact(profile: EaseProfileProtocol) {
        if let info = self.conversationList.datas.first(where: { $0.id == profile.id }) {
            self.toChat(indexPath: IndexPath(row: 0, section: 0), info: info)
        } else {
            self.createChat(profile: profile, info: "")
        }
    }
    
    private func createChat(profile: EaseProfileProtocol,info: String) {
        if let info = self.viewModel?.loadIfNotExistCreate(profile: profile, text: info) {
            let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: info.id , chatType: info.type == .chat ? .chat:.group)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content: 
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { [weak self] text in
            self?.viewModel?.contactService?.addContact(userId: text, invitation: "", completion: { error, userId in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    private func createGroup() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .newGroup,provider: nil)
        vc.confirmClosure = { [weak self] profiles in
            vc.dismiss(animated: true) {
                self?.create(profiles: profiles)
            }
        }
        self.present(vc, animated: true)
    }
    
    private func create(profiles: [EaseProfileProtocol]) {
        var name = ""
        var ids = [String]()
        for (index,profile) in profiles.enumerated() {
            if index <= 2 {
                if index == 0 {
                    name += (profile.nickname.isEmpty ? profile.id:profile.nickname)
                } else {
                    name += (", "+(profile.nickname.isEmpty ? profile.id:profile.nickname))
                }
            }
            ids.append(profile.id)
        }
        let option = ChatGroupOption()
        option.isInviteNeedConfirm = false
        option.maxUsers = 1000
        option.style = .privateMemberCanInvite
        ChatClient.shared().groupManager?.createGroup(withSubject: name, description: "", invitees: ids, message: nil, setting: option, completion: { [weak self] group, error in
            if error == nil,let group = group {
                let profile = EaseProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                self?.createChat(profile: profile,info: name)
            } else {
                consoleLogInfo("create group error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
}

extension ConversationListController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.conversationList.reloadData()
    }
    
    
}
