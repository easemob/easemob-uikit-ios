//
//  LoginViewController.swift
//  AgoraChatEThreeExample
//
//  Created by 朱继超 on 2022/4/20.
//

import EaseChatUIKit
import UIKit

final class LoginViewController: UIViewController, UITextFieldDelegate {

    @UserDefault("ChatUserName", defaultValue: "") var userName

    @UserDefault("ChatPassword", defaultValue: "") var passWord

    private lazy var logo: UIImageView = {
        UIImageView(
            frame: CGRect(
                x: ScreenWidth / 3.0,
                y: NavigationHeight + 20,
                width: ScreenWidth / 3.0,
                height: ScreenWidth / 3.0
            )
        ).image(UIImage(named: "login_logo")!).contentMode(.scaleAspectFit)
    }()

    private lazy var userNameField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 20,
                y: self.logo.frame.maxY + 20,
                width: ScreenWidth - 40,
                height: 40
            )
        ).cornerRadius(5).placeholder("user id").delegate(self).tag(111)
            .layerProperties(UIColor(0xf5f7f9), 1).leftView(
                UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40)),
                .always
            )
    }()

    private lazy var passWordField: UITextField = {
        UITextField(
            frame: CGRect(
                x: 20,
                y: self.userNameField.frame.maxY + 10,
                width: ScreenWidth - 40,
                height: 40
            )
        ).cornerRadius(5).placeholder("token").delegate(self).tag(112)
            .layerProperties(UIColor(0xf5f7f9), 1).leftView(
                UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40)),
                .always
            )
    }()

    private lazy var login: UIButton = {
        UIButton(type: .custom).frame(
            CGRect(
                x: 20,
                y: self.passWordField.frame.maxY + 40,
                width: ScreenWidth - 40,
                height: 45
            )
        ).backgroundColor(UIColor(0x0066ff)).cornerRadius(10).title(
            "Login",
            .normal
        ).font(UIFont.systemFont(ofSize: 18, weight: .semibold)).addTargetFor(
            self,
            action: #selector(loginAction),
            for: .touchUpInside
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([
            self.logo, self.userNameField, self.passWordField, self.login,
        ])
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        // Pre-fill the last used credentials to make repeated verification easier.
        self.userNameField.text = self.userName
        self.passWordField.text = self.passWord
    }

}

extension LoginViewController {

    @objc private func loginAction() {
        self.view.endEditing(true)
        guard let userName = self.userNameField.text,
            let passWord = self.passWordField.text, !userName.isEmpty,
            !passWord.isEmpty
        else { return }
        self.userName = userName.lowercased()
        self.passWord = passWord
        let profile = ChatUserProfile()
        profile.id = userName.lowercased()
        ChatUIKitClient.shared.login(user: profile, token: passWord) { error in
            if error == nil {
                UIApplication.shared.chat.keyWindow?.rootViewController?
                    .showToast(
                        toast: "login sucessfully",
                        duration: 2
                    )
            } else {
                UIApplication.shared.chat.keyWindow?.rootViewController?
                    .showToast(
                        toast: "login error:\(error?.errorDescription ?? "")",
                        duration: 2
                    )
            }
        }
        // There is no need to wait for a successful login.
        // Return `MainViewController` immediately; the conversation/contact/group
        // lists fill in via the `onDatabaseOpened` / data-sync listeners.
        UIApplication.shared.chat.keyWindow?.rootViewController =
            MainViewController()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
