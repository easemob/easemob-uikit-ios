//
//  EmptyView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/18.
//

import UIKit

@objc public enum EmptyViewState: UInt8 {
    case empty
    case error
}

@objcMembers open class EmptyStateView: UIView {
    
    private var retryClosure: (() -> ())?
    
    public var state: EmptyViewState = .empty {
        willSet {
            DispatchQueue.main.async {
                self.retryButton.isHidden = newValue == .error
            }
        }
    }
    
    lazy var imageContainer: UIImageView = {
        UIImageView()
    }()
    
    lazy var retryButton: UIButton = {
        UIButton(type: .custom).font(UIFont.theme.labelMedium).textColor(UIColor.theme.neutralColor98, .normal).addTargetFor(self, action: #selector(retry), for: .touchUpInside)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Init a empty state view.
    /// - Parameters:
    ///   - frame: CGRect
    ///   - emptyImage: UIImage?
    @objc public required init(frame: CGRect,emptyImage: UIImage?,onRetry: @escaping () -> ()) {
        super.init(frame: frame)
        self.retryClosure = onRetry
        self.setupView()
        self.imageContainer.image = emptyImage
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self.imageContainer)
        self.imageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainer.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.imageContainer.centerYAnchor.constraint(equalTo: centerYAnchor,constant: -NavigationHeight).isActive = true
        self.imageContainer.widthAnchor.constraint(equalToConstant: 107).isActive = true
        self.imageContainer.heightAnchor.constraint(equalToConstant: 107).isActive = true
        
        self.addSubview(self.retryButton)
        self.retryButton.translatesAutoresizingMaskIntoConstraints = false
        self.retryButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.retryButton.topAnchor.constraint(equalTo: self.imageContainer.bottomAnchor,constant: 15).isActive = true
        self.retryButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        self.retryButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.retryButton.cornerRadius(Appearance.avatarRadius)
    }
    
    @objc private func retry() {
        self.retryClosure?()
    }
}
