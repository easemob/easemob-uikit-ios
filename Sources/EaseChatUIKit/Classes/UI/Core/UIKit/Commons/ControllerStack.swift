//
//  ControllerStack.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/23.
//

import UIKit


@objc open class ControllerStack: NSObject {
    
    @objc public static func toDestination(vc: UIViewController) {
        let current = UIViewController.currentController
        if current?.navigationController != nil {
            vc.hidesBottomBarWhenPushed = true
            current?.navigationController?.pushViewController(vc, animated: true)
            return
        } else {
            if current?.presentingViewController?.navigationController != nil {
                vc.hidesBottomBarWhenPushed = true
                current?.presentingViewController?.navigationController?.pushViewController(vc, animated: true)
                return
            } else {
                if current != nil {
                    current?.present(vc, animated: true)
                }
                return
            }
        }
    }
}
