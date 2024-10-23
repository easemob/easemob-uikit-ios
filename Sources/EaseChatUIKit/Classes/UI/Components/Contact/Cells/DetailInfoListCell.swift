//
//  DetailInfoListCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/23.
//

import UIKit

@objcMembers open class DetailInfo: NSObject {
    public var title: String = ""
    public var detail: String = ""
    public var withSwitch: Bool = false
    public var switchValue: Bool = false
    
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}

@objc open class DetailInfoListCell: UITableViewCell {
    
    @objc public var indexPath: IndexPath?
    
    @objc public var valueChanged: ((Bool,IndexPath) -> ())?
    
    lazy var titleLabel: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 16, width: (self.frame.width/2.0-22), height: 22)).font(UIFont.theme.titleMedium).backgroundColor(.clear)
    }()
    
    lazy var detailLabel: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width-(self.frame.width/2.0-56), y: 16, width: (self.frame.width/2.0-36), height: 22)).font(UIFont.theme.labelMedium).backgroundColor(.clear).textAlignment(.right)
    }()
    
    public private(set) lazy var switchMenu: UISwitch = {
        UISwitch(frame: CGRect(x: self.frame.width-62, y: (self.contentView.frame.height-30)/2.0, width: 50, height: 30))
    }()
    
    public private(set) lazy var separatorLine: UIView = {
        UIView(frame: CGRect(x: 16, y: self.contentView.frame.height-0.5, width: self.contentView.frame.width-16, height: 0.5))
    }()
    
    lazy var indicator: UIImageView = {
        UIImageView(frame: CGRect(x: self.frame.width-37, y: 0, width: 20, height: 20)).contentMode(.scaleAspectFill).backgroundColor(.clear)
    }()


    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.titleLabel,self.detailLabel,self.switchMenu,separatorLine,self.indicator])
        self.switchMenu.addTarget(self, action: #selector(valueSwitch), for: .valueChanged)
        self.switchMenu.isHidden = true
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 16, y: 16, width: (self.frame.width/2.0-22), height: 22)
        self.detailLabel.frame = CGRect(x: self.frame.width/2.0, y: 16, width: (self.frame.width/2.0-36), height: 22)
        self.switchMenu.frame = CGRect(x: self.frame.width-62, y: (self.contentView.frame.height-30)/2.0, width: 50, height: 30)
        self.separatorLine.frame = CGRect(x: 16, y: self.frame.height-0.5, width: self.frame.width, height: 0.5)
        self.indicator.frame = CGRect(x: self.frame.width-28, y: (self.frame.height-20)/2.0, width: 10, height: 20)
    }
    
    @objc public func refresh(info: DetailInfo) {
        self.switchMenu.isHidden = !info.withSwitch
        self.titleLabel.text = info.title
        self.detailLabel.text = info.detail
        if info.title == "contact_details_button_clearchathistory".chat.localize {
            self.indicator.isHidden = true
        } else {
            self.indicator.isHidden = info.withSwitch
        }
        
        if !info.withSwitch {
            self.detailLabel.frame = CGRect(x: self.frame.width/2.0, y: 16, width: (self.frame.width/2.0-36), height: 22)
        } else {
            self.detailLabel.frame = CGRect(x: self.frame.width-116, y: 16, width: 100, height: 22)
        }
        self.switchMenu.isOn = info.switchValue
    }
    
    @objc private func valueSwitch() {
        if let index = self.indexPath {
            self.valueChanged?(self.switchMenu.isOn,index)
        }
    }
}

extension DetailInfoListCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.titleLabel.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        self.detailLabel.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5
        self.switchMenu.onTintColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        
        let image = UIImage(named: "chevron_right", in: .chatBundle, with: nil)?.withTintColor(style == .dark ? UIColor.theme.neutralColor5:UIColor.theme.neutralColor3)
        self.indicator.image = image
        
        
        self.separatorLine.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor9
    }
    
    
}
