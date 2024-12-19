//
//  MainViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2023/12/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit


final class MainViewController: UITabBarController {
    
    private lazy var chats: ConversationListController = {
        let vc = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init()
        vc.tabBarItem.tag = 0
        vc.viewModel?.registerEventsListener(listener: self)
        return vc
    }()
    
    private lazy var contacts: ContactViewController = {
        let vc = EaseChatUIKit.ComponentsRegister.shared.ContactsController.init(headerStyle: .contact)
        vc.tabBarItem.tag = 1
        vc.viewModel?.registerEventsListener(self)
        return vc
    }()
    
    private lazy var me: SettingViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let setting = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        setting.tabBarItem = UITabBarItem(title: "Setting".chat.localize, image: UIImage(named: "tabbar_setting"), selectedImage: UIImage(named: "tabbar_settingHL"))
        setting.tabBarItem.tag = 2
        return setting as! SettingViewController
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIApplication.shared.chat.keyWindow != nil {
            tabBar.frame = CGRect(x: 0, y: ScreenHeight-BottomBarHeight-49, width: ScreenWidth, height: BottomBarHeight+49)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.insetsLayoutMarginsFromSafeArea = false
        self.tabBarController?.additionalSafeAreaInsets = .zero
        self.setupDataProvider()
        self.loadViewControllers()
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.contacts.tabBarItem.badgeValue = "1"
        self.updateContactBadge()
    }
    
    private func setupDataProvider() {
        //userProfileProvider为用户数据的提供者，使用协程实现与userProfileProviderOC不能同时存在userProfileProviderOC使用闭包实现
        ChatUIKitContext.shared?.userProfileProvider = self
        ChatUIKitContext.shared?.userProfileProviderOC = nil
        //groupProvider原理同上
        ChatUIKitContext.shared?.groupProfileProvider = self
        ChatUIKitContext.shared?.groupProfileProviderOC = nil
    }
    


    private func loadViewControllers() {

        let nav1 = UINavigationController(rootViewController: self.chats)
        nav1.interactivePopGestureRecognizer?.isEnabled = true
        nav1.interactivePopGestureRecognizer?.delegate = self
        let nav2 = UINavigationController(rootViewController: self.contacts)
        nav2.interactivePopGestureRecognizer?.isEnabled = true
        nav2.interactivePopGestureRecognizer?.delegate = self
        let nav3 = UINavigationController(rootViewController: self.me)
        nav3.interactivePopGestureRecognizer?.isEnabled = true
        nav3.interactivePopGestureRecognizer?.delegate = self
        self.viewControllers = [nav1, nav2,nav3]
//        self.tabBar.isTranslucent = false
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = UIColor.theme.barrageDarkColor8
        self.tabBar.barTintColor = UIColor.theme.barrageDarkColor8
//        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: BottomBarHeight+49)
//        blurView.alpha = 0.8
//        blurView.insetsLayoutMarginsFromSafeArea = false
//        blurView.layoutMargins = .zero
//        self.tabBar.insertSubview(blurView, at: 0)
        self.tabBar.isTranslucent = true
        self.tabBar.barStyle = .default
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
    }

}

extension MainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return self.navigationController!.viewControllers.count > 1
        }
        return true
    }
}

extension MainViewController: ThemeSwitchProtocol {
    
    func switchTheme(style: EaseChatUIKit.ThemeStyle) {
//        if let blur = self.tabBar.viewWithTag(0) as? UIVisualEffectView {
//            blur.effect = style == .dark ? UIBlurEffect(style: .dark): UIBlurEffect(style: .light)
//            blur.alpha = style == .dark ? 1:0.8
//        }
        self.tabBar.barTintColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        
        var chatsImage = UIImage(named: "tabbar_chats")
        chatsImage = chatsImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedChatsImage = chatsImage?.withTintColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, renderingMode: .alwaysOriginal)
        self.chats.tabBarItem = UITabBarItem(title: "Chats", image: chatsImage, selectedImage: selectedChatsImage)
        
        self.chats.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5], for: .normal)
        self.chats.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5], for: .selected)
        
        var contactImage = UIImage(named: "tabbar_contacts")
        contactImage = contactImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedContactImage = contactImage?.withTintColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, renderingMode: .alwaysOriginal)
        self.contacts.tabBarItem = UITabBarItem(title: "Contacts", image: contactImage, selectedImage: selectedContactImage)
        self.contacts.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5], for: .normal)
        self.contacts.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5], for: .selected)
        
        var meImage = UIImage(named: "tabbar_mine")
        meImage = meImage?.withTintColor(style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5, renderingMode: .alwaysOriginal)
        let selectedMeImage = meImage?.withTintColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, renderingMode: .alwaysOriginal)
        self.me.tabBarItem = UITabBarItem(title: "Setting", image: meImage, selectedImage: selectedMeImage)
        
        self.me.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor5], for: .normal)
        self.me.tabBarItem.setTitleTextAttributes([.foregroundColor:style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5], for: .selected)
    }
    
}

