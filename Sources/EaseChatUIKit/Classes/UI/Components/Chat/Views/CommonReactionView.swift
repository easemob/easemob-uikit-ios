//
//  CommonReactionView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/30.
//

import UIKit

fileprivate let space = Int((ScreenWidth-10-CGFloat((Appearance.chat.commonReactions.count+1)*36))/CGFloat(Appearance.chat.commonReactions.count))

@objcMembers open class CommonReactionView: UIView {
    
    /// ``String`` represents the emoji of reaction,if empty,means more
    public var reactionClosure: ((String,ChatMessage) -> Void)?
    
    public private(set) var reactions = [Reaction]()
    
    public private(set) var message = ChatMessage()
    
    public private(set) lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: 36, height: 36)
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = CGFloat(19)
        return flow
    }()
    
    public private(set) lazy var reactionsList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 5, y: 4, width: self.frame.width-68, height: 36), collectionViewLayout: self.layout).backgroundColor(.clear).registerCell(ReactionEmojiCell.self, forCellReuseIdentifier: "CommonReactionCell").dataSource(self).delegate(self).showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false)
    }()
    
    public private(set) lazy var reactionMore: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width-48, y: 4, width: 36, height: 36)).backgroundColor(.clear).addTargetFor(self, action: #selector(moreReactions), for: .touchUpInside)
    }()
    
    @objc public required init(frame: CGRect, message: ChatMessage) {
        self.message = message
        super.init(frame: frame)
        self.addSubViews([self.reactionsList,self.reactionMore])
        self.reactionsList.isScrollEnabled = false
        self.fillReactions()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func fillReactions() {
        if let reactions = self.message.reactionList {
            self.reactions.removeAll()
            self.reactions = Appearance.chat.commonReactions.map { key in
                let reaction = Reaction()
                reaction.emoji = key
                if let realReaction = reactions.first(where: { $0.reaction ?? "" == key }) {
                    reaction.addBySelf = realReaction.isAddedBySelf
                }
                return reaction
            }
        }
        self.reactionsList.reloadData()
    }

    @objc open func moreReactions() {
        self.reactionClosure?("",self.message)
    }
}

extension CommonReactionView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        var image = UIImage(named: "reaction_all", in: .chatBundle, with: nil)
        if style == .dark {
            image = image?.withTintColor(UIColor.theme.neutralColor9)
        }
        self.reactionMore.image(image, .normal)
        self.reactionsList.reloadData()
    }
}

extension CommonReactionView: UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.reactions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommonReactionCell", for: indexPath) as? ReactionEmojiCell
        if let reaction = self.reactions[safe: indexPath.row] {
            cell?.refresh(reaction: reaction)
        }
        return cell ?? ReactionEmojiCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let reaction = self.reactions[safe: indexPath.row] {
            self.reactionClosure?(reaction.emoji,self.message)
        }
    }
    
}
