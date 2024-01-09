//
//  NotificationExtension.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 2020/12/31.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

public extension Notification {
    
    var chat: ChatWrapper<Self> {
        ChatWrapper.init(self)
    }
    
}

public extension NotificationCenter {
    /// - Parameters:
    ///   - name: The name of the notification for which to register the observer; that is, only notifications with this name are used to add the block to the operation queue.
    ///
    ///     If you pass `nil`, the notification center doesn’t use a notification’s name to decide whether to add the block to the operation queue.
    ///   - obj: The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.
    ///
    ///     If you pass `nil`, the notification center doesn’t use a notification’s sender to decide whether to deliver it to the observer.
    ///   - queue: The operation queue to which block should be added.
    ///
    ///     If you pass `nil`, the block is run synchronously on the posting thread.
    ///   - block: The block to be executed when the notification is received.
    ///
    ///     The block is copied by the notification center and (the copy) held until the observer registration is removed.
    ///
    ///     The block takes one argument:
    ///   - notification: The notification.
//    func observeOnce(forName name: NSNotification.Name?, immediateRemove: Bool,
//                     object obj: Any? = nil,
//                     queue: OperationQueue? = nil,
//                     using block: @escaping (_ notification: Notification) -> Void) {
//        var handler: NSObjectProtocol!
//        handler = addObserver(forName: name, object: obj, queue: queue) { [weak self] in
//            if immediateRemove == true { self?.removeObserver(handler!) }
//            block($0)
//        }
//    }
    
}

public extension ChatWrapper where Base == Notification {
    /// keyboardEndFrame
    var keyboardEndFrame: CGRect? {
        return (base.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    
    /// keyboard animation duration
    var keyboardAnimationDuration: TimeInterval? {
        return (base.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}
