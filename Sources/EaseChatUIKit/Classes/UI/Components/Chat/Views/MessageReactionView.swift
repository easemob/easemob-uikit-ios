//
//  MessageReactionView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/1/18.
//

import UIKit

@objcMembers open class MessageReactionView: UIView {
    
    public private(set) var datas: [MessageReaction] = []
    
    public private(set) lazy var reactionMenus: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        return UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width-30, height: self.frame.height), collectionViewLayout: flow).delegate(self).dataSource(self).registerCell(MessageReactionCell.self, forCellReuseIdentifier: "EaseChatUIKit.MessageReactionCell").backgroundColor(.clear).showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()
    
    public private(set) lazy var moreReaction: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-30, y: 2, width: 24, height: 24)).image(UIImage(named: "reaction_more", in: .chatBundle, with: nil), .normal).addTargetFor(self, action: #selector(moreAction), for: .touchUpInside)
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.reactionMenus,self.moreReaction])
        self.reactionMenus.isScrollEnabled = false
        self.reactionMenus.bounces = false
    }
    
    @objc func moreAction() {
        
    }
    
    @objc open func reactionMenuWidth(reactions: [MessageReaction]) -> CGFloat {
        var width = 0
        for reaction in reactions {
            width += Int(reaction.reactionWidth)
        }
        if reactions.count > 0 {
            width += (reactions.count-1)*4
        }
        return CGFloat(width)
    }
    
    @objc open func refresh(entity: MessageEntity) {
        if let reactions = entity.message.reactionList {
            if self.frame.width < limitBubbleWidth {
                let reactionWidth = self.reactionMenuWidth(reactions: reactions)
                if entity.message.direction == .send {
                    self.reactionMenus.frame = CGRect(x: self.frame.width-reactionWidth-30, y: 0, width: reactionWidth, height: self.frame.height)
                } else {
                    self.reactionMenus.frame = CGRect(x: 0, y: 0, width: reactionWidth, height: self.frame.height)
                }
                self.moreReaction.frame = CGRect(x: self.reactionMenus.frame.maxY, y: 2, width: 24, height: 24)
            } else {
                self.reactionMenus.frame = CGRect(x: 0, y: 0, width: self.frame.width-30, height: self.frame.height)
                self.moreReaction.frame = CGRect(x: self.frame.width-30, y: 2, width: 24, height: 24)
            }
            self.datas.removeAll()
            self.datas.append(contentsOf: reactions)
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
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EaseChatUIKit.MessageReactionCell", for: indexPath) as? MessageReactionCell
        if let reaction = self.datas[safe: indexPath.row] {
            cell?.refresh(reaction: reaction)
        }
        return cell ?? MessageReactionCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}



@objcMembers open class MessageReactionCell: UICollectionViewCell {
    
    public private(set) lazy var content: UILabel = {
        self.createContent()
    }()
    
    @objc open func createContent() -> UILabel {
        UILabel(frame: self.bounds).cornerRadius(4).layerProperties(Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5, 1).textAlignment(.center)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.content)
    }
    
    @objc open func refresh(reaction: MessageReaction) {
        self.content.attributedText = reaction.reactionAttribute
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
            let attribute = NSMutableAttributedString {
                AttributedText(" ").font(Font.theme.labelSmall)
                ImageAttachment(UIImage(named: content, in: .chatBundle, with: nil), bounds: CGRect(x: 0, y: -6.5, width: 24, height: 24))
                AttributedText(" \(self.count)").font(Font.theme.labelSmall).foregroundColor(Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5)
            }
            return attribute
        }
        return nil
    }
    

}
