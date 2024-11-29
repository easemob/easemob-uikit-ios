//
//  MessageInputExtensionView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/7/31.
//

import UIKit

@objc open class MessageInputExtensionView: UIView,UIScrollViewDelegate {

    public private(set) var items = [ActionSheetItemProtocol]()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
            
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.items = Appearance.chat.inputExtendActions
        self.scrollView.bounces = false
        self.isUserInteractionEnabled = false
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        self.scrollView.isPagingEnabled = true
        self.scrollView.isScrollEnabled = true
        self.addSubViews([self.scrollView,self.pageControl])
        self.setupViews()
        self.backgroundColor = .clear
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupMenuItems()
    }
    
    private func setupViews() {
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor,constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -32),
            
            pageControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        self.scrollView.delegate = self
    }

    deinit {
        consoleLogInfo("deinit \(self.swiftClassName ?? "")", type: .debug)
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 首先检查触摸点是否在 menuList 的范围内
        if self.scrollView.frame.contains(point) {
            // 将点从 self 的坐标系转换到 menuList 的坐标系
            let convertedPoint = self.convert(point, to: self.scrollView)
            // 在 menuList 中查找可以处理该事件的视图
            if let hitView = self.scrollView.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        
        // 如果触摸点不在 menuList 内或 menuList 无法处理该事件，
        // 则调用父类的 hitTest 方法
        return super.hitTest(point, with: event)
    }
    
    private func setupMenuItems() {
        // Remove existing subviews
        self.scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        let pageWidth = self.scrollView.frame.width
        let pageHeight: CGFloat = self.items.count <= 4 ? 100 : 198
        
        let horizontalMargin: CGFloat = 31
        let horizontalSpacing: CGFloat = 24
        let verticalSpacing: CGFloat = 12
        
        var itemWidth = (pageWidth - 2 * horizontalMargin - 3 * horizontalSpacing) / 4
        if itemWidth < 64 {
            itemWidth = 64
        }
        let itemHeight = (pageHeight - verticalSpacing) / 2
        
        let numberOfPages = Int(ceil(Double(self.items.count) / 8.0))
        self.pageControl.numberOfPages = numberOfPages
        self.pageControl.isHidden = numberOfPages <= 1
        
        self.scrollView.contentSize = CGSize(width: pageWidth * CGFloat(numberOfPages), height: pageHeight)
        
        // Always start from the left margin
        let leftMargin = horizontalMargin
        
        for (index, item) in self.items.enumerated() {
            let pageIndex = index / 8
            let itemIndex = index % 8
            
            // Calculate row and column based on itemIndex
            let row = itemIndex / 4
            let column = itemIndex % 4
            
            let x = CGFloat(pageIndex) * pageWidth + leftMargin + CGFloat(column) * (itemWidth + horizontalSpacing)
            let y = CGFloat(row) * (itemHeight + verticalSpacing)
            
            let itemView = MenuItemView(frame: CGRect(x: x, y: y, width: itemWidth, height: itemHeight))
            
            itemView.refresh(item: item)
            self.scrollView.addSubview(itemView)
        }
    }



    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        self.pageControl.currentPage = Int(pageIndex)
    }

}

extension MessageInputExtensionView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor = style == .dark ? UIColor.theme.neutralColor1 : UIColor.theme.neutralColor98
        
        self.pageControl.pageIndicatorTintColor = style == .dark ? UIColor.theme.neutralColor3 : UIColor.theme.neutralColor9
        self.pageControl.currentPageIndicatorTintColor = style == .dark ? UIColor.theme.neutralColor9:UIColor.theme.neutralColor5
    }
    
    
}

@objc open class MenuItemView: UIView {
    
    public private(set) lazy var cover: UIView = {
        UIView(frame:CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width)).cornerRadius(12)
    }()
    
    public private(set) lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: self.cover.frame.width / 2.0 - 24, y: self.cover.frame.height / 2.0 - 24, width: 48, height: 48)).contentMode(.scaleAspectFit)
    }()

    public private(set) lazy var name: UILabel = {
        UILabel(frame: CGRect(x: 0, y: self.cover.frame.maxY + 8, width: self.frame.width, height: 18)).textAlignment(.center).font(UIFont.theme.bodySmall).textColor(UIColor.theme.neutralColor1).backgroundColor(.clear)
    }()
    
    public private(set) var item: ActionSheetItemProtocol?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTap)))
        self.addSubViews([self.cover,self.name])
        self.cover.addSubview(self.icon)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 首先检查触摸点是否在 cover 的范围内
        if self.cover.frame.contains(point) {
            // 将点从 self 的坐标系转换到 cover 的坐标系
            let convertedPoint = self.convert(point, to: self.cover)
            // 在 cover 中查找可以处理该事件的视图
            if let hitView = self.cover.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        
        // 如果触摸点不在 cover 内或 cover 无法处理该事件，
        // 则调用父类的 hitTest 方法
        return super.hitTest(point, with: event)
    }
    
    @objc private func onTap() {
        self.cover.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor3 : UIColor.theme.neutralColor9
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+1) {
            self.switchTheme(style: Theme.style)
        }
        if let item = self.item {
            item.action?(item, self)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let itemWidth = min(self.frame.width, self.frame.height)
        self.cover.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        self.icon.frame = CGRect(x: self.cover.frame.width / 2.0 - 16, y: self.cover.frame.height / 2.0 - 16, width: 32, height: 32)
        self.name.frame = CGRect(x: 0, y: self.cover.frame.maxY + 8, width: self.frame.width, height: 18)
        self.name.center.x = self.cover.center.x
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func refresh(item: ActionSheetItemProtocol) {
        self.item = item
        self.icon.image =  item.image
        self.name.text = item.title
        self.switchTheme(style: Theme.style)
    }
}

extension MenuItemView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.cover.backgroundColor = style == .dark ? UIColor.theme.neutralColor2 : UIColor.theme.neutralColor95
        self.name.textColor = style == .dark ? UIColor.theme.neutralColor7 : UIColor.theme.neutralColor3
        self.icon.image = self.icon.image?.withTintColor(style == .dark ? UIColor.theme.neutralColor9 : UIColor.theme.neutralColor3, renderingMode: .automatic)
    }
}
