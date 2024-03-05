//
//  HistoricalMessagesPreviewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/2/27.
//

import UIKit

@objcMembers open class SearchResultMessagesController: MessageListController {
    
    public private(set) var searchMessageId = ""
    
    open override func createMessageContainer() -> MessageListView {
        MessageListView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), mention: self.chatType == .group,historyResult: true)
    }
    
    @objc(initWithConversationId:chatType:searchMessageId:)
    public required init(conversationId: String, chatType: ChatType = .chat, searchMessageId: String) {
        self.searchMessageId = searchMessageId
        super.init(conversationId: conversationId, chatType: chatType)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc(initWithConversationId:chatType:) 
    public required init(conversationId: String, chatType: ChatType = .chat) {
        super.init(conversationId: conversationId, chatType: chatType)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
    }
    
    open override func viewDetail() {
        
    }
    
    open override func viewContact(body: ChatCustomMessageBody) {
        
    }
    
    open override func navigationClick(type: EaseChatNavigationBarClickEvent, indexPath: IndexPath?) {
        self.pop()
    }
}
