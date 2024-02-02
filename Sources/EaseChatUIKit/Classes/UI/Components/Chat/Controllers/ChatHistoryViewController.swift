//
//  ChatHistoryViewController.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit

@objcMembers open class ChatHistoryViewController: UIViewController {
    
    public private(set) var message = ChatMessage()
    
    public private(set) var messages = [MessageEntity]()
    
    @objc open func createNavigation() -> EaseChatNavigationBar {
        EaseChatNavigationBar(showLeftItem: true,textAlignment: .left,rightImages: [UIImage(named: "message_select_bottom_forward", in: .chatBundle, with: nil)!],hiddenAvatar: true)
    }
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
        self.createNavigation()
    }()
    
    public private(set) lazy var tableView: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).backgroundColor(.clear).separatorStyle(.none).registerCell(ChatHistoryCell.self, forCellReuseIdentifier: "CombineChatHistoryCell").delegate(self).dataSource(self)
    }()
    
    public required init(message: ChatMessage) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.tableView,self.navigation])
        // Do any additional setup after loading the view.
        self.requestMessages()
    }
    

    @objc open func requestMessages() {
        ChatClient.shared().chatManager?.downloadAndParseCombineMessage(self.message, completion: { messages, error in
            if error == nil {
                if let combineMessages = messages {
                    for message in combineMessages {
                        self.messages.append(self.convertMessage(message: message))
                    }
                    self.tableView.reloadData()
                }
            } else {
                consoleLogInfo("downloadAndParseCombineMessage error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func convertMessage(message: ChatMessage) -> MessageEntity {
        let entity = ComponentsRegister.shared.MessageRenderEntity.init()
        entity.state = .succeed
        entity.message = message
        _ = entity.content
        _ = entity.bubbleSize
        _ = entity.height
        return entity
    }

}

extension ChatHistoryViewController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let message = self.messages[safe: indexPath.row] else { return 62 }
        if message.message.body.type == .text || message.message.body.type == .image || message.message.body.type == .video {
            return message.bubbleSize.height+40
        } else {
            return 62
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = self.messages[safe: indexPath.row] else { return UITableViewCell() }
        var cell = tableView.dequeueReusableCell(withIdentifier: "CombineChatHistoryCell") as? ChatHistoryCell
        if cell == nil {
            cell = ChatHistoryCell(reuseIdentifier: "CombineChatHistoryCell", message: message.message)
        }
        cell?.selectionStyle = .none
        cell?.refresh(entity: message)
        return cell ?? UITableViewCell()
    }
    
    
}

