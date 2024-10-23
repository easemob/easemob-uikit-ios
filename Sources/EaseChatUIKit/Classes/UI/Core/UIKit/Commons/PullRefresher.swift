//
//  PullRefresher.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/12.
//

import Foundation
import QuartzCore
import UIKit

internal class AnimatorView: UIView {
    fileprivate let activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(activityIndicatorView)
        
        self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicatorView.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Animator: PullRefresherDelegate {
    internal let animatorView: AnimatorView

    init(frame: CGRect) {
        animatorView = AnimatorView(frame: frame)
    }
    
    func pullToRefreshAnimationDidStart(_ view: PullRefresher) {
        animatorView.activityIndicatorView.startAnimating()
    }
    
    func pullToRefreshAnimationDidEnd(_ view: PullRefresher) {
        animatorView.activityIndicatorView.stopAnimating()
    }
    
    func pullToRefresh(_ view: PullRefresher, progressDidChange progress: CGFloat) {
        
    }
    
    func pullToRefresh(_ view: PullRefresher, stateDidChange state: PullRefresherState) {
//        switch state {
//        case .loading:
////            animatorView.titleLabel.text = "Loading"
//        case .pullToRefresh:
////            animatorView.titleLabel.text = "Pull to refresh"
//        case .releaseToRefresh:
////            animatorView.titleLabel.text = "Release to refresh"
//        }
    }
}

public enum PullRefresherState {
    case loading
    case pullToRefresh
    case releaseToRefresh
}

public protocol PullRefresherDelegate {
    func pullToRefreshAnimationDidStart(_ view: PullRefresher)
    func pullToRefreshAnimationDidEnd(_ view: PullRefresher)
    func pullToRefresh(_ view: PullRefresher, progressDidChange progress: CGFloat)
    func pullToRefresh(_ view: PullRefresher, stateDidChange state: PullRefresherState)
}

open class PullRefresher: UIView {
    private var observation: NSKeyValueObservation?
    private var scrollViewBouncesDefaultValue: Bool = false
    private var scrollViewInsetsDefaultValue: UIEdgeInsets = UIEdgeInsets.zero

    private var animator: PullRefresherDelegate
    private var action: (() -> ()) = {}

    private var previousOffset: CGFloat = 0

    internal var loading: Bool = false {
        
        didSet {
            if loading != oldValue {
                if loading {
                    startAnimating()
                } else {
                    stopAnimating()
                }
            }
        }
    }
    
    
    // MARK: Object lifecycle methods

    convenience init(action: @escaping (() -> ()), frame: CGRect) {
        var bounds = frame
        bounds.origin.y = 0
        let animator = Animator(frame: bounds)
        self.init(frame: frame, animator: animator as! PullRefresherDelegate)
        self.action = action;
        addSubview(animator.animatorView)
    }

    convenience init(action: @escaping (() -> ()), frame: CGRect, animator: PullRefresherDelegate, subview: UIView) {
        self.init(frame: frame, animator: animator)
        self.action = action;
        subview.frame = self.bounds
        addSubview(subview)
    }
    
    convenience init(action: @escaping (() -> ()), frame: CGRect, animator: PullRefresherDelegate) {
        self.init(frame: frame, animator: animator)
        self.action = action;
    }
    
    init(frame: CGRect, animator: PullRefresherDelegate) {
        self.animator = animator
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
        // It is not currently supported to load view from nib
    }
    
    
    // MARK: UIView methods
    
    open override func willMove(toSuperview newSuperview: UIView!) {
        self.observation?.invalidate()
        if let scrollView = newSuperview as? UIScrollView {
            self.observation = scrollView.observe(\.contentOffset, options: [.initial]) { [unowned self] (scrollView, change) in
                let offsetWithoutInsets = self.previousOffset + self.scrollViewInsetsDefaultValue.top
                if (offsetWithoutInsets < -self.frame.size.height) {
                    if (scrollView.isDragging == false && self.loading == false) {
                        self.loading = true
                    } else if (self.loading) {
                        self.animator.pullToRefresh(self, stateDidChange: .loading)
                    } else {
                        self.animator.pullToRefresh(self, stateDidChange: .releaseToRefresh)
                        self.animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                    }
                } else if (self.loading) {
                    self.animator.pullToRefresh(self, stateDidChange: .loading)
                } else if (offsetWithoutInsets < 0) {
                    self.animator.pullToRefresh(self, stateDidChange: .pullToRefresh)
                    self.animator.pullToRefresh(self, progressDidChange: -offsetWithoutInsets / self.frame.size.height)
                }
                self.previousOffset = scrollView.contentOffset.y
            }
            scrollViewBouncesDefaultValue = scrollView.bounces
            scrollViewInsetsDefaultValue = scrollView.contentInset
        }
    }
    
    
    // MARK: PullToRefresher methods

    private func startAnimating() {
        let scrollView = superview as! UIScrollView
        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        
        // We need to restore previous offset because we will animate scroll view insets and regular scroll view animating is not applied then
        scrollView.contentOffset.y = previousOffset
        scrollView.bounces = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets.top)
        }, completion: {finished in
            self.animator.pullToRefreshAnimationDidStart(self)
            self.action()
        })
    }
    
    private func stopAnimating() {
        self.animator.pullToRefreshAnimationDidEnd(self)
        let scrollView = superview as! UIScrollView
        scrollView.bounces = self.scrollViewBouncesDefaultValue
        UIView.animate(withDuration: 0.3, animations: {
            scrollView.contentInset = self.scrollViewInsetsDefaultValue
        }, completion: { finished in
            self.animator.pullToRefresh(self, progressDidChange: 0)
        })
    }
}

