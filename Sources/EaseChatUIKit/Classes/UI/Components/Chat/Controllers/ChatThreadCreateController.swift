//
//  ChatThreadCreateController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objc open class ChatThreadCreateController: UIViewController {
    
    public private(set) var message = ChatMessage()
    
    public required init(messageId: String) {
        if let localMessage = ChatClient.shared().chatManager?.getMessageWithMessageId(messageId) {
            self.message = localMessage
        } else {
            consoleLogInfo("ChatThreadCreateController message is empty!", type: .error)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
