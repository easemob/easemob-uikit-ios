//
//  HueSettingViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

final class HueSettingViewController: UIViewController {
    
    @IBOutlet weak var scope: UILabel!
    
    @IBOutlet weak var primaryHue: UILabel!
    
    @IBOutlet weak var primaryValue: UISlider!
    
    @IBOutlet weak var secondaryHue: UILabel!
    
    @IBOutlet weak var secondaryValue: UISlider!
    
    @IBOutlet weak var errorHue: UILabel!
    
    @IBOutlet weak var errorValue: UISlider!
    
    @IBOutlet weak var neutralHue: UILabel!
    
    @IBOutlet weak var neutralValue: UISlider!
    
    @IBOutlet weak var neutralSpecialHue: UILabel!
    
    @IBOutlet weak var neutralSpecialValue: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 5: Appearance.primaryHue = CGFloat(sender.value)
        case 6: Appearance.secondaryHue = CGFloat(sender.value)
        case 7: Appearance.errorHue = CGFloat(sender.value)
        case 8: Appearance.neutralHue = CGFloat(sender.value)
        case 9: Appearance.neutralSpecialHue = CGFloat(sender.value)
        default:
            break
        }
        Theme.switchTheme(style: .custom)
    }
    
    override class func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
