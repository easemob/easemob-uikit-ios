//
//  ReactionDetailCell.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/30.
//

import UIKit

private var selectedKey: UInt8 = 99

@objcMembers open class ReactionDetailCell: UICollectionViewCell {
    
    public private(set) lazy var background: UILabel = {
        UILabel(frame: self.bounds).cornerRadius(Appearance.avatarRadius).textAlignment(.center)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.addSubViews([self.background])
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.background.frame = self.contentView.bounds
    }
    
    @objc open func refresh(reaction: MessageReaction) {
        var addedColor = UIColor.clear
        if reaction.selected {
            addedColor = Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor9
        }
        self.background.attributedText = reaction.convertReactionDetailAttribute()
        self.background.backgroundColor = addedColor
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageReaction {
    
    @objc var selected: Bool {
        get {
            return objc_getAssociatedObject(self, &selectedKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &selectedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    @objc open func convertReactionDetailAttribute() -> NSAttributedString? {
        if let content = self.reaction {
            let symbol = ChatEmojiConvertor.shared.reactionEmojis[content] ?? content
            let image = ChatEmojiConvertor.shared.emojiReactionMap.isEmpty ? UIImage(named: symbol, in: .chatBundle, with: nil):ChatEmojiConvertor.shared.emojiReactionMap[symbol]
            
            var attribute = NSMutableAttributedString()
            if image == nil {
                attribute  = NSMutableAttributedString {
                    AttributedText("\(content)").font(.systemFont(ofSize: 22))
                    AttributedText(" \(self.count)").font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor3)
                }
            } else {
                attribute = NSMutableAttributedString {
                    ImageAttachment(image, bounds: CGRect(x: 0, y: -5, width: 22, height: 22))
                    AttributedText(" ").font(Font.theme.labelMedium)
                    AttributedText(" \(self.count)").font(Font.theme.labelMedium).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor3)
                }
            }
            return attribute
        }
        return nil
    }
}
