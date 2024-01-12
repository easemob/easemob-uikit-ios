//
//  ContactInfoViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

/**
 This is the documentation comment for the `ContactInfoViewController` class.
 
 The `ContactInfoViewController` class is a subclass of `UIViewController` and is responsible for displaying contact information and providing various functionalities related to contacts.
 
 The class has properties and methods for managing the contact information, creating the user interface, handling user interactions, and performing actions such as adding or removing contacts.
 
 Example usage:
 ```
 let contactInfoVC = ContactInfoViewController(profile: profile)
 navigationController?.pushViewController(contactInfoVC, animated: true)
 ```
 */
@objc open class ContactInfoViewController: UIViewController {
    
    public let service = ContactServiceImplement()
    
    public private(set) var profile: EaseProfileProtocol = EaseProfile()
    
    @objc public var removeContact: (() -> Void)?
    
    private var contacts = [String]()
    
    @UserDefault("EaseChatUIKit_conversation_mute_map", defaultValue: Dictionary<String,Dictionary<String,Int>>()) private var muteMap
    
    public private(set) lazy var datas: [DetailInfo] = {
        self.dataSource()
    }()
    
    /// Can override 
    /// - Returns: <#description#>
    @objc open func dataSource() -> [DetailInfo] {
        [["title":"contact_details_switch_donotdisturb".chat.localize,"detail":"","withSwitch": true,"switchValue":self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.profile.id] ?? 0 == 1],["title":"contact_details_button_clearchathistory".chat.localize,"detail":"","withSwitch": false,"switchValue":false]].map {
            let info = DetailInfo()
            info.setValuesForKeys($0)
            return info
        }
    }
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        self.createNavigation()
    }()
    
    /**
     Creates a navigation bar for the ContactInfoViewController.
     
     - Returns: An instance of EaseChatNavigationBar.
     */
    @objc open func createNavigation() -> EaseChatNavigationBar {
        EaseChatNavigationBar(showLeftItem: true, rightImages: self.showMenu ? [UIImage(named: "more_detail", in: .chatBundle, with: nil)!] : [], hiddenAvatar: true)
    }
    
    public private(set) lazy var header: DetailInfoHeader = {
        self.createHeader()
    }()
    
    /**
     Creates a header view for the ContactInfoViewController.

     - Returns: An instance of DetailInfoHeader.
     */
    @objc open func createHeader() -> DetailInfoHeader {
        DetailInfoHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 264), showMenu: self.showMenu, placeHolder: UIImage(named: "single", in: .chatBundle, with: nil)).backgroundColor(.clear)
    }
    
    lazy var showMenu: Bool = {
        self.showMenuCondition()
    }()
    
    /**
     Determines whether to show the menu conditionally.
     
     - Returns: `true` if the menu should be shown, `false` otherwise.
     */
    @objc open func showMenuCondition() -> Bool {
        if self.profile.id == EaseChatUIKitContext.shared?.currentUserId ?? "" {
            return false
        } else {
            if !self.contacts.contains(self.profile.id) {
                return false
            }
            return true
        }
    }
    
    public private(set) lazy var addContact: UIButton = {
        self.createAddContact()
    }()
    
    /**
     Creates and returns a custom UIButton for adding a contact.
     
     - Returns: A UIButton instance.
     */
    @objc open func createAddContact() -> UIButton {
        UIButton(type: .custom).frame(CGRect(x: 105, y: 0, width: self.view.frame.width-210, height: 50)).cornerRadius(4).font(UIFont.theme.headlineSmall).textColor(UIColor.theme.neutralColor98, .normal).title("Add Contact".chat.localize, .normal).addTargetFor(self, action: #selector(addAction), for: .touchUpInside)
    }
    
    public private(set) lazy var menuList: UITableView = {
        self.createMenuList()
    }()
    
    /**
     Creates a menu list UITableView.

     - Returns: The created UITableView.
     */
    @objc open func createMenuList() -> UITableView {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height), style: .plain).delegate(self).dataSource(self).tableFooterView(UIView()).rowHeight(54).tableHeaderView(self.header).backgroundColor(.clear)
    }
    
    /**
     Initializes a ContactInfoViewController with the given profile.
     
     - Parameters:
        - profile: The profile of the contact.
     */
    @objc public required init(profile: EaseProfileProtocol) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        if self.profile.id == EaseChatUIKitContext.shared?.currentUserId ?? "", let user = EaseChatUIKitContext.shared?.currentUser {
            self.profile = user
        }
        self.fetchAllContactIds()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Fetches all contact IDs and updates the contacts array.
     
     This method first checks if there are any locally stored contacts. If there are, it updates the `contacts` array with the locally stored contacts and calls the `setup()` method. If there are no locally stored contacts, it fetches the contacts from the server using the `getContactsFromServer(completion:)` method of the `ChatClient`'s `contactManager`. Once the contacts are fetched, it updates the `contacts` array and calls the `setup()` method.
     */
    @objc open func fetchAllContactIds() {
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
    
    /**
     Updates the user state and sets it to the specified state.
     
     - Parameters:
        - state: The new user state.
     */
    @MainActor @objc open func updateUserState(state: UserState) {
        self.header.userState = state
    }

    /**
     Sets up the view controller by adding subviews, setting avatar URL, nickname, user state, and detail text.
     If `showMenu` is false, it also configures the menu list and adds a footer view with an "Add Contact" button.
     */
    @objc open func setup() {
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
    
    /**
     This method is responsible for handling the header actions in the ContactInfoViewController.
     It checks if there is a chat action item available in the contact's detail extension action items.
     If found, it sets the action closure to invoke the `alreadyChat()` method when the action is triggered.
     */
    @objc open func headerActions() {
        if let chat = Appearance.contact.detailExtensionActionItems.first(where: { $0.featureIdentify == "Chat" }) {
            chat.actionClosure = { [weak self] _ in
                self?.alreadyChat()
            }
        }
    }
    
    /**
     Opens the chat conversation with the selected profile.
     
     This method is called when the user wants to start a chat with a specific profile. It performs the following steps:
     1. Acknowledges the conversation as read using the ChatClient shared instance.
     2. Checks if there is a previous view controller in the navigation stack that is an instance of MessageListController.
         - If found, pops to that view controller and presents a new instance of MessageViewController with the selected conversation ID.
         - If not found, presents a new instance of MessageViewController with the selected conversation ID.
     3. If there is no previous view controller in the navigation stack, checks if the presenting view controller is an instance of MessageListController.
         - If true, dismisses the presenting view controller and presents a new instance of MessageViewController with the selected conversation ID.
         - If false, presents a new instance of MessageViewController with the selected conversation ID.
     4. If there is no presenting view controller, creates a new instance of MessageViewController with the selected conversation ID and sets it as the desired view controller using ControllerStack.
     */
    @objc open func alreadyChat() {
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
    
    /**
     Handles the navigation click events in the ContactInfoViewController.
     
     - Parameters:
        - type: The type of navigation click event.
        - indexPath: The optional index path associated with the event.
     */
    @objc open func navigationClick(type: EaseChatNavigationBarClickEvent, indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .rightItems: self.rightActions(indexPath: indexPath ?? IndexPath())
        default:
            break
        }
    }
    
    /**
     Handles the right actions for a given indexPath.
     
     - Parameters:
        - indexPath: The index path of the selected row.
     */
    @objc open func rightActions(indexPath: IndexPath) {
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
    
    /**
     Adds a contact to the user's contact list.
     
     - Parameters:
        - userId: The ID of the user to be added as a contact.
        - invitation: The invitation message for the contact.
        - completion: A closure that is called when the contact is successfully added or an error occurs. The closure takes two parameters: an optional `Error` object and the ID of the added contact.
     */
    @objc open func addAction() {
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
        self.cellForRowAtIndexPath(indexPath: indexPath)
    }
    
    /**
     Returns a table view cell for the specified index path.

     - Parameters:
        - indexPath: The index path of the cell.

     - Returns: A table view cell for the specified index path.
     */
    @objc open func cellForRowAtIndexPath(indexPath: IndexPath) -> UITableViewCell {
        var cell = self.menuList.dequeueReusableCell(withIdentifier: "DetailInfoListCell") as? DetailInfoListCell
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
        self.didSelectRow(indexPath: indexPath)
    }
    
    /// Called when a row is selected in the table view.
    /// - Parameter indexPath: The index path of the selected row.
    @objc open func didSelectRow(indexPath: IndexPath) {
        DialogManager.shared.showAlert(title: "", content: "group_details_button_clearchathistory".chat.localize, showCancel: true, showConfirm: true) { [weak self] _ in
            guard let `self` = self else { return }
            ChatClient.shared().chatManager?.getConversationWithConvId(self.profile.id)?.deleteAllMessages(nil)
            NotificationCenter.default.post(name: Notification.Name("EaseChatUIKit_clean_history_messages"), object: self.profile.id)
        }
    }
    
    /**
        Handles the switch change event for the contact info view controller.
     
        - Parameters:
            - isOn: A boolean value indicating whether the switch is turned on or off.
            - indexPath: The index path of the corresponding cell in the table view.
    */
    @objc open func switchChanged(isOn: Bool, indexPath: IndexPath) {
        if let name = self.datas[safe: indexPath.row]?.title {
            self.muteMap[EaseChatUIKitContext.shared?.currentUserId ?? ""]?[self.profile.id] = isOn ? 1:0
            if name == "contact_details_switch_donotdisturb".chat.localize {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "EaseUIKit_do_not_disturb_changed"), object: nil,userInfo: ["id":self.profile.id,"value":isOn])
            }
        }
    }
}

extension ContactInfoViewController: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.addContact.backgroundColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
}
