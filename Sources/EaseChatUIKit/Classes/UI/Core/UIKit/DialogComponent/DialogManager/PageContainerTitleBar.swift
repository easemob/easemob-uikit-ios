//
//  PageContainer.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

@objcMembers open class PageContainerTitleBar: UIView {
    
    var datas: [ChoiceItem] = []
    
    var chooseClosure: ((Int)->())?
        
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: 16+Appearance.pageContainerTitleBarItemWidth/2.0-8, y: self.frame.height-4, width: 16, height: 4)).cornerRadius(2).backgroundColor(UIColor.theme.primaryLightColor)
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let flow = self.datas.count > 1 ? UICollectionViewFlowLayout():ChoiceItemLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: Appearance.pageContainerTitleBarItemWidth, height: self.frame.height-16)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        return flow
    }()
    
    lazy var choicesBar: UICollectionView = {
        UICollectionView(frame: CGRect(x: 16, y: 8, width: self.frame.width-32, height: self.frame.height-16), collectionViewLayout: self.layout).dataSource(self).delegate(self).registerCell(ChoiceItemCell.self, forCellReuseIdentifier: NSStringFromClass(ChoiceItemCell.self)).showsHorizontalScrollIndicator(false).backgroundColor(.clear)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /**
     A convenience initializer for creating a `PageContainerTitleBar` instance with the specified frame, choices, and selected closure.

     - Parameters:
        - frame: The frame rectangle for the view, measured in points.
        - choices: An array of strings representing the choices to be displayed in the title bar.
        - selectedClosure: A closure that will be called when a choice is selected, passing the index of the selected choice as an argument.

     - Returns: A new `PageContainerTitleBar` instance.
     */
    @objc public init(frame: CGRect, choices: [String], selectedClosure: @escaping (Int)->()) {
        self.chooseClosure = selectedClosure
        self.datas = choices.map({ ChoiceItem(text: $0,selected: false) })
        super.init(frame: frame)
        self.backgroundColor = UIColor.theme.neutralColor98
        self.datas.first?.selected = true
        self.addSubViews([self.indicator,self.choicesBar])
        self.choicesBar.bounces = false
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        if choices.count == 1 {
            self.indicator.center = CGPoint(x: self.center.x, y: self.indicator.center.y)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PageContainerTitleBar: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ChoiceItemCell.self), for: indexPath) as? ChoiceItemCell else {
            return ChoiceItemCell()
        }
        cell.refresh(item: self.datas[indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.scrollIndicator(to: indexPath.row)
        for item in self.datas {
            item.selected = false
        }
        self.datas[safe: indexPath.row]?.selected = true
        collectionView.reloadData()
        self.chooseClosure?(indexPath.row)
    }
    
    @objc public func scrollIndicator(to index: Int) {
        for item in self.datas {
            item.selected = false
        }
        self.datas[safe: index]?.selected = true
        self.choicesBar.reloadData()
        UIView.animate(withDuration: 0.25) {
            self.indicator.frame = CGRect(x: 16+Appearance.pageContainerTitleBarItemWidth/2.0+Appearance.pageContainerTitleBarItemWidth*CGFloat(index)-8, y: self.frame.height-4, width: 16, height: 4)
        }
    }


}

extension PageContainerTitleBar: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.indicator.backgroundColor(style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor)
        self.choicesBar.reloadData()
    }
}


@objcMembers open class ChoiceItemCell: UICollectionViewCell {
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).textAlignment(.center).textColor(UIColor.theme.neutralColor1).font(UIFont.theme.bodyLarge).backgroundColor(.clear)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.content)
        Theme.registerSwitchThemeViews(view: self)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
    }
    
    public func refresh(item: ChoiceItem) {
        self.content.text = item.text
        if item.selected {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
            self.content.font = UIFont.theme.bodyLarge
        } else {
            self.content.textColor = Theme.style == .dark ? UIColor.theme.neutralColor4:UIColor.theme.neutralColor7
            self.content.font = UIFont.theme.bodyMedium
        }
    }
}

extension ChoiceItemCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.content.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
    }
    
}

open class ChoiceItem: NSObject {
    var text: String
    var selected: Bool
    
    init(text: String, selected: Bool = false) {
        self.text = text
        self.selected = selected
    }
}

/// Choice layout
@objcMembers open class ChoiceItemLayout: UICollectionViewFlowLayout {
    
    internal var center: CGPoint!
    internal var rows: Int!
    
    
    private var deleteIndexPaths: [IndexPath]?
    private var insertIndexPaths: [IndexPath]?
    
    public override func prepare() {
        let size = self.collectionView?.frame.size ?? .zero
        self.rows = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        self.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //Calculate per item center
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.size = self.itemSize
        if self.rows == 1 {
            attributes.center = self.center
        }
        return attributes
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        for index in 0 ..< self.rows {
            let indexPath = IndexPath(item: index, section: 0)
            attributesArray.append(self.layoutAttributesForItem(at:indexPath)!)
        }
        return attributesArray
    }
    
    
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        self.deleteIndexPaths = [IndexPath]()
        self.insertIndexPaths = [IndexPath]()
        
        for updateItem in updateItems {
            if updateItem.updateAction == UICollectionViewUpdateItem.Action.delete {
                guard let indexPath = updateItem.indexPathBeforeUpdate else { return }
                self.deleteIndexPaths?.append(indexPath)
            } else if updateItem.updateAction == UICollectionViewUpdateItem.Action.insert {
                guard let indexPath = updateItem.indexPathAfterUpdate else { return }
                self.insertIndexPaths?.append(indexPath)
            }
        }
        
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.deleteIndexPaths = nil
        self.insertIndexPaths = nil
    }
    
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //Appear animation
        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if self.insertIndexPaths?.contains(itemIndexPath) ?? false {
            if attributes != nil {
                attributes = self.layoutAttributesForItem(at: itemIndexPath)
                attributes?.alpha = 0.0
                attributes?.center = CGPointMake(self.center.x, self.center.y)
            }
        }
        
        
        return attributes
    }
    
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Disappear animation
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        if self.deleteIndexPaths?.contains(itemIndexPath) ?? false {
            if attributes != nil {
                attributes = self.layoutAttributesForItem(at: itemIndexPath)
                
                attributes?.alpha = 0.0
                attributes?.center = CGPointMake(self.center.x, self.center.y)
                attributes?.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
            }
        }
        
        return attributes
    }
    
    

}

