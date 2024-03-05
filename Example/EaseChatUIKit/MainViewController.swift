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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if UIApplication.shared.chat.keyWindow != nil {
            tabBar.frame = CGRect(x: 0, y: ScreenHeight-BottomBarHeight-49, width: ScreenWidth, height: BottomBarHeight+49)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadViewControllers()
        // Do any additional setup after loading the view.
        self.tabBar.insetsLayoutMarginsFromSafeArea = false
        self.tabBarController?.additionalSafeAreaInsets = .zero
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    private func loadViewControllers() {
        
        let contacts = EaseChatUIKit.ComponentsRegister.shared.ContactsController.init(headerStyle: .contact, provider:nil)
        contacts.tabBarItem = UITabBarItem(title: "Contacts".chat.localize, image: UIImage(named: "tabbar_contacts"), selectedImage: UIImage(named: "tabbar_contactsHL"))
        contacts.tabBarItem.tag = 0
        
        let chats = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init(provider: self)
        chats.tabBarItem = UITabBarItem(title: "Chats".chat.localize, image: UIImage(named: "tabbar_chats"), selectedImage: UIImage(named: "tabbar_chatsHL"))
        chats.tabBarItem.tag = 1
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        let setting = storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        setting.tabBarItem = UITabBarItem(title: "Setting".chat.localize, image: UIImage(named: "tabbar_setting"), selectedImage: UIImage(named: "tabbar_settingHL"))
        setting.tabBarItem.tag = 2
        
        let nav1 = UINavigationController(rootViewController: chats)
        let nav2 = UINavigationController(rootViewController: contacts)
        let nav3 = UINavigationController(rootViewController: setting)
        self.viewControllers = [nav1, nav2,nav3]
        self.tabBar.isTranslucent = false
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = UIColor.theme.barrageDarkColor8
        self.tabBar.barTintColor = UIColor.theme.barrageDarkColor8
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: BottomBarHeight+49)
        blurView.alpha = 0.8
        blurView.insetsLayoutMarginsFromSafeArea = false
        blurView.layoutMargins = .zero
        self.tabBar.insertSubview(blurView, at: 0)
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.shadowImage = UIImage()
    }

}

extension MainViewController: ThemeSwitchProtocol {
    func switchTheme(style: EaseChatUIKit.ThemeStyle) {
        if let blur = self.tabBar.viewWithTag(0) as? UIVisualEffectView {
            blur.effect = style == .dark ? UIBlurEffect(style: .dark): UIBlurEffect(style: .light)
            blur.alpha = style == .dark ? 1:0.8
        }
        self.tabBar.barTintColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.tabBar.backgroundColor = style == .dark ? UIColor.theme.barrageLightColor8:UIColor.theme.barrageDarkColor8
    }
    
}

//MARK: - EaseProfileProvider for conversations&contacts usage.
//For example using conversations controller,as follows.
extension MainViewController: EaseProfileProvider {

    func fetchProfiles(profilesMap: [EaseChatUIKit.EaseProfileProviderType : [String]]) async -> [EaseChatUIKit.EaseProfileProtocol] {
        //Create a task group
        return await withTaskGroup(of: [EaseChatUIKit.EaseProfileProtocol].self, returning: [EaseChatUIKit.EaseProfileProtocol].self) { group in
            var resultProfiles: [EaseChatUIKit.EaseProfileProtocol] = []
            for (type,profileIds) in profilesMap {
                //According to condition,add task execute
                if type == .chat {
                    group.addTask {
                        var resultProfiles: [EaseChatUIKit.EaseProfileProtocol] = []
                        let result = await self.requestUserInfos(profileIds: profileIds)
                        if let infos = result {
                            for info in infos {
                                let profile = EaseProfile()
                                profile.id = info.id
                                profile.nickname = info.nickname
                                profile.avatarURL = info.avatarURL
                                resultProfiles.append(profile)
                            }
                        }
                        return resultProfiles
                    }
                } else {
                    group.addTask {
                        var resultProfiles: [EaseChatUIKit.EaseProfileProtocol] = []
                        //根据profileIds去请求每个群的昵称头像并且 map塞进resultProfiles中返回
                        let result = await self.requestGroupsInfo(groupIds: profileIds)
                        if let groups = result {
                            for group in groups {
                                let profile = EaseProfile()
                                profile.id = group.id
                                profile.nickname = group.nickname
                                profile.avatarURL = group.avatarURL
                                resultProfiles.append(profile)
                            }
                        }
                        return resultProfiles
                    }
                }
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }

        
    }
    
    private func requestUserInfos(profileIds: [String]) async -> [EaseProfileProtocol]? {
        return []
    }
    
    private func requestGroupsInfo(groupIds: [String]) async -> [EaseProfileProtocol]? {
        return []
    }
}
