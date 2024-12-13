//
//  CustomMessageListController.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 11/22/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class CustomMessageListController: MessageListController {
    
    override func processFollowInputAttachmentAction() {
        if Appearance.chat.messageAttachmentMenuStyle == .followInput {
            if let fileItem = Appearance.chat.inputExtendActions.first(where: { $0.tag == "File" }) {
                fileItem.action = { [weak self] item,object in
                    self?.handleAttachmentAction(item: item)
                }
            }
            if let photoItem = Appearance.chat.inputExtendActions.first(where: { $0.tag == "Photo" }) {
                photoItem.action = { [weak self] item,object in
                    self?.handleAttachmentAction(item: item)
                }
            }
            if let cameraItem = Appearance.chat.inputExtendActions.first(where: { $0.tag == "Camera" }) {
                cameraItem.action = { [weak self] item,object in
                    self?.handleAttachmentAction(item: item)
                }
            }
            if let contactItem = Appearance.chat.inputExtendActions.first(where: { $0.tag == "Contact" }) {
                contactItem.action = { [weak self] item,object in
                    self?.handleAttachmentAction(item: item)
                }
            }
            if let redPackageItem = Appearance.chat.inputExtendActions.first(where: { $0.tag == "Red" }) {
                redPackageItem.action = { [weak self] item,object in
                    self?.handleAttachmentAction(item: item)
                }
            }
            
        }
    }
    
    override func handleAttachmentAction(item: any ActionSheetItemProtocol) {
        switch item.tag {
        case "File": self.selectFile()
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        case "Contact": self.selectContact()
        case "Red": self.redPackageMessage()
        default:
            break
        }
    }
    
    private func redPackageMessage() {
        self.viewModel.sendRedPackageMessage()
    }

}

let redPackageIdentifier = "redPackage"

extension MessageListViewModel {
    func sendRedPackageMessage() {
        var ext = Dictionary<String,Any>()
        ext["something"] = "发红包"
        let json = ChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext.merge(json) { _, new in
            new
        }
        let chatMessage = ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: redPackageIdentifier, customExt: ["money": "20", "name": "张三","message": "恭喜发财大吉大利"]), ext: ext)
        self.driver?.showMessage(message: chatMessage)
        self.chatService?.send(message: chatMessage) { [weak self] error, message in
            if error == nil {
                if let message = message {
                    self?.driver?.updateMessageStatus(message: message, status: .succeed)
                }
            } else {
                consoleLogInfo("send text message failure:\(error?.errorDescription ?? "")", type: .error)
                if let message = message {
                    self?.driver?.updateMessageStatus(message: message, status: .failure)
                }
            }
        }
    }
    
    
}

