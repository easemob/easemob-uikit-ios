//
//  UIScrollPullExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/12.
//

import UIKit

private let pullRefreshTag = 324
private let pullRefreshDefaultHeight: CGFloat = 50

extension UIScrollView {
    
    // Actual UIView subclass which is added as subview to desired UIScrollView. If you want customize appearance of this object, do that after addPullToRefreshWithAction
    public var PullRefresher: PullRefresher? {
        get {
            let PullRefresher = viewWithTag(pullRefreshTag)
            return PullRefresher as? PullRefresher
        }
    }
    
    // If you want to add pull to refresh functionality to your UIScrollView just call this method and pass action closure you want to execute while pull to refresh is animating. If you want to stop pull to refresh you must do that manually calling stopPullRefresher methods on your scroll view
    public func addPullToRefreshWithAction(_ action: @escaping (() -> ())) {
        let pullRefresher = EaseChatUIKit.PullRefresher(action: action, frame: CGRect(x: 0, y: -pullRefreshDefaultHeight, width: self.frame.size.width, height: pullRefreshDefaultHeight))
        pullRefresher.tag = pullRefreshTag
        self.addSubview(pullRefresher)
    }
    
    // If you want to use your custom animation and custom subview when pull to refresh is animating, you should call this method and pass your animator and view objects.
    public func addPullToRefreshWithAction(_ action: @escaping (() -> ()), withAnimator animator: PullRefresherDelegate, withSubview subview: UIView) {
        let height = subview.frame.height
        let pullRefresher = EaseChatUIKit.PullRefresher(action: action, frame: CGRect(x: 0, y: -height, width: self.frame.size.width, height: height), animator: animator, subview: subview)
        pullRefresher.tag = pullRefreshTag
        self.addSubview(pullRefresher)
    }
    
    //
    public func addPullToRefreshWithAction<T: UIView>(_ action: @escaping (() -> ()), withAnimator animator: T) where T: PullRefresherDelegate {
        let height = animator.frame.height
        let pullRefresher = EaseChatUIKit.PullRefresher(action: action, frame: CGRect(x: 0, y: -height, width: self.frame.size.width, height: height), animator: animator, subview: animator)
        pullRefresher.tag = pullRefreshTag
        self.addSubview(pullRefresher)
    }
    
    // Manually start pull to refresh
    public func startPullToRefresh() {
        PullRefresher?.loading = true
    }
    
    // Manually stop pull to refresh
    public func stopPullToRefresh() {
        PullRefresher?.loading = false
    }
}
