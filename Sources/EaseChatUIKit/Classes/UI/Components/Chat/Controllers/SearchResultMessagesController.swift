//
//  HistoricalMessagesPreviewController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/2/27.
//

import UIKit

@objcMembers open class SearchResultMessagesController: MessageListController {
    
    public private(set) var searchMessageId = ""
    
    open override func createMessageContainer() -> MessageListView {
        MessageListView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), mention: self.chatType == .group,showType: .history)
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
    
    open override func rightImages() -> [UIImage] {
        []
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.navigation.subtitle = nil
        self.navigation.title = self.profile.nickname.isEmpty ? self.profile.id:self.profile.nickname
        self.view.addSubViews([self.messageContainer,self.navigation])
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        
        self.viewModel.bindDriver(driver: self.messageContainer,searchMessageId: self.searchMessageId)
        self.viewModel.addEventsListener(self)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.view.addSubview(self.loadingView)
    }
    
    open override func viewDetail() {
        
    }
    
    public override func onMessageAvatarClicked(user: any ChatUserProfileProtocol) {
        
    }
    
    open override func viewContact(body: ChatCustomMessageBody) {
        
    }
    
    open override func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?) {
        self.pop()
    }
}
