//
//  MessageReactionView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/18.
//

import UIKit

@objcMembers open class MessageReactionView: UIView {
    
    public private(set) var datas: [MessageReaction] = []
    
    public var reactionClosure: ((MessageReaction?) -> Void)?
    
    public private(set) lazy var reactionMenus: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width-30, height: self.frame.height), collectionViewLayout: flow).delegate(self).dataSource(self).registerCell(MessageReactionCell.self, forCellReuseIdentifier: "EaseChatUIKit.MessageReactionCell").backgroundColor(.clear).showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()
    
    public private(set) lazy var moreReaction: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-30, y: 2, width: 24, height: 24)).image(UIImage(named: "reaction_more", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(moreAction), for: .touchUpInside).cornerRadius(Appearance.avatarRadius)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.reactionMenus,self.moreReaction])
        self.reactionMenus.isScrollEnabled = false
        self.reactionMenus.bounces = false
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    @objc func moreAction() {
        self.reactionClosure?(nil)
    }
    
    @objc open func refresh(entity: MessageEntity) {
        if let reactions = entity.message.reactionList {
            self.reactionMenus.frame = CGRect(x: 0, y: 0, width: self.frame.width-30, height: self.frame.height)
            self.moreReaction.frame = CGRect(x: self.frame.width-24, y: 3, width: 24, height: 24)
            self.datas.removeAll()
            self.datas.append(contentsOf: reactions.prefix(entity.visibleReactionToIndex+1))
            self.reactionMenus.reloadData()
        } else {
            self.frame = .zero
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MessageReactionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let reaction = self.datas[safe: indexPath.row] {
            return CGSize(width: reaction.reactionWidth, height: 28)
        }
        return CGSize(width: 51, height: 28)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        4
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EaseChatUIKit.MessageReactionCell", for: indexPath) as? MessageReactionCell
        if let reaction = self.datas[safe: indexPath.row] {
            cell?.refresh(reaction: reaction)
        }
        return cell ?? MessageReactionCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.reactionClosure?(self.datas[safe: indexPath.row])
    }
    
    
}

extension MessageReactionView: ThemeSwitchProtocol {
    
    open func switchTheme(style: ThemeStyle) {
        self.moreReaction.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.reactionMenus.reloadData()
    }
    
}


@objcMembers open class MessageReactionCell: UICollectionViewCell {
    
    public private(set) lazy var content: UILabel = {
        self.createContent()
    }()
    
    @objc open func createContent() -> UILabel {
        UILabel(frame: self.bounds).cornerRadius(Appearance.avatarRadius).layerProperties(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor, 1).textAlignment(.center)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.content)
    }
    
    @objc open func refresh(reaction: MessageReaction) {
        self.content.attributedText = reaction.reactionAttribute
        if reaction.isAddedBySelf {
            self.content.layer.borderColor = Theme.style == .dark ? UIColor.theme.primaryDarkColor.cgColor:UIColor.theme.primaryLightColor.cgColor
            self.content.backgroundColor = Theme.style == .dark ? UIColor.theme.primaryColor1:UIColor.theme.primaryColor95
        } else {
            self.content.layer.borderColor = UIColor.clear.cgColor
            self.content.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}


extension MessageReaction {
    
    var reactionAttribute: NSAttributedString? {
        self.convertReactionAttribute()
    }
    
    var reactionWidth: CGFloat {
        var width = UILabel().attributedText(self.reactionAttribute).sizeThatFits(CGSize(width: 72, height: 28)).width+12
        if width < 51 {
            width = 51
        }
        return width
    }
    
    @objc open func convertReactionAttribute() -> NSAttributedString? {
        if let content = self.reaction {
            let symbol = ChatEmojiConvertor.shared.reactionEmojis[content] ?? content
            let image = ChatEmojiConvertor.shared.emojiReactionMap.isEmpty ? UIImage(named: symbol, in: .chatBundle, with: nil):ChatEmojiConvertor.shared.emojiReactionMap[symbol]
            
            var attribute = NSMutableAttributedString()
            if image == nil {
                attribute  = NSMutableAttributedString {
                    AttributedText("").font(Font.theme.labelSmall)
                    AttributedText("\(content)").font(.systemFont(ofSize: 24))
                    AttributedText(" \(self.count)").font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
                }
            } else {
                attribute = NSMutableAttributedString {
                    ImageAttachment(image, bounds: CGRect(x: 0, y: -6.5, width: 24, height: 24))
                    AttributedText(" ").font(Font.theme.labelSmall)
                    AttributedText(" \(self.count)").font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
                }
            }
            return attribute
        }
        return nil
    }
    

}