//MARK: - EaseProfileProvider for conversations&contacts usage.
//For example using conversations controller,as follows.
extension MainViewController: ChatUserProfileProvider,ChatGroupProfileProvider {
    //MARK: - EaseProfileProvider
    func fetchProfiles(profileIds: [String]) async -> [any EaseChatUIKit.ChatUserProfileProtocol] {
        return await withTaskGroup(of: [EaseChatUIKit.ChatUserProfileProtocol].self, returning: [EaseChatUIKit.ChatUserProfileProtocol].self) { group in
            var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
                let result = await self.requestUserInfos(profileIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    //MARK: - EaseGroupProfileProvider
    func fetchGroupProfiles(profileIds: [String]) async -> [any EaseChatUIKit.ChatUserProfileProtocol] {
        
        return await withTaskGroup(of: [EaseChatUIKit.ChatUserProfileProtocol].self, returning: [EaseChatUIKit.ChatUserProfileProtocol].self) { group in
            var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
            group.addTask {
                var resultProfiles: [EaseChatUIKit.ChatUserProfileProtocol] = []
                let result = await self.requestGroupsInfo(groupIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    
    private func requestUserInfos(profileIds: [String]) async -> [ChatUserProfileProtocol]? {
        var unknownIds = [String]()
        var resultProfiles = [ChatUserProfileProtocol]()
        for profileId in profileIds {
            if let profile = ChatUIKitContext.shared?.userCache?[profileId] {
                if profile.nickname.isEmpty {
                    unknownIds.append(profile.id)
                } else {
                    resultProfiles.append(profile)
                }
            } else {
                unknownIds.append(profileId)
            }
        }
        if unknownIds.isEmpty {
            return resultProfiles
        }
        let result = await ChatClient.shared().userInfoManager?.fetchUserInfo(byId: unknownIds)
        if result?.1 == nil,let infoMap = result?.0 {
            for (userId,info) in infoMap {
                let profile = ChatUserProfile()
                let nickname = info.nickname ?? ""
                profile.id = userId
                profile.nickname = nickname
                if let remark = ChatClient.shared().contactManager?.getContact(userId)?.remark {
                    profile.remark = remark
                }
                profile.avatarURL = info.avatarUrl ?? ""
                resultProfiles.append(profile)
                ChatUIKitContext.shared?.userCache?[userId] = profile
            }
            return resultProfiles
        }
        return []
    }
    
    private func requestGroupsInfo(groupIds: [String]) async -> [ChatUserProfileProtocol]? {
        var resultProfiles = [ChatUserProfileProtocol]()
        let groups = ChatClient.shared().groupManager?.getJoinedGroups() ?? []
        for groupId in groupIds {
            if let group = groups.first(where: { $0.groupId == groupId }) {
                let profile = ChatUserProfile()
                profile.id = groupId
                profile.nickname = group.groupName
                profile.avatarURL = group.settings.ext
                resultProfiles.append(profile)
                ChatUIKitContext.shared?.groupCache?[groupId] = profile
            }

        }
        return resultProfiles
    }
}


//MARK: - ConversationEmergencyListener
extension  MainViewController: ConversationEmergencyListener {
    func onResult(error: EaseChatUIKit.ChatError?, type: EaseChatUIKit.ConversationEmergencyType) {
        //show toast or alert,then process
    }
    
    func onConversationLastMessageUpdate(message: EaseChatUIKit.ChatMessage, info: EaseChatUIKit.ConversationInfo) {
        //Latest message updated on the conversation.
    }
    
    func onConversationsUnreadCountUpdate(unreadCount: UInt) {
        DispatchQueue.main.async {
            self.chats.tabBarItem.badgeValue = unreadCount > 0 ? "\(unreadCount)" : nil
        }
    }

}

//MARK: - ContactEmergencyListener ContactEventListener
extension MainViewController: ContactEmergencyListener {
    func onResult(error: EaseChatUIKit.ChatError?, type: EaseChatUIKit.ContactEmergencyType, operatorId: String) {
        if type != .setRemark {
            if type == .cleanFriendBadge {
                DispatchQueue.main.async {
                    self.contacts.tabBarItem.badgeValue = nil
                }
            } else {
                self.updateContactBadge()
            }
        }
    }
    
    private func updateContactBadge() {
        if let newFriends = UserDefaults.standard.value(forKey: "EaseChatUIKit_contact_new_request") as? Array<Dictionary<String,Any>> {
            
            let unreadCount = newFriends.filter({ $0["read"] as? Int == 0 }).count
            DispatchQueue.main.async {
                self.contacts.tabBarItem.badgeValue = unreadCount > 0 ? "\(newFriends.count)":nil
            }
        } else {
            DispatchQueue.main.async {
                self.contacts.tabBarItem.badgeValue = nil
            }
        }
    }
}
