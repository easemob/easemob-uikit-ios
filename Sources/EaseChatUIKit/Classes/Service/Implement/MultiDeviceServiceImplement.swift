//
//  MultiDeviceServiceImplement.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/6.
//

import UIKit

@objc public class MultiDeviceServiceImplement: NSObject {
    
    private var responseDelegates: NSHashTable<MultiDeviceListener> = NSHashTable<MultiDeviceListener>.weakObjects()
        
    @objc public override init() {
        super.init()
        ChatClient.shared().addMultiDevices(delegate: self, queue: .main)
    }
    
    deinit {
        ChatClient.shared().remove(self)
    }
}

extension MultiDeviceServiceImplement: MultiDeviceService {
    public func bindMultiDeviceListener(listener: MultiDeviceListener) {
        if self.responseDelegates.contains(listener) {
            return
        }
        self.responseDelegates.add(listener)
    }
    
    public func unbindMultiDeviceListener(listener: MultiDeviceListener) {
        if self.responseDelegates.contains(listener) {
            self.responseDelegates.remove(listener)
        }
    }
    
    
}

extension MultiDeviceServiceImplement: MultiDeviceEventsListener {
    public func multiDevicesContactEventDidReceive(_ aEvent: MultiDeviceEvent, username aUsername: String, ext aExt: String?) {
        for listener in self.responseDelegates.allObjects {
            listener.onContactsEventDidChanged?(event: aEvent, userId: aUsername, extension: aExt ?? "")
        }
    }
    
    public func multiDevicesGroupEventDidReceive(_ aEvent: MultiDeviceEvent, groupId aGroupId: String, ext aExt: Any?) {
        for listener in self.responseDelegates.allObjects {
            if let users = aExt as? [String] {
                listener.onGroupEventDidChanged?(event: aEvent, groupId: aGroupId, users: users)
            } else {
                listener.onGroupEventDidChanged?(event: aEvent, groupId: aGroupId, users: [])
            }
        }
    }
    
    public func multiDevicesConversationEvent(_ event: MultiDeviceEvent, conversationId: String, conversationType: ChatConversationType) {
        for listener in self.responseDelegates.allObjects {
            listener.onConversationEventDidChanged?(event: event, conversationId: conversationId, conversationType: conversationType)
        }
    }
    
    public func multiDevicesMessageBeRemoved(_ conversationId: String, deviceId: String) {
        for listener in self.responseDelegates.allObjects {
            listener.onMessageRemovedByServer?(conversationId: conversationId, deviceId: deviceId)
        }
    }
    
    public func multiDevicesUndisturbEventNotifyFormOtherDeviceData(_ undisturbData: String?) {
        for listener in self.responseDelegates.allObjects {
            listener.noDisturbEventNotify?(jsonString: undisturbData ?? "")
        }
    }
}
