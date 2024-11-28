import UIKit

/**
    The `ConversationListController` class implements a view controller that displays a list of conversations.
    It inherits from `UIViewController`.
 */
@objc open class ConversationListController: UIViewController {
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        self.createNavigationBar()
    }()
    
    public private(set) lazy var search: UIButton = {
        self.createSearchBar()
    }()
    
    public private(set) lazy var conversationList: ConversationList = {
        self.createList()
    }()
    
    public private(set) var viewModel: ConversationViewModel?
    
    @objc public required init() {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = ComponentsRegister.shared.ConversationViewService.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func createNavigationBar() -> ChatNavigationBar {
        ChatNavigationBar( showLeftItem: false,rightImages: [UIImage(named: "add", in: .chatBundle, with: nil)!])
    }
    
    @objc open func createSearchBar() -> UIButton {
        UIButton(type: .custom).frame(CGRect(x: 16, y: self.navigation.frame.maxY+5, width: self.view.frame.width-32, height: 36)).backgroundColor(UIColor.theme.neutralColor95).textColor(UIColor.theme.neutralColor6, .normal).title("Search".chat.localize, .normal).image(UIImage(named: "search", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(searchAction), for: .touchUpInside).cornerRadius(Appearance.avatarRadius)
    }
    
    @objc open func createList() -> ConversationList {
        ConversationList(frame: CGRect(x: 0, y: self.search.frame.maxY+10, width: self.view.frame.width, height: self.view.frame.height-self.search.frame.maxY-10-(self.tabBarController?.tabBar.frame.height ?? 0)), style: .plain)
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
        self.view.window?.backgroundColor = .white
        self.navigation.avatarURL = ChatUIKitContext.shared?.currentUser?.avatarURL
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.search,self.conversationList])
        self.navigation.title = "Chats".chat.localize
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
    
    
}

extension ConversationListController {
    /**
     Handles the navigation bar click event.

     - Parameters:
        - type: The type of navigation bar click event.
        - indexPath: The index path of the clicked item, if applicable.
     */
    @objc open func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    /**
        Pops the current view controller from the navigation stack if it exists,
        otherwise dismisses the view controller.

        - Note: This method is typically used to navigate back to the previous screen.
    */
    @objc open func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    /**
     Opens the chat view controller for the selected conversation.

     - Parameters:
        - indexPath: The index path of the selected conversation in the table view.
        - info: The information of the selected conversation.

     - Note: This method creates an instance of `MessageViewController` and pushes it onto the navigation stack using `ControllerStack.toDestination(vc:)`.
     */
    @objc open func toChat(indexPath: IndexPath, info: ConversationInfo) {
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: info.id, chatType: info.type == .chat ? .chat:.group)
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
    }
    
    /**
        Performs a search action in the conversation list.
        - Note: This method creates a `SearchConversationsController` instance and presents it to the user.
                When a conversation is selected from the search results, it navigates to the chat screen.
     */
    @objc open func searchAction() {
        var search: SearchConversationsController?
        search = SearchConversationsController(searchInfos: self.conversationList.datas) {
            search?.navigationController?.popViewController(animated: false)
            self.toChat(indexPath: IndexPath(), info: $0)
        }
        if let vc = search {
            if vc.navigationController == nil {
                vc.modalPresentationStyle = .fullScreen
            }
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    /**
     Handles the right actions for a given indexPath in the conversation list.
     
     - Parameters:
         - indexPath: The index path of the selected row in the conversation list.
     */
    @objc open func rightActions(indexPath: IndexPath) {
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
    
    /**
     Selects a contact from the contacts list.
     
     This method presents a view controller that displays a list of contacts. The user can select a contact, and the selected contact's profile is passed to the `chatToContact` method.
     */
    @objc open func selectContact() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .newChat)
        vc.confirmClosure = { [weak self] users in
            if let profile = users.first {
                vc.dismiss(animated: true) {
                    self?.chatToContact(profile: profile)
                }
            }
        }
        self.view.window?.backgroundColor = .black
        self.present(vc, animated: true)
    }
    
    /**
     Opens a chat with the specified contact profile.
     
     - Parameters:
        - profile: The contact profile to chat with.
     */
    @objc open func chatToContact(profile: ChatUserProfileProtocol) {
        if let info = self.conversationList.datas.first(where: { $0.id == profile.id }) {
            self.toChat(indexPath: IndexPath(row: 0, section: 0), info: info)
        } else {
            self.createChat(profile: profile, type: .chat, info: "")
        }
    }
    
    /**
     Creates a chat with the given profile and information.
     
     - Parameters:
        - profile: The profile of the user to create the chat with.
        - info: Additional information about the chat.
     */
    @objc open func createChat(profile: ChatUserProfileProtocol, type: ChatConversationType, info: String) {
        if type == .chat {
            ChatUIKitContext.shared?.userCache?[profile.id] = profile
        } else {
            ChatUIKitContext.shared?.groupCache?[profile.id] = profile
        }
        if let conversation = self.viewModel?.loadIfNotExistCreate(profile: profile, type: type, text: info) {
            let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: conversation.id , chatType: conversation.type == .chat ? .chat:.group)
            vc.modalPresentationStyle = .fullScreen
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    /**
     Adds a contact to the conversation list.
     
     This method displays an alert dialog with a text field for the user to enter the contact ID. After the user confirms, the `addContact` method of the `contactService` is called to add the contact. If an error occurs during the process, it is logged.
     */
    @objc open func addContact() {
        DialogManager.shared.showAlert(title: "new_chat_button_click_menu_addcontacts".chat.localize, content:
                                        "add_contacts_subtitle".chat.localize, showCancel: true, showConfirm: true,showTextFiled: true,placeHolder: "contactID".chat.localize) { text in
            ChatClient.shared().contactManager?.addContact(text, message: "", completion: {  userId,error  in
                if let error = error {
                    consoleLogInfo("add contact error:\(error.errorDescription ?? "")", type: .error)
                }
            })
        }
    }
    
    @objc open func createGroup() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .newGroup)
        vc.confirmClosure = { [weak self] profiles in
            vc.dismiss(animated: false)
            self?.create(profiles: profiles)
        }
        self.view.window?.backgroundColor = .black
        self.present(vc, animated: true)
    }
    
    /**
     Creates a group conversation with the given profiles.
     
     - Parameters:
        - profiles: An array of `ChatUserProfileProtocol` objects representing the selected profiles for the group conversation.
     
     This method creates a group conversation with the given profiles. It constructs the group name based on the profiles' nicknames or IDs, and then uses the `ChatGroupOption` to configure the group settings. Finally, it calls the `createGroup` method of the `ChatGroupManager` to create the group.
     */
    @objc open func create(profiles: [ChatUserProfileProtocol]) {
        var name = ""
        var users = [ChatUserProfileProtocol]()
        let ownerId = ChatUIKitContext.shared?.currentUserId ?? ""
        if let owner = ChatUIKitContext.shared?.userCache?[ownerId] {
            users.append(owner)
            users.append(contentsOf: profiles)
        }
        var ids = [String]()
        for (index,profile) in users.enumerated() {
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
        option.maxUsers = Appearance.chat.groupParticipantsLimitCount
        option.style = .privateMemberCanInvite
        ChatClient.shared().groupManager?.createGroup(withSubject: name, description: "", invitees: ids, message: nil, setting: option, completion: { [weak self] group, error in
            if error == nil,let group = group {
                let profile = ChatUserProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                self?.createChat(profile: profile, type: .groupChat,info: name)
            } else {
                consoleLogInfo("create group error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
}

extension ConversationListController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.search.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.conversationList.reloadData()
    }
    
    
}
