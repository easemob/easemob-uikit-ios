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
        
    override func handleAttachmentAction(item: any ActionSheetItemProtocol) {
        switch item.tag {
        case "File": self.selectFile()
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        case "Contact": self.selectContact()
        case "Red": self.redPackageMessage()
        case "Gift": self.giftMessage()
        case "Music": self.musicMessage()
        default:
            break
        }
    }
    
    private func redPackageMessage() {
        self.viewModel.sendRedPackageMessage()
    }

    private func giftMessage() {
        self.viewModel.sendGiftMessage()
    }
    
    private func musicMessage() {
        self.viewModel.sendMusicMessage()
    }
    
}

let redPackageIdentifier = "redPackage"

let giftIdentifier = "gift"

let musicIdentifier = "music"

extension MessageListViewModel {
    func sendRedPackageMessage() {
        var ext = Dictionary<String,Any>()
        ext["something"] = "Send Red Package"
        let json = ChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext.merge(json) { _, new in
            new
        }
        let chatMessage = ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: redPackageIdentifier, customExt: ["money": "20", "name": "zhangsan","message": "Hello World"]), ext: ext)
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
    
    func sendGiftMessage() {
        var ext = Dictionary<String,Any>()
        ext["something"] = "Send Gift"
        let json = ChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext.merge(json) { _, new in
            new
        }
        let chatMessage = ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: giftIdentifier, customExt: ["gift": "gift"]), ext: ext)
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
    
    func sendMusicMessage() {
        var ext = Dictionary<String,Any>()
        ext["something"] = "Send music"
        let json = ChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext.merge(json) { _, new in
            new
        }
        let chatMessage = ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: musicIdentifier, customExt: ["music": "music"]), ext: ext)
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

