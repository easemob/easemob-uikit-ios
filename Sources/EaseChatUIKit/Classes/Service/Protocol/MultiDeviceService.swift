//
//  MultiDeviceService.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation

@objc public protocol MultiDeviceService: NSObjectProtocol {
    /// Bind multi device changed listener
    /// - Parameter listener: ``MultiDeviceListener``
    func bindMultiDeviceListener(listener: MultiDeviceListener)
    
    /// Unbind multi device changed listener
    /// - Parameter listener: ``MultiDeviceListener``
    func unbindMultiDeviceListener(listener: MultiDeviceListener)
}


@objc public protocol MultiDeviceListener: NSObjectProtocol {
    
    /// When a event of contact changes on other devices
    /// - Parameters:
    ///   - event: ``MultiDeviceEvent``
    ///   - userId: The id of the user.
    ///   - info: Extension info.
    @objc optional func onContactsEventDidChanged(event: MultiDeviceEvent,userId: String,extension info: String)
    
    /// When a event of group changes on other devices
    /// - Parameters:
    ///   - event: ``MultiDeviceEvent``
    ///   - groupId: The id of the group.
    ///   - users: [UserId].
    @objc optional func onGroupEventDidChanged(event: MultiDeviceEvent,groupId: String,users: [String])
    
    /// When a event of conversation changes on other devices
    /// - Parameters:
    ///   - event: ``MultiDeviceEvent``
    ///   - conversationId: The id of the group.
    ///   - conversationType: ``ChatConversationType``.
    @objc optional func onConversationEventDidChanged(event: MultiDeviceEvent,conversationId: String,conversationType: ChatConversationType)
    
    /// When a message remove by server.
    /// - Parameters:
    ///   - conversationId: The id of the conversation.
    ///   - deviceId: Operation device id.
    @objc optional func onMessageRemovedByServer(conversationId: String,deviceId: String)
    
    /// Notifications after Do Not Disturb is set on other devices
    /// - Parameter jsonString: Json
    @objc optional func noDisturbEventNotify(jsonString: String)
}
