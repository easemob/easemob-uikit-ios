//
//  ReactionEmojiCellCollectionViewCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/29.
//

import UIKit

@objcMembers open class ReactionEmojiCell: UICollectionViewCell {
    
    public private(set) lazy var background: UIView = {
        UIView(frame: self.bounds).cornerRadius(Appearance.avatarRadius)
    }()
    
    public private(set) lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 4, y: 4, width: self.contentView.frame.width-8, height: self.contentView.frame.height-8)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.addSubViews([self.background,self.icon])
    }
    
    @objc open func refresh(reaction: Reaction) {
        if let imageName = ChatEmojiConvertor.shared.emojiReactionMap.isEmpty ? reaction.emoji:ChatEmojiConvertor.shared.reactionEmojis[reaction.emoji],let image = UIImage(named: imageName, in: .chatBundle, with: nil) {
            self.icon.image = image
        }
        var addedColor = UIColor.clear
        if reaction.addBySelf {
            addedColor = Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        }
        self.background.backgroundColor = addedColor
    
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@objc open class Reaction: NSObject {
    
    var emoji = ""
    
    var addBySelf = false
}
