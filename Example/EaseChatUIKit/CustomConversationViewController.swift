//
//  CustomConversationViewController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2024/1/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class CustomConversationViewController: ConversationListController {
    
    
    override func createNavigationBar() -> ChatNavigationBar {
        ChatNavigationBar()
    }
    
    override func createList() -> ConversationList {
        ConversationList()
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
