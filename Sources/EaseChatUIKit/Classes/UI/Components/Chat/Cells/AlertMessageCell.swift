//
//  AlertMessageCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/4.
//

import UIKit

@objc open class AlertMessageCell: MessageCell {
    
    public private(set) lazy var time: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 16, width: ScreenWidth-32, height: 16)).textAlignment(.center).backgroundColor(.clear).font(UIFont.theme.bodySmall)
    }()
    
    public private(set) lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 16, y: 32, width: ScreenWidth-32, height: 16)).textAlignment(.center).backgroundColor(.clear).tag(bubbleTag)
    }()

    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required public init(towards: BubbleTowards, reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.status.isHidden = true
        self.nickName.isHidden = true
        self.avatar.isHidden = true
        self.messageDate.isHidden = true
        self.replyContent.isHidden = true
        self.bubbleWithArrow.isHidden = true
        self.bubbleMultiCorners.isHidden = true
        self.topicView.isHidden = true
        self.checkbox.isHidden = true
        self.reactionView.isHidden = true
        self.contentView.addSubViews([self.time,self.content])
        self.addGestureTo(view: self.content, target: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func clickAction(gesture: UITapGestureRecognizer) {
        if !self.entity.message.alertMessageThreadId.isEmpty {
            self.clickAction?(.cell,self.entity)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.time.frame = CGRect(x: 16, y: 16, width: ScreenWidth-32, height: 16)
        self.content.frame = CGRect(x: 16, y: 32, width: ScreenWidth-32, height: 16)
    }
    
    open override func refresh(entity: MessageEntity) {
        self.checkbox.isHidden = true
        self.entity = entity
        self.content.attributedText = entity.content
        self.time.text = entity.message.showDate
    }
    
    public override func switchTheme(style: ThemeStyle) {
        self.time.textColor = style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor7
    }
}


