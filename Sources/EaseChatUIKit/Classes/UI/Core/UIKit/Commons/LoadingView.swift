//
//  LoadingView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/9/22.
//

import UIKit

@objc public class LoadingView: UIView {
    
    let lightEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    
    let darkEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    lazy var blur: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: self.lightEffect).cornerRadius(.medium)
        return blurView
    }()
    
    lazy var indicatorText: UILabel = {
        UILabel().font(UIFont.theme.labelMedium).textColor(UIColor.theme.neutralColor98).text("Loading...".chat.localize).textAlignment(.center)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isHidden = true
        self.activityIndicatorView.stopAnimating()
    }
    
    private func setupViews() {
        self.isHidden = true
        self.addSubViews([self.blur,self.activityIndicatorView,self.indicatorText])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.blur.translatesAutoresizingMaskIntoConstraints = false
        self.indicatorText.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blur.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.blur.centerYAnchor.constraint(equalTo: centerYAnchor),
            self.blur.widthAnchor.constraint(equalToConstant: 94),
            self.blur.heightAnchor.constraint(equalToConstant: 78)
        ])
        NSLayoutConstraint.activate([
            self.activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor,constant: -12)
        ])
        NSLayoutConstraint.activate([
            self.indicatorText.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.indicatorText.bottomAnchor.constraint(equalTo: self.blur.bottomAnchor,constant: -12),
            self.indicatorText.widthAnchor.constraint(equalToConstant: 94),
            self.indicatorText.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    /// Start loading animation
    @MainActor func startAnimating() {
        self.isHidden = false
        self.alpha = 1
        self.activityIndicatorView.startAnimating()
    }
    
    /// Stop loading animation
    @MainActor func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
        }
    }
    
}


extension LoadingView: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.blur.effect = style == .dark ? self.darkEffect:self.lightEffect
        self.backgroundColor = UIColor.theme.barrageLightColor2
        self.activityIndicatorView.color = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor7
    }
}
