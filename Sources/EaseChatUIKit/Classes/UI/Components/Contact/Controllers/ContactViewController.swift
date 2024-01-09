import UIKit

@objcMembers open class ContactViewController: UIViewController {
    
    public var confirmClosure: (([EaseProfileProtocol]) -> ())?
    
    public private(set) var style = ContactListHeaderStyle.contact
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        if self.style == .newGroup || self.style == .addGroupParticipant || self.style == .shareContact {
            return EaseChatNavigationBar(frame: (self.style == .newGroup || self.style == .newChat) ? CGRect(x: 0, y: 0, width: ScreenWidth, height: 44):CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),textAlignment: .left,rightTitle: "").backgroundColor(.clear)
        } else {
            return EaseChatNavigationBar(frame: (self.style == .newGroup || self.style == .newChat) ? CGRect(x: 0, y: 0, width: ScreenWidth, height: 44):CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),showLeftItem: self.style != .contact, rightImages: self.style == .newChat ? []:[UIImage(named: "person_add", in: .chatBundle, with: nil)!],hiddenAvatar: self.style == .contact ? false:true).backgroundColor(.clear)
        }
    }()
    
    public private(set) lazy var search: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY + 5, width: self.view.frame.width-32, height: 36)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).title(" Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var contactList: ContactView = {
        ContactView(frame: CGRect(x: 0, y: self.search.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.search.frame.maxY-10-(self.tabBarController?.tabBar.frame.height ?? 0)),headerStyle: self.style).backgroundColor(.clear)
    }()
            
    public private(set) var viewModel: ContactViewModel?
    
    /// ``ContactListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``
    ///   - providerOC: The object of conform ``EaseProfileProviderOC``.
    ///   - ignoreIds: Array of contact ids that already exist in the group.
    @objc(initWithHeaderStyle:providerOC:ignoreIds:)
    public required init(headerStyle: ContactListHeaderStyle = .contact,providerOC: EaseProfileProviderOC? = nil,ignoreIds: [String] = []) {
        self.style = headerStyle
        self.viewModel = ContactViewModel(providerOC: providerOC,ignoreIds: ignoreIds)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// ``ContactListController`` init method.Only available in Swift language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``.
    ///   - provider: The object of conform ``EaseProfileProvider``.
    ///   - ignoreIds: Array of contact ids that already exist in the group.   
    public required init(headerStyle: ContactListHeaderStyle = .contact,provider: EaseProfileProvider? = nil,ignoreIds: [String] = []) {
        self.style = headerStyle
        self.viewModel = ContactViewModel(provider: provider,ignoreIds: ignoreIds)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.search,self.contactList])
        self.viewModel?.bind(driver: self.contactList)
        self.setupTitle()
    
        //Click of the navigation
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        //Push to ContactInfoViewController
        self.viewModel?.viewContact = { [weak self] in
            self?.viewContact(profile: $0)
        }
        
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        //If you want to listen for notifications about the success or failure of some requests and other events, you can add the following listeners
//        ContactViewController().viewModel.registerEventsListener(listener: <#T##ConversationEmergencyListener#>)
//        ConversationListController().viewModel.unregisterEventsListener(listener: <#T##ConversationEmergencyListener#>)
        self.receiveContactHeaderAction()
        
    }
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightTitle: self.confirmAction()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    private func setupTitle() {
        var text = ""
        switch self.style {
        case .newGroup:
            text = "new_chat_button_click_menu_creategroup".chat.localize
            self.navigation.rightItem.title("Create".chat.localize, .normal)
        case .newChat:
            text = "New Message".chat.localize
        case .contact:
            text = "Contact".chat.localize
        case .shareContact:
            text = "Share Contact".chat.localize
        case .addGroupParticipant:
            text = "add_group_members".chat.localize
            self.navigation.rightItem.title("Add".chat.localize, .normal)
        default:
            break
        }
        self.navigation.rightItem.isEnabled = false
        self.navigation.title = text
    }
    
    private func receiveContactHeaderAction() {
        if let item = Appearance.contact.listExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewNewFriendRequest()
            }
        }
        if let item = Appearance.contact.listExtensionActions.first(where: { $0.featureIdentify == "GroupChats" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewJoinedGroups()
            }
        }
    }
    
    @objc private func searchAction() {
        var vc: ContactSearchResultController?
        vc = ContactSearchResultController(headerStyle: self.style) { [weak self] item in
            vc?.navigationController?.popViewController(animated: false)
            self?.viewContact(profile: item)
        }
        if let vc = vc {
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    private func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0: self.addContact()
        default:
            break
        }
    }
    
    private func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content:
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { [weak self] text in
            self?.viewModel?.service?.addContact(userId: text, invitation: "", completion: { error, userId in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    private func confirmAction() {
        var choices = [EaseProfileProtocol]()
        for contacts in self.contactList.contacts {
            for contact in contacts {
                if contact.selected {
                    choices.append(contact)
                }
            }
        }
        self.confirmClosure?(choices)
    }
    
    @objc private func viewContact(profile: EaseProfileProtocol) {
        switch self.style {
        case .newChat:
            self.confirmClosure?([profile])
        case .contact:
            let vc = ComponentsRegister.shared.ContactInfoController.init(profile: profile)
            vc.removeContact = { [weak self] in
                self?.viewModel?.loadAllContacts()
            }
            ControllerStack.toDestination(vc: vc)
        case .shareContact:
            self.confirmClosure?([profile])
        case .addGroupParticipant,.newGroup:
            let count = self.contactList.rawData.filter { $0.selected }.count
            self.navigation.rightItem.isEnabled = count > 0
            var title = self.style == .newGroup ? "new_chat_button_click_menu_creategroup".chat.localize:"Add".chat.localize
            if count > 0 {
                title += "(\(count))"
            }
            self.navigation.rightItem.setTitle(title, for: .normal)
        default:
            break
        }
    }
    
    private func viewNewFriendRequest() {
        let vc = ComponentsRegister.shared.NewFriendRequestController.init()
        ControllerStack.toDestination(vc: vc)
    }
    
    private func viewJoinedGroups() {
        let vc = ComponentsRegister.shared.JoinedGroupsController.init()
        ControllerStack.toDestination(vc: vc)
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension ContactViewController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        
        
        self.navigation.rightItem.textColor(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor7, .disabled)
        self.navigation.rightItem.textColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, .normal)
    }
    
}

