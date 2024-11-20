//
//  ChatEmojiView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import UIKit

@objcMembers open class MessageInputEmojiView: UIView {
        
    public var deleteClosure: (() -> Void)?
    
    public var sendClosure: (() -> Void)?

    public var emojiClosure: ((String) -> Void)?

    public lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (ScreenWidth - 20 - 60) / 7.0, height: (ScreenWidth - 20 - 60) / 7.0)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }()

    public lazy var emojiList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 0, y: 10, width: self.frame.width, height: self.frame.height - 10 - BottomBarHeight), collectionViewLayout: self.flowLayout).registerCell(ChatEmojiCell.self, forCellReuseIdentifier: "ChatEmojiCell").dataSource(self).delegate(self).backgroundColor(.clear)
    }()

    public lazy var separaLine: UIView = {
        UIView(frame: CGRect(x: 0, y: 10, width: ScreenWidth, height: 1)).backgroundColor(.clear)
    }()

    public lazy var deleteEmoji: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 112, y: self.frame.height - 56, width: 44, height: 44)).addTargetFor(self, action: #selector(deleteAction), for: .touchUpInside).isEnabled(true).cornerRadius(.large).backgroundColor(.clear)
    }()
    
    public lazy var sendEmoji: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.frame.width - 56, y: self.frame.height - 56, width: 44, height: 44)).addTargetFor(self, action: #selector(sendAction), for: .touchUpInside).isEnabled(true).cornerRadius(.large).backgroundColor(.clear).image(UIImage(named: "airplane", in: .chatBundle, with: nil), .normal)
    }()
    
    lazy var gradient: GradientEmojiView = {
        GradientEmojiView(frame: CGRect(x: 0, y: self.frame.height-BottomBarHeight-31, width: self.frame.width, height: 32)).image(UIImage(named: "gradient_light", in: .chatBundle, with: nil))
    }()

    @objc required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([self.emojiList, self.gradient,self.deleteEmoji, self.sendEmoji,self.separaLine])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in subviews.reversed() {
            if view.isKind(of: type(of: view)),view.frame.contains(point) {
                if view.isKind(of: GradientEmojiView.self) {
                    let childPoint = self.convert(point, to: self.emojiList)
                    let childView = self.emojiList.hitTest(childPoint, with: event)
                    return childView
                } else {
                    let childPoint = self.convert(point, to: view)
                    let childView = view.hitTest(childPoint, with: event)
                    return childView
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.gradient.frame = CGRect(x: 0, y: self.frame.height-BottomBarHeight-31, width: self.frame.width, height: 31)
        self.deleteEmoji.frame = CGRect(x: self.frame.width - 112, y: self.frame.height - 56 - BottomBarHeight, width: 44, height: 44)
        self.sendEmoji.frame = CGRect(x: self.frame.width - 56, y: self.frame.height - 56 - BottomBarHeight, width: 44, height: 44)
        self.deleteEmoji.cornerRadius(Appearance.avatarRadius)
        self.sendEmoji.cornerRadius(Appearance.avatarRadius)
        self.separaLine.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: 1)
        self.emojiList.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: self.frame.height - 10 - BottomBarHeight)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func deleteAction() {
        self.deleteClosure?()
    }
    
    @objc func sendAction() {
        self.sendClosure?()
    }
}

extension MessageInputEmojiView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ChatEmojiConvertor.shared.emojis.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChatEmojiCell", for: indexPath) as? ChatEmojiCell
        cell?.icon.image = ChatEmojiConvertor.shared.emojiMap.isEmpty ? UIImage(named: ChatEmojiConvertor.shared.emojis[indexPath.row], in: .chatBundle, with: nil):ChatEmojiConvertor.shared.emojiMap[ChatEmojiConvertor.shared.emojis[indexPath.row]]
        return cell ?? ChatEmojiCell()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.emojiClosure?(ChatEmojiConvertor.shared.emojis[indexPath.row])
    }
}

extension MessageInputEmojiView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        let image = UIImage(named: "arrow_left_thick", in: .chatBundle, with: nil)
        
        self.deleteEmoji.setImage(style == .dark ? image?.withTintColor(UIColor.theme.neutralColor98):image?.withTintColor(UIColor.theme.neutralColor3), for: .normal)
        self.deleteEmoji.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor95
        self.sendEmoji.backgroundColor = style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
        self.gradient.image = UIImage(named: style == .dark ? "gradient_dark":"gradient_light", in: .chatBundle, with: nil)
    }
}

open class ChatEmojiCell: UICollectionViewCell {
    lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: 7, y: 7, width: self.contentView.frame.width - 14, height: self.contentView.frame.height - 14)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.icon)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        self.icon.frame = CGRect(x: 7, y: 7, width: contentView.frame.width - 14, height: contentView.frame.height - 14)
    }
}


