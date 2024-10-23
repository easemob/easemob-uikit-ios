//
//  MessageReactionsController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit


@objcMembers open class MessageReactionsController: UIViewController,PresentedViewType {
    
    public var presentedViewComponent: PresentedViewComponent? = PresentedViewComponent(contentSize:  CGSize(width: ScreenWidth, height: ScreenHeight*(3.2/5.0)),destination: .bottomBaseline)
    
    private var needRefresh: (() -> Void)?
    
    public private(set) var message = ChatMessage()
        
    public private(set) var reactions = [Reaction]()
    
    public private(set) lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.view.frame.width/2.0-18, y: 6, width: 36, height: 5)).cornerRadius(2.5).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    public private(set) lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: 36, height: 36)
        flow.minimumLineSpacing = 18
        flow.minimumInteritemSpacing = 18
        return flow
    }()
    
    public private(set) lazy var reactionsList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 12, y: self.indicator.frame.maxY+13, width: self.view.frame.width-24, height: self.view.frame.height - 24 - BottomBarHeight), collectionViewLayout: self.layout).backgroundColor(.clear).registerCell(ReactionEmojiCell.self, forCellReuseIdentifier: "ReactionEmojiCell").dataSource(self).delegate(self)
    }()
    
    @objc required public init(message: ChatMessage,actionClosure: @escaping () -> Void) {
        self.message = message
        self.needRefresh = actionClosure
        super.init(nibName: nil, bundle: nil)
        let datas = (ChatEmojiConvertor.shared.emojiReactionMap.isEmpty ? ChatEmojiConvertor.shared.emojis:ChatEmojiConvertor.shared.reactions).map {
            let reaction = Reaction()
            reaction.emoji = $0
            return reaction
        }
        if let reactions = message.reactionList {
            for reaction in reactions {
                if reaction.isAddedBySelf {
                    if let addEmoji = datas.first(where: { $0.emoji == reaction.reaction ?? "" }) {
                        addEmoji.addBySelf = true
                    }
                }
            }
        }
        self.reactions = datas
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        self.view.cornerRadius(.medium, [.topLeft,.topRight], .clear, 0)
        self.view.addSubViews([self.indicator,self.reactionsList])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        // Do any additional setup after loading the view.
    }
    
    
}

extension MessageReactionsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
}

extension MessageReactionsController: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {

    // MARK: UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        self.reactions.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReactionEmojiCell", for: indexPath) as? ReactionEmojiCell
        // Configure the cell
        if let reaction = self.reactions[safe: indexPath.row] {
            cell?.refresh(reaction: reaction)
        }
        return cell ?? ReactionEmojiCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let reaction = self.reactions[safe: indexPath.row] {
            if !reaction.addBySelf {
                ChatClient.shared().chatManager?.addReaction(reaction.emoji, toMessage: self.message.messageId, completion: { [weak self] error in
                    if error == nil {
                        reaction.addBySelf = true
                        self?.reactionsList.reloadItems(at: [indexPath])
                        self?.needRefresh?()
                    } else {
                        consoleLogInfo("add reaction error:\(error?.errorDescription ?? "")", type: .error)
                    }
                })
            } else {
                ChatClient.shared().chatManager?.removeReaction(reaction.emoji, fromMessage: self.message.messageId, completion: { [weak self] error in
                    if error == nil {
                        reaction.addBySelf = false
                        self?.reactionsList.reloadItems(at: [indexPath])
                        self?.needRefresh?()
                    } else {
                        consoleLogInfo("remove reaction error:\(error?.errorDescription ?? "")", type: .error)
                    }
                })
            }
        }
        
    }

}
