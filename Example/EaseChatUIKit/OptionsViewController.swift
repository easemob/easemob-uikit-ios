//
//  OptionsViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2023/12/15.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class OptionsViewController: UIViewController {
    
    @IBOutlet weak var themeSegment: UISegmentedControl!
    
    @IBOutlet weak var bubbleStyle: UILabel!
    
    @IBOutlet weak var bubbleStyleSegment: UISegmentedControl!
    
    @IBOutlet weak var avatarStyle: UILabel!
    
    @IBOutlet weak var avatarStyleSegment: UISegmentedControl!
    
    @IBOutlet weak var hueSetting: UIButton!
    
    @IBOutlet var contentStyle: UIView!
    
    @IBOutlet weak var alertStyle: UILabel!
    
    @IBOutlet weak var alertStyleSegment: UISegmentedControl!
    
    
    lazy var switchCellStyle: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth/2.0-100, y: self.alertStyleSegment.frame.maxY+150, width: 200, height: 40)).textColor(.white, .normal).backgroundColor(UIColor.theme.primaryColor6).cornerRadius(.small).title(".all", .normal).title("ContentStyle", .normal).font(.systemFont(ofSize: 16, weight: .semibold))
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.themeSegment.selectedSegmentIndex = Int(Theme.style.rawValue)
        self.bubbleStyleSegment.selectedSegmentIndex = 0
        self.themeSegment.selectedSegmentIndex = 0
        self.avatarStyleSegment.selectedSegmentIndex = 0
        self.alertStyleSegment.selectedSegmentIndex = 1
        Appearance.alertStyle = .small
        // Do any additional setup after loading the view.
        self.switchCellStyle.addInteraction(UIContextMenuInteraction(delegate: self))
        self.view.addSubview(self.switchCellStyle)
    }
    
    @IBAction func switchTheme(_ sender: UISegmentedControl) {
        let style = ThemeStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .light
        Theme.switchTheme(style: style)
        UIApplication.shared.windows.forEach { $0.overrideUserInterfaceStyle = (style == .dark ? .dark:.light) }
    }
    
    @IBAction func switchBubble(_ sender: UISegmentedControl) {
        Appearance.chat.bubbleStyle = MessageCell.BubbleDisplayStyle(rawValue: UInt(sender.selectedSegmentIndex)) ?? .withArrow
    }
    
    @IBAction func switchAvatar(_ sender: UISegmentedControl) {
        Appearance.avatarRadius = sender.selectedSegmentIndex == 1 ? .extraSmall:.large
        Theme.switchTheme(style: Theme.style)
    }
    
    @IBAction func switchAlert(_ sender: UISegmentedControl) {
        Appearance.alertStyle =  sender.selectedSegmentIndex == 1 ? .small:.large
    }
    
    @IBAction func setHue(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        let setting = storyboard.instantiateViewController(withIdentifier: "HueSettingViewController")
        self.navigationController?.pushViewController(setting, animated: true)
    }
}

extension OptionsViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (_) -> UIMenu? in
            let action1 = UIAction(title: ".all", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withAvatar,.withNickName,.withDateAndTime]
                self.switchCellStyle.setTitle(".all", for: .normal)
            }
            let action2 = UIAction(title: ".hideTime", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withAvatar,.withNickName]
                self.switchCellStyle.setTitle(".hideTime", for: .normal)
            }
            let action3 = UIAction(title: ".hideReply", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withAvatar,.withNickName,.withDateAndTime]
                self.switchCellStyle.setTitle(".hideReply", for: .normal)
            }
            let action4 = UIAction(title: ".hideAvatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withNickName,.withDateAndTime]
                self.switchCellStyle.setTitle(".hideAvatar", for: .normal)
            }
            let action5 = UIAction(title: ".hideNickname", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withAvatar,.withDateAndTime]
                self.switchCellStyle.setTitle(".hideNickname", for: .normal)
            }
            let action6 = UIAction(title: ".hideNickname&Avatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withDateAndTime]
                self.switchCellStyle.setTitle(".hideNickname&Avatar", for: .normal)
            }
            let action7 = UIAction(title: ".hideTime&Avatar", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withNickName]
                self.switchCellStyle.setTitle(".hideTime&Avatar", for: .normal)
            }
            let action8 = UIAction(title: ".hideNickname&Time", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = [.withReply,.withAvatar]
                self.switchCellStyle.setTitle(".hideNickname&Time", for: .normal)
            }
            let action9 = UIAction(title: ".hideAll", image: UIImage(systemName: "bookmark.fill")) { (_) in
                Appearance.chat.contentStyle = []
                self.switchCellStyle.setTitle(".hideAll", for: .normal)
            }
            let menu = UIMenu(title: "Cell Content Display", children: [action1, action2, action3, action4, action5, action6,action7, action8,action9])
            
            return menu
        }
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
