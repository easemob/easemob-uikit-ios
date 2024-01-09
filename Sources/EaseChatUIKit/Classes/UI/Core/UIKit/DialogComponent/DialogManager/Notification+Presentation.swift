//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation

public extension Notification {
    /// frame
    var keyboardEndFrame: CGRect? {
        return (userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    /// animation duration
    var keyboardAnimationDuration: TimeInterval? {
        return (userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    }
}
