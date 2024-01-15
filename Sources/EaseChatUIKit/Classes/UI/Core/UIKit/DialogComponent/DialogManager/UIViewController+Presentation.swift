//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation
import UIKit

public typealias PresentationViewController = UIViewController & PresentedViewType

public extension UIViewController {
    
    static var currentController: UIViewController? {
        if let vc = UIApplication.shared.chat.keyWindow?.rootViewController {
            if let nav = vc as? UINavigationController {
                return nav.visibleViewController
            }
            if let tab = vc as? UITabBarController {
                if let nav = tab.selectedViewController as? UINavigationController {
                    return nav.visibleViewController
                } else {
                    return tab.selectedViewController
                }
            }
            if let presented = vc.presentedViewController {
                var vc: UIViewController?
                while presented.presentedViewController != nil {
                    vc = presented.presentedViewController
                }
                return vc
            }
            return vc
        }
        return nil
    }
    
    func presentViewController(_ viewController: PresentationViewController, animated: Bool = true) {
//        dismiss(animated: false)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: animated, completion: nil)
    }
}

// MARK: -  UIViewControllerTransitioningDelegate
extension UIViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presentedVC = presented as? PresentedViewType else { return nil }
        return presentedVC.presentTransitionType.animation
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let dismissedVC = dismissed as? PresentedViewType else { return nil }
        return dismissedVC.dismissTransitionType.animation
    }
}
