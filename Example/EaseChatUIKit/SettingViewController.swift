//
//  ViewController.swift
//  EaseChatUIKit
//
//  Created by zjc19891106 on 11/01/2023.
//  Copyright (c) 2023 zjc19891106. All rights reserved.
//

import UIKit
import EaseChatUIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nickname: UILabel!
    
    @IBOutlet weak var options: UIButton!
    
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.avatar.backgroundColor(.clear).cornerRadius(Appearance.avatarRadius)
        self.nickname.text = ChatUIKitContext.shared?.currentUserId ?? ""
        let avatarImage = ImageView(frame: .zero)
        self.avatar.addSubview(avatarImage)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.topAnchor.constraint(equalTo: self.avatar.topAnchor,constant: 0).isActive = true
        avatarImage.bottomAnchor.constraint(equalTo: self.avatar.bottomAnchor,constant: 0).isActive = true
        avatarImage.leftAnchor.constraint(equalTo: self.avatar.leftAnchor,constant: 0).isActive = true
        avatarImage.rightAnchor.constraint(equalTo: self.avatar.rightAnchor,constant: 0).isActive = true
        if let avatarURL = ChatUIKitContext.shared?.currentUser?.avatarURL {
            avatarImage.image(with: avatarURL, placeHolder: Appearance.avatarPlaceHolder)
        } else {
            self.avatar.image = Appearance.avatarPlaceHolder
        }
        // The storyboard pins the logout button with a fixed frame, so on taller screens / Mac it ends
        // up underneath the tab bar. Re-anchor it above the safe-area bottom (which already accounts
        // for the tab bar height) so it's never obscured.
        self.logout.translatesAutoresizingMaskIntoConstraints = false
        self.options.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.logout.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.logout.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            self.logout.widthAnchor.constraint(equalToConstant: 255),
            self.logout.heightAnchor.constraint(equalToConstant: 52),
            self.options.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.options.bottomAnchor.constraint(equalTo: self.logout.topAnchor, constant: -20),
            self.options.widthAnchor.constraint(equalToConstant: 160),
            self.options.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    @IBAction func optionsAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let options = storyboard.instantiateViewController(withIdentifier: "OptionsViewController")
        ControllerStack.toDestination(vc: options)
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        print("logout begin :\(Date().timeIntervalSince1970*1000)")
        ChatUIKitClient.shared.logout(unbindNotificationDeviceToken: false) { error in
            consoleLogInfo("logout error:\(error?.errorDescription ?? "")", type: .error)
        }
        print("logout end :\(Date().timeIntervalSince1970*1000)")
        
        ChatUIKitContext.shared?.cleanCache(type: .all)
        UIApplication.shared.chat.keyWindow?.rootViewController = LoginViewController()
    }
    
    
    
}




