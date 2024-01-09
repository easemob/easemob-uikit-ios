//
//  DetailInfoListCell.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/23.
//

import UIKit

@objcMembers open class DetailInfo: NSObject {
    var title: String = ""
    var detail: String = ""
    var withSwitch: Bool = false
    var switchValue: Bool = false
    
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}

@objc open class DetailInfoListCell: UITableViewCell {
    
    @objc public var indexPath: IndexPath?
    
    @objc public var valueChanged: ((Bool,IndexPath) -> ())?
    
    lazy var titleLabel: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 16, width: (self.frame.width/2.0-22), height: 22)).font(UIFont.theme.labelMedium).backgroundColor(.clear)
    }()
    
    lazy var detailLabel: UILabel = {
        UILabel(frame: CGRect(x: self.frame.width-(self.frame.width/2.0-56), y: 16, width: (self.frame.width/2.0-36), height: 22)).font(UIFont.theme.labelMedium).backgroundColor(.clear).textAlignment(.right)
    }()
    
    public private(set) lazy var switchMenu: UISwitch = {
        UISwitch(frame: CGRect(x: self.frame.width-62, y: (self.contentView.frame.height-30)/2.0, width: 50, height: 30))
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubViews([self.titleLabel,self.detailLabel,self.switchMenu])
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
    }
    
    @objc public func refresh(info: DetailInfo) {
        self.switchMenu.isHidden = !info.withSwitch
        self.titleLabel.text = info.title
        self.detailLabel.text = info.detail
        self.accessoryType = info.withSwitch ? .none:.disclosureIndicator
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
        self.switchMenu.onTintColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    }
    
    
}
