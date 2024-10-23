//
//  ReportOptionCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionCell: UITableViewCell {
    
    public private(set) var normalImage = UIImage(named: "uncheck", in: .chatBundle, with: nil)
    
    public private(set) var selectImage = UIImage(named: "check", in: .chatBundle, with: nil)
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 16, y: (self.contentView.frame.height-22)/2.0, width: self.contentView.frame.width-72, height: 22)).textColor(UIColor.theme.neutralColor1).font(UIFont.theme.labelLarge).backgroundColor(.clear)
    }()
    
    lazy var stateView: UIImageView = {
        UIImageView(frame: CGRect(x: self.contentView.frame.width-44, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)).backgroundColor(.clear)
    }()
    
    lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: self.content.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.content.frame.minX, height: 0.5))
    }()
    
    @objc public required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubViews([self.content,self.stateView,self.separatorLine])
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 16, y: (self.contentView.frame.height-22)/2.0, width: self.contentView.frame.width-72, height: 22)
        self.stateView.frame = CGRect(x: self.contentView.frame.width-44, y: (self.contentView.frame.height-28)/2.0, width: 28, height: 28)
        self.separatorLine.frame = CGRect(x:self.content.frame.minX, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-self.content.frame.minX, height: 0.5)
    }
    
    /// Refresh report option select state.
    /// - Parameters:
    ///   - select: Whether select or not.
    ///   - title: title
    @objc open func refresh(select: Bool ,title: String) {
        self.stateView.image(select ? self.selectImage:self.normalImage)
        self.content.text = title
    }
}

extension ReportOptionCell: ThemeSwitchProtocol {
    open func switchTheme(style: ThemeStyle) {
        self.content.textColor(style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        self.selectImage = style == .dark ? self.selectImage?.withTintColor(UIColor.theme.primaryDarkColor, renderingMode: .automatic):self.selectImage
        self.normalImage = style == .dark ? self.normalImage?.withTintColor(UIColor.theme.neutralColor8, renderingMode: .automatic):self.normalImage
        self.separatorLine.backgroundColor = (style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9)
    }
    
    
}
