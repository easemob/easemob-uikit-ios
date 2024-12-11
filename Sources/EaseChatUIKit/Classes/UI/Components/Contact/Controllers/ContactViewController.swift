import UIKit

@objcMembers open class ContactViewController: UIViewController {
    
    /// A closure that is called when the user confirms the selection of profiles.
    /// - Parameter profiles: An array of `ChatUserProfileProtocol` objects representing the selected profiles.
    public var confirmClosure: (([ChatUserProfileProtocol]) -> ())?
    
    public private(set) var style = ContactListHeaderStyle.contact
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        self.createNavigation()
    }()
    
    /**
     Creates and returns a navigation bar for the ContactViewController.
     
     - Returns: An instance of EaseChatNavigationBar.
     */
    @objc open func createNavigation() -> ChatNavigationBar {
        if self.style == .newGroup  || self.style == .shareContact || self.style == .newChat {
            return ChatNavigationBar(show: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44),textAlignment: .left,rightTitle: "").backgroundColor(.clear)
        } else {
            if style == .addGroupParticipant {
                return ChatNavigationBar(show: CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),textAlignment: .left,rightTitle: "Add".chat.localize).backgroundColor(.clear)
            } else {
                return ChatNavigationBar(show: CGRect(x: 0, y: 0, width: ScreenWidth, height: NavigationHeight),showLeftItem: self.style != .contact, rightImages: self.style == .newChat ? []:[UIImage(named: "person_add", in: .chatBundle, with: nil)!],hiddenAvatar: self.style == .contact ? false:true).backgroundColor(.clear)
            }
        }
    }
    
    public private(set) lazy var search: UIButton = {
        self.createSearch()
    }()
    
    /**
     Creates a search button with a custom frame and appearance.

     - Returns: The created search button.
     */
    @objc open func createSearch() -> UIButton {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY + 5, width: self.view.frame.width-32, height: 36)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).title("Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside).cornerRadius(Appearance.avatarRadius)
    }
    
    public private(set) lazy var contactList: ContactView = {
        self.createContactList()
    }()
    
    private var ignoreIds = [String]()
    
    /**
     Creates a contact list view.

     - Returns: A `ContactView` instance.
     */
    @objc open func createContactList() -> ContactView {
        ContactView(frame: CGRect(x: 0, y: self.search.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.search.frame.maxY-10-(self.tabBarController?.tabBar.frame.height ?? 0)),headerStyle: self.style).backgroundColor(.clear)
    }
            
    public private(set) var viewModel: ContactViewModel?
    
    /// ``ContactListController`` init method.Only available in Objective-C language.
    /// - Parameters:
    ///   - headerStyle: ``ContactListHeaderStyle``
    ///   - ignoreIds: Array of contact ids that already exist in the group.
    @objc(initWithHeaderStyle:ignoreIds:)
    public required init(headerStyle: ContactListHeaderStyle = .contact,ignoreIds: [String] = []) {
        self.style = headerStyle
        self.viewModel = ComponentsRegister.shared.ContactViewService.init(ignoreIds: ignoreIds)
        self.ignoreIds = ignoreIds
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigation.avatarURL = ChatUIKitContext.shared?.currentUser?.avatarURL
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.search,self.contactList])
        if self.style != .newGroup || self.style != .newChat || self.style != .shareContact {
            self.navigation.separateLine.isHidden = true
        }
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
    
    /**
     Handles the navigation bar click events.
     
     - Parameters:
        - type: The type of navigation bar click event.
        - indexPath: The index path associated with the click event (optional).
     */
    @objc open func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightTitle: self.confirmAction()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    /**
     Sets up the title for the ContactViewController based on the current style.
     
     The title is determined by the value of the `style` property. Depending on the style, the title will be set to a localized string.
     
     - Note: This method should be called after the `style` property has been set.
     */
    @objc open func setupTitle() {
        var text = ""
        switch self.style {
        case .newGroup:
            text = "Create".chat.localize
            self.navigation.rightItem.title("Create".chat.localize, .normal)
        case .newChat:
            text = "new_chat_button_click_menu_selectcontacts".chat.localize
        case .contact:
            text = "Contact"
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
    /**
     Handles the action when the contact header is tapped.
     
     This method checks for the presence of specific extension actions in the `Appearance.contact.listExtensionActions` array and assigns corresponding action closures to them. If an extension action with the feature identifier "NewFriendRequest" is found, the closure will call the `viewNewFriendRequest()` method. If an extension action with the feature identifier "GroupChats" is found, the closure will call the `viewJoinedGroups()` method.
     */    
    @objc open func receiveContactHeaderAction() {
        if let item = Appearance.contact.listHeaderExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewNewFriendRequest()
            }
        }
        if let item = Appearance.contact.listHeaderExtensionActions.first(where: { $0.featureIdentify == "GroupChats" }) {
            item.actionClosure = { [weak self] _ in
                self?.viewJoinedGroups()
            }
        }
    }
    
    /**
        Performs a search action in the ContactViewController.
        - Parameters:
            - None
        - Returns: None
    */
    @objc open func searchAction() {
        var vc: ContactSearchResultController?
        var selectProfiles = [ChatUserProfileProtocol]()
        for contacts in self.contactList.contacts {
            for contact in contacts {
                if contact.selected {
                    selectProfiles.append(contact)
                }
            }
        }
        var canDismiss = true
        if self.style == .addGroupParticipant || self.style == .newGroup {
            canDismiss = false
        }
        vc = ContactSearchResultController(headerStyle: self.style,selectProfiles: selectProfiles,ignoreIds: self.ignoreIds) { [weak self] item in
            if canDismiss {
                vc?.navigationController?.popViewController(animated: false)
            }
            self?.viewContact(profile: item)
        }
        if let vc = vc {
            if self.style != .newGroup,self.style != .newChat,self.style != .shareContact {
                vc.modalPresentationStyle = .fullScreen
            }
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    /**
     Handles the right actions for a given index path.
     
     - Parameter indexPath: The index path of the selected row.
     */
    @objc open func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if self.style == .contact {
                self.addContact()
            }
            if self.style == .addGroupParticipant {
                self.confirmAction()
            }
        default:
            break
        }
    }
    
    /**
     Adds a contact to the contact list.
     
     This method displays an alert dialog with a title and content, allowing the user to enter a contact ID. After the user confirms the input, the `addContact` method is called on the view model's service, passing the entered contact ID and an empty invitation string. If an error occurs during the process, it is logged.
     */
    @objc open func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content:
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { [weak self] text in
            self?.viewModel?.service?.addContact(userId: text, invitation: "", completion: { error, userId in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    /**
        Performs the confirm action by collecting the selected contacts and invoking the confirm closure.

        - Note: This method iterates through the contact list and adds the selected contacts to the `choices` array.
                It then invokes the `confirmClosure` with the `choices` array as the parameter.
    */
    @objc open func confirmAction() {
        var choices = [ChatUserProfileProtocol]()
        for contacts in self.contactList.contacts {
            for contact in contacts {
                if contact.selected {
                    choices.append(contact)
                }
            }
        }
        self.confirmClosure?(choices)
    }
    
    /**
     This method is called to view a contact's profile.
     
     - Parameters:
        - profile: The profile of the contact to be viewed.
     */
    @objc open func viewContact(profile: ChatUserProfileProtocol) {
        switch self.style {
        case .newChat:
            self.confirmClosure?([profile])
        case .contact:
            let vc = ComponentsRegister.shared.ContactInfoController.init(profile: profile)
            vc.removeContact = { [weak self] in
                self?.viewModel?.loadAllContacts()
            }
            vc.modalPresentationStyle = .fullScreen
            ControllerStack.toDestination(vc: vc)
        case .shareContact:
            self.confirmClosure?([profile])
        case .addGroupParticipant,.newGroup:
            var count = 0
            for contacts in self.contactList.contacts {
                for contact in contacts {
                    if contact.id == profile.id {
                        contact.selected = profile.selected
                    }
                    if contact.selected {
                        count += 1
                    }
                }
            }
            self.contactList.contactList.reloadData()
            
            self.navigation.rightItem.isEnabled = count > 0
            var title = self.style == .newGroup ? "Create".chat.localize:"Add".chat.localize
            if count > 0 {
                title += "(\(count))"
            }
            self.navigation.rightItem.setTitle(title, for: .normal)
        default:
            break
        }
    }
    
    /**
     Opens the view for new friend requests.
     */
    @objc open func viewNewFriendRequest() {
        let vc = ComponentsRegister.shared.NewFriendRequestController.init()
        vc.modalPresentationStyle = .fullScreen
        self.viewModel?.notifyCleanNewFriendRequestBadge()
        self.contactList.header.refresh()
        ControllerStack.toDestination(vc: vc)
    }
    
    /// Opens the view for displaying joined groups.
    @objc open func viewJoinedGroups() {
        let vc = ComponentsRegister.shared.JoinedGroupsController.init()
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
    }
    
    /**
     Pops the current view controller from the navigation stack or dismisses it if there is no navigation controller.

     - Note: If the view controller is embedded in a navigation controller, it will be popped from the navigation stack with animation. If there is no navigation controller, the view controller will be dismissed with animation.
     */
    @objc open func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension ContactViewController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        
        
        self.navigation.rightItem.textColor(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor7, .disabled)
        self.navigation.rightItem.textColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, .normal)
    }
    
}

