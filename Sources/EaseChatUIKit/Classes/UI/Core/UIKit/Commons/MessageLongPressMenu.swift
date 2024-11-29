//
//  MessageLongPressMenu.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/7/23.
//

import UIKit

public let PopItemWidth = CGFloat(68)
public let PopItemHeight = CGFloat(58)
public let PopLeftRightMargin = CGFloat(4)
public let PopTopBottomMargin = CGFloat(4)

public let PopArrowSize = CGSize(width: 16, height: 10)
public let HeaderTopBottomMargin = CGFloat(12)

@objc final public class MessageLongPressMenu: UIView {

    public static let shared = MessageLongPressMenu()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: PopItemWidth, height: PopItemHeight)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: menuSize.width, height: menuSize.height), collectionViewLayout: layout).registerCell(PopMenuCollectionViewCell.self, forCellReuseIdentifier: "PopMenuCollectionViewCell").delegate(self).dataSource(self).backgroundColor(.clear)
        collection.contentInset = UIEdgeInsets(top: PopTopBottomMargin, left: PopLeftRightMargin, bottom: PopTopBottomMargin, right: PopLeftRightMargin)
        collection.bounces = false
        collection.contentInsetAdjustmentBehavior = .never
        return collection
    }()
    
    public private(set) var items: [ActionSheetItemProtocol] = []
    
    public private(set) var targetView: UIView?
    
    public private(set) var header: UIView?
    
    public private(set) lazy var separateLine: UIView = {
        UIView(frame: CGRect(x: 18, y: self.collectionView.frame.height, width: self.popView.frame.width-36, height: 0.5))
    }()
    
    public private(set) lazy var popArrow: PopMenuArrow = {
        let arrow = PopMenuArrow(frame: CGRect(x: 0, y: 0, width: PopArrowSize.width, height: PopArrowSize.height))
        self.addSubview(arrow)
        return arrow
    }()
    
    public private(set) var startRect: CGRect = .zero
    
    public private(set) var endRect: CGRect = .zero
    
    public private(set) var visibleHeight: CGFloat = 0
    
    public private(set) var targetViewFrame: CGRect = .zero
    
    public private(set) var tempStartRect: CGRect = .zero
    
    public private(set) var tempEndRect: CGRect = .zero
    
    public private(set) var topSelectWidth: CGFloat = 0
    
    public private(set) var bottomSelectWidth: CGFloat = 0
    
    public private(set) var contentLeftMargin: CGFloat = 0
    
    public private(set) var contentRightMargin: CGFloat = 0
    
    public private(set) lazy var popView: UIView = {
        let pop = UIView(frame: .zero)
        pop.layer.cornerRadius = Appearance.avatarRadius == .large ? 12:4
        pop.layer.shadowOffset = CGSize(width: 0, height: 4)
        pop.layer.shadowOpacity = 1
        pop.layer.shadowRadius = 4
        pop.addSubview(self.collectionView)
        self.addSubview(pop)
        return pop
    }()
    
    lazy var shadowLayer0: CALayer = {
        let shadowPath0 = UIBezierPath(roundedRect: self.popView.bounds, cornerRadius: 0)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 3
        layer0.shadowOffset = CGSize(width: 0, height: 1)
        layer0.bounds = self.popView.bounds
        layer0.position = self.popView.center
        return layer0
    }()
    
    lazy var shadowLayer1: CALayer = {
        let shadowPath1 = UIBezierPath(roundedRect: self.popView.bounds, cornerRadius: 0)
        let layer1 = CALayer()
        layer1.shadowPath = shadowPath1.cgPath
        layer1.shadowColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2).cgColor
        layer1.shadowOpacity = 1
        layer1.shadowRadius = 8
        layer1.shadowOffset = CGSize(width: 0, height: 4)
        layer1.bounds = self.popView.bounds
        layer1.position = self.popView.center
        return layer1
    }()
    
    private var action: ((ActionSheetItemProtocol, PopMenuCollectionViewCell?) -> Void)?
        
    public var menuSize = CGSize.zero
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func hiddenMenu() {
        self.header?.removeFromSuperview()
        self.removeFromSuperview()
        self.isHidden = true
        
        if let target = self.targetView, let textView = self.getSubTextView(in: target), !textView.isFirstResponder {
            (textView as? LinkRecognizeTextView)?.selectedRange = NSRange(location: 0, length: 0)
        }

    }
    
    func getSubTextView(in view: UIView) -> UIView? {
        if view is LinkRecognizeTextView {
            return view
        } else {
            for subview in view.subviews {
                if let res = self.getSubTextView(in: subview) {
                    return res
                }
            }
        }
        return nil
    }

    func clearTextViewSelection(view: UIView) {
        if view is UITextView {
            (view as! UITextView).selectedRange = NSMakeRange(0, 0)
        } else {
            for sub in view.subviews {
                self.clearTextViewSelection(view: sub)
            }
        }
    }
    
    func clearAllData() {
        self.items.removeAll()
        self.menuSize = .zero
        self.startRect = .zero
        self.endRect = .zero
        self.visibleHeight = 0
        self.targetViewFrame = .zero
        self.tempStartRect = .zero
        self.tempEndRect = .zero
        self.topSelectWidth = 0
        self.bottomSelectWidth = 0
        self.contentLeftMargin = 0
        self.contentRightMargin = 0
        self.removeFromSuperview()
    }
    
    /// 在有效区域外部（即屏幕外） 什么都不做
    func targetViewOutValidFrame() -> Bool {
        let targetFrame = self.targetView?.convert(self.targetView?.bounds ?? .zero, to: UIApplication.shared.chat.keyWindow)
        if targetFrame?.origin.y ?? 0 > UIScreen.main.bounds.height || (targetFrame?.origin.y ?? 0 + (targetFrame?.size.height ?? 0) < 0) {
            return true
        }
        return false
    }
    
    func updateSelectSizeData() {
        guard let textView = self.targetView?.subviews.first(where: { $0 is LinkRecognizeTextView }) as? LinkRecognizeTextView else { return }

        self.contentLeftMargin = textView.textContainerInset.left
        self.contentRightMargin = textView.textContainerInset.right
        self.topSelectWidth = textView.frame.width - self.startRect.origin.x - self.contentRightMargin
        self.bottomSelectWidth = self.endRect.origin.x - self.contentLeftMargin

        if self.startRect.origin.y == self.endRect.origin.y {
            self.topSelectWidth = self.endRect.origin.x - self.startRect.origin.x
            self.bottomSelectWidth = self.topSelectWidth
        }

        guard let window = UIApplication.shared.chat.keyWindow else { return }
        self.tempStartRect = textView.convert(self.startRect, to: window)
        self.tempEndRect = textView.convert(self.endRect, to: window)

        // 文本特别长，menu显示在文本正中间
        if self.tempStartRect.minY - StatusBarHeight < self.menuSize.height + PopArrowSize.height &&
            self.visibleHeight - (self.tempEndRect.maxY - self.tempStartRect.minY) - 10 < self.menuSize.height + PopArrowSize.height {

            let targetRect = textView.bounds
            let targetFrame = textView.convert(targetRect, to: window)
            self.tempStartRect.origin.x = targetFrame.origin.x + self.contentLeftMargin
            self.tempStartRect.origin.y = self.visibleHeight / 2.0
            self.topSelectWidth = textView.frame.width - self.contentLeftMargin - self.contentRightMargin
        }
    }
    
    func updateMenuSize() {
        let line = (self.items.count + 4) / 5
        let width = (line <= 1 ? 5:CGFloat(min(self.items.count, 5))) * PopItemWidth + PopLeftRightMargin * 2
        let height = CGFloat(line) * PopItemHeight + PopTopBottomMargin * 2 + 8 * (CGFloat(line)-1)
        self.menuSize = CGSize(width: width, height: height)
        self.collectionView.frame = CGRect(x: 0, y: HeaderTopBottomMargin, width: self.menuSize.width, height: self.menuSize.height)
    }

    func updateTargetViewFrame() {
        guard let window = UIApplication.shared.chat.keyWindow else { return }
        var targetFrame: CGRect
        let targetRect = self.targetView?.bounds ?? .zero
        targetFrame = self.targetView?.convert(targetRect, to: window) ?? .zero
        
        if !self.startRect.equalTo(CGRect.zero) {
            targetFrame.origin.y += self.startRect.origin.y
            targetFrame.size.height = self.endRect.origin.y - self.startRect.origin.y + self.endRect.size.height
        }
        
        let menuHeight = self.menuSize.height + StatusBarHeight
        
        if targetFrame.origin.y < 0 {
            /// 先把上半部分移除
            targetFrame.size.height += targetFrame.origin.y
            targetFrame.origin.y = 0
            targetFrame.size.height = min(self.visibleHeight, targetFrame.size.height)
        } else {
            if targetFrame.origin.y < menuHeight {
                /// 文本特别长，menu显示在文本正中间
                if self.visibleHeight - targetFrame.origin.y - targetFrame.size.height < menuHeight {
                    targetFrame.origin.y += (self.visibleHeight - targetFrame.origin.y) / 2.0
                }
            } else {
                targetFrame.size.height = min(self.visibleHeight - targetFrame.origin.y, targetFrame.size.height)
            }
        }
        
        targetFrame.origin.y = ceil(targetFrame.origin.y)
        self.targetViewFrame = targetFrame
    }
    
    func targetViewCenter() -> CGPoint {
        let targetFrame = self.targetViewFrame
        let centerX = targetFrame.origin.x + targetFrame.size.width/2.0
        let centerY = targetFrame.origin.y + targetFrame.size.height/2.0
        return CGPoint(x:centerX, y:centerY);
    }
    
    func getPopFrameWithoutReaction() -> CGRect {
        let targetFrame = self.targetViewFrame
        let targetCenter = self.targetViewCenter()
        let headerFrame = self.header?.frame ?? .zero
        let itemCount = min(self.items.count, 5)
        let menuWidth = itemCount < 5 ? CGFloat(itemCount) * PopItemWidth + PopLeftRightMargin * 2 : self.menuSize.width
        let lines: CGFloat = CGFloat(ceilf(Float(CGFloat(self.items.count/5))))
        let menuHeight = self.menuSize.height + headerFrame.height + HeaderTopBottomMargin * 2
        let spac: CGFloat = 10.0
        var popFrame = CGRect(x: (ScreenWidth-menuWidth)/2.0, y: 0, width: menuWidth, height: menuHeight+HeaderTopBottomMargin*2+headerFrame.height+(lines-1)*8+CGFloat(self.header == nil ? 0:20))
        
        let left = targetCenter.x / ScreenWidth < 0.5
        var top = targetFrame.minY < popFrame.height + PopArrowSize.height + StatusBarHeight
//        if top {
//            popFrame = CGRect(x: (ScreenWidth - menuWidth) / 2.0, y: 0, width: menuWidth, height: menuHeight + HeaderTopBottomMargin + (self.header != nil ? 16 : 0))
//        }
        if self.startRect != .zero {
            top = targetFrame.minY < popFrame.height + PopArrowSize.height + StatusBarHeight
        }
        
        if top {
            if self.startRect != .zero {
                if self.tempEndRect.maxY + popFrame.height + PopArrowSize.height > self.visibleHeight {
                    popFrame.origin.y = self.visibleHeight - popFrame.height - spac
                } else {
                    popFrame.origin.y = max(self.tempEndRect.maxY, spac) + PopArrowSize.height
                }
            } else {
                if targetFrame.maxY + popFrame.height + PopArrowSize.height > self.visibleHeight {
                    popFrame.origin.y = self.visibleHeight - popFrame.height - spac
                } else {
                    popFrame.origin.y = targetFrame.origin.y + targetFrame.size.height + PopArrowSize.height
                }
            }
        } else {
            if self.startRect != .zero {
                popFrame.origin.y = min(self.tempStartRect.minY - popFrame.height, self.visibleHeight - spac) - PopArrowSize.height
            } else {
                popFrame.origin.y = targetFrame.origin.y - popFrame.height - PopArrowSize.height
            }
        }
        
        // Align PopView center with PopArrow center
        let arrowCenterX = targetCenter.x
        if itemCount < 5,self.header == nil {
            popFrame.origin.x = arrowCenterX - menuWidth / 2.0
            
            // Ensure PopView doesn't go off screen
            if popFrame.minX < spac {
                popFrame.origin.x = spac
            } else if popFrame.maxX > ScreenWidth - spac {
                popFrame.origin.x = ScreenWidth - spac - menuWidth
            }
        } else {
            if left {
                popFrame.origin.x = max(popFrame.origin.x, spac)
            } else {
                popFrame.origin.x = min(popFrame.origin.x, ScreenWidth - spac - menuWidth)
            }
        }
        
        self.collectionView.frame = CGRect(x: 0, y: HeaderTopBottomMargin, width: menuWidth, height: self.menuSize.height)
        
        // Update header and separator line positions
        self.header?.frame = CGRect(x: CGFloat(ceilf(Float((popFrame.width-headerFrame.width))/2.0)), y: 13, width: headerFrame.width, height: headerFrame.height)
        self.separateLine.frame = CGRect(x: 18, y: (self.header?.frame.maxY ?? 0)+12, width: popFrame.width-36, height: 0.5)
        
        popFrame.origin.y = ceil(popFrame.origin.y) + (top ? 2 : -2)
        return popFrame
    }

    func getPopFrame() -> CGRect {
        let targetFrame = self.targetViewFrame
        let targetCenter = self.targetViewCenter()
        let headerFrame = self.header?.frame ?? .zero
        let menuWidth = self.menuSize.width
        let menuHeight = self.menuSize.height
        let spac: CGFloat = 10.0
        let lines: CGFloat = CGFloat(ceilf(Float(CGFloat(self.items.count/5))))
        var popFrame = CGRect(x: (ScreenWidth-menuWidth)/2.0, y: 0, width: menuWidth, height: menuHeight+HeaderTopBottomMargin*2+headerFrame.height+(lines-1)*8+CGFloat(self.header == nil ? 0:20))
        
        let left = targetCenter.x / ScreenWidth < 0.5
        var top = targetFrame.minY < popFrame.height + PopArrowSize.height + StatusBarHeight
//        if top {
//            popFrame = CGRect(x: (ScreenWidth-menuWidth)/2.0, y: 0, width: menuWidth, height: menuHeight+HeaderTopBottomMargin*2+headerFrame.height+(lines-1)*8)
//        }
        if self.startRect != .zero {
            top = targetFrame.minY < popFrame.height + PopArrowSize.height + StatusBarHeight
        }
        
        if top {
            if self.startRect != .zero {
                if self.tempEndRect.maxY + popFrame.height + PopArrowSize.height > self.visibleHeight {
                    popFrame.origin.y = self.visibleHeight - popFrame.height - spac
                } else {
                    popFrame.origin.y = max(self.tempEndRect.maxY, spac) + PopArrowSize.height
                }
                popFrame.origin.x = self.tempEndRect.maxX - self.bottomSelectWidth / 2.0 - menuWidth / 2.0
            } else {
                if targetFrame.maxY + popFrame.height + PopArrowSize.height > self.visibleHeight {
                    popFrame.origin.y = self.visibleHeight - popFrame.height - spac
                } else {
                    popFrame.origin.y = targetFrame.origin.y + targetFrame.size.height + PopArrowSize.height
                }
                self.header?.frame = CGRect(x: CGFloat(ceilf(Float((popFrame.width-headerFrame.width))/2.0)), y: 13, width: headerFrame.width, height: headerFrame.height)
                self.separateLine.frame = CGRect(x: 18, y: (self.header?.frame.maxY ?? 0)+12, width: popFrame.width-36, height: 0.5)
                self.collectionView.frame = CGRect(x: 0, y: self.separateLine.frame.maxY+HeaderTopBottomMargin, width: popFrame.width, height: self.menuSize.height)
            }
        } else {
            if self.startRect != .zero {
                popFrame.origin.y = min(self.tempStartRect.minY - popFrame.height, self.visibleHeight - spac) - PopArrowSize.height
                popFrame.origin.x = self.tempStartRect.minX + self.topSelectWidth / 2.0 - menuWidth / 2.0
            } else {
                popFrame.origin.y = targetFrame.origin.y - popFrame.height - PopArrowSize.height
                self.separateLine.frame = CGRect(x: 18, y: self.collectionView.frame.maxY+12, width: popFrame.width-36, height: 0.5)
                self.header?.frame = CGRect(x: CGFloat(ceilf(Float((popFrame.width-headerFrame.width))/2.0)), y: self.separateLine.frame.maxY+HeaderTopBottomMargin/2.0, width: headerFrame.width, height: headerFrame.height)
            }
        }
        if left {
            popFrame.origin.x = max(popFrame.origin.x, spac)
        } else {
            popFrame.origin.x = min(popFrame.origin.x, ScreenWidth - spac - menuWidth)
        }
        popFrame.origin.y = ceil(popFrame.origin.y)+(top ? 2:-2)
        return popFrame
    }

    func getArrowFrame() -> CGRect {
        let targetFrame = self.targetViewFrame
        let headerFrame = self.header?.frame ?? .zero
        let menuHeight = self.menuSize.height+headerFrame.height+24+32
        var top = targetFrame.minY < menuHeight + PopArrowSize.height + StatusBarHeight
        
        if self.startRect != .zero {
            top = targetFrame.minY < menuHeight + PopArrowSize.height + StatusBarHeight
        }
        
        var arrowFrame = CGRect(x: 0, y: 0, width: PopArrowSize.width, height: PopArrowSize.height)
        arrowFrame.origin.x = targetFrame.origin.x + targetFrame.size.width / 2.0 - arrowFrame.size.width / 2.0
        
        if top {
            if self.startRect != .zero {
                if self.tempEndRect.maxY + targetFrame.maxY + menuHeight + 24 + 32 + PopArrowSize.height > self.visibleHeight {
                    arrowFrame.origin.y = self.visibleHeight - menuHeight - 10
                } else {
                    arrowFrame.origin.y = self.tempEndRect.maxY
                }
                arrowFrame.origin.x = self.tempEndRect.maxX - self.bottomSelectWidth / 2.0 - arrowFrame.size.width / 2.0
            } else {
                if menuHeight + PopArrowSize.height < ScreenHeight - targetFrame.maxY {
                    arrowFrame.origin.y = self.popView.frame.minY-PopArrowSize.height
                } else {
                    arrowFrame.origin.y = self.popView.frame.maxY
                }
            }
            arrowFrame.origin.y = ceil(arrowFrame.origin.y)+(top ? 1:-1)
        } else {
            if self.startRect != .zero {
                arrowFrame.origin.y = min(self.tempStartRect.minY, self.visibleHeight) - PopArrowSize.height
                arrowFrame.origin.x = self.tempStartRect.origin.x + self.topSelectWidth / 2.0 - arrowFrame.size.width / 2.0
            } else {
                arrowFrame.origin.y = targetFrame.origin.y - PopArrowSize.height
            }
            arrowFrame.origin.y = ceil(arrowFrame.origin.y)+(top ? 2:-2)
        }
        return arrowFrame
    }


    func updateSubviewsLayout() {
        self.updateMenuSize()
        
        if !self.startRect.equalTo(.zero) {
            self.updateSelectSizeData()
        }
        
        self.updateTargetViewFrame()
        if self.items.count < 5,self.header == nil {
            self.popView.frame = self.getPopFrameWithoutReaction()
        } else {
            self.popView.frame = self.getPopFrame()
        }
        self.popArrow.frame = self.getArrowFrame()
        self.popView.layer.shadowColor = UIColor(red: 0.275, green: 0.306, blue: 0.325, alpha: Theme.style == .dark ? 0.3:0.15).cgColor
        if self.popArrow.frame.origin.y > popView.frame.origin.y {
            self.popArrow.transform = CGAffineTransform(rotationAngle: .pi)
        } else {
            self.popArrow.transform = .identity
        }
        
        self.collectionView.reloadData()
    }
    
    public func showMenu(items: [ActionSheetItemProtocol], targetView: UIView, header: UIView? = nil, action: ((ActionSheetItemProtocol, PopMenuCollectionViewCell?) -> Void)? = nil) {
        self.action = action
        self.hiddenMenu()
        self.isHidden = false
        self.items = items
        self.targetView = targetView
        self.header = header
        self.visibleHeight = ScreenHeight-NavigationHeight-BottomBarHeight-MessageInputBarHeight
        if self.targetViewOutValidFrame() {
            return
        }
        self.items.removeAll()
        self.items = items
        self.updateSubviewsLayout()
        if let headerView = header {
            self.separateLine.isHidden = false
            self.popView.addSubview(headerView)
            self.popView.addSubview(self.separateLine)
        } else {
            self.separateLine.isHidden = true
        }
        self.shadowLayer0.removeFromSuperlayer()
        self.shadowLayer1.removeFromSuperlayer()
        self.popView.layer.addSublayer(self.shadowLayer0)
        self.popView.layer.addSublayer(self.shadowLayer1)
        let current = UIViewController.currentController(with: targetView)
        if current?.navigationController != nil {
            current?.navigationController?.view.addSubview(self)
        } else {
            current?.view.addSubview(self)
        }
    }
    
    func hiddenMenuPoint(point: CGPoint) {
        self.hiddenMenu()
        let targetRect = self.targetView?.bounds ?? .zero
        let targetFrame = self.targetView?.convert(targetRect, to: UIApplication.shared.chat.keyWindow) ?? .zero
        if !targetFrame.contains(point),let target = self.targetView?.subviews.first(where: { $0 is LinkRecognizeTextView }) as? UITextView {
            self.clearTextViewSelection(view: target)
        }
    }
    
    func setTargetView(targetView: UIView) {
        self.targetView = targetView
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if self.targetViewFrame.contains(point) {
            (self.targetView as? UITextView)?.selectedRange = NSRange(location: 0, length: 0)
        }
        
        let hitView = super.hitTest(point, with: event)
        
        if hitView == self {
            self.hiddenMenuPoint(point: point)
            return self.superview
        }
        
        return hitView
    }


}

extension MessageLongPressMenu: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor = .clear
        self.popView.backgroundColor = style == .dark ? UIColor.theme.neutralColor2:UIColor.theme.neutralColor98
        self.separateLine.backgroundColor = Theme.style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor9
        self.shadowLayer0.shadowColor = style == .dark ? UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.15).cgColor:UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.3).cgColor
        self.shadowLayer1.shadowColor = style == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1).cgColor:UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2).cgColor
    }

}

extension MessageLongPressMenu: UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopMenuCollectionViewCell", for: indexPath) as? PopMenuCollectionViewCell else {
            return UICollectionViewCell()
        }
        if let item = self.items[safe: indexPath.row] {
            cell.refresh(item: item)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as? PopMenuCollectionViewCell
        if let item = self.items[safe: indexPath.row] {
            self.action?(item, cell)
            if let target = self.targetView {
                self.clearTextViewSelection(view: target)
            }
            self.hiddenMenu()
        }
    }
}


@objc final public class PopMenuCollectionViewCell: UICollectionViewCell {
        
    public lazy var icon: UIImageView = {
        UIImageView(frame: CGRect(x: (self.frame.width-32)/2.0, y: 3, width: 32, height: 32)).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public lazy var title: UILabel = {
        UILabel(frame: CGRect(x: 8, y: self.frame.height - 16, width: self.frame.width-20, height: 16)).font(UIFont.theme.labelSmall).backgroundColor(.clear).textAlignment(.center)
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubViews([self.icon,self.title])
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.icon.frame = CGRect(x: (self.frame.width-32)/2.0, y: 3, width: 32, height: 32)
        self.title.frame = CGRect(x: 2, y: self.icon.frame.maxY+4, width: self.frame.width-4, height: 16)
    }
        
    @objc public func refresh(item: ActionSheetItemProtocol) {
        self.icon.image = item.image?.withTintColor(Theme.style == .dark ? UIColor.theme.neutralColor9:UIColor.theme.neutralColor3)
        self.title.text = item.title
    }
}

extension PopMenuCollectionViewCell: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.title.textColor = style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
    }

}

@objc final public class PopMenuArrow: UIView {
    
    private var arrowColor: UIColor = .clear
    private var shadowColor: UIColor = Theme.style == .dark ? UIColor(white: 1, alpha: 0.3):UIColor(white: 0, alpha: 0.5)
    private var shadowOffset: CGSize = CGSize(width: 0, height: 3)
    private var shadowBlurRadius: CGFloat = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        
        let arrowWidth = rect.size.width
        let arrowHeight = rect.size.height
        
        // Create path for the arrow
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: arrowHeight))
        path.addLine(to: CGPoint(x: arrowWidth / 2.0, y: 0))
        path.addLine(to: CGPoint(x: arrowWidth, y: arrowHeight))
        path.closeSubpath()
        
        // Draw shadow
        context.saveGState()
        context.addPath(path)
        context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadowColor.cgColor)
        context.setFillColor(arrowColor.cgColor)
        context.fillPath()
        context.restoreGState()
        
        // Draw arrow
        context.addPath(path)
        context.setFillColor(arrowColor.cgColor)
        context.fillPath()
    }
}

extension PopMenuArrow: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.shadowColor = style == .dark ? UIColor(white: 1, alpha: 0.3):UIColor(white: 0, alpha: 0.5)
        self.arrowColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.setNeedsDisplay()
    }
}


@objc final public class PopMenuKeyboardManager: NSObject {
    
    public static let shared = PopMenuKeyboardManager()
    
    private var keyboardFrame: CGRect = .zero
    
    public private(set) var keyboardHeight = CGFloat(300)
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.keyboardFrame = keyboardFrame
        self.keyboardHeight = keyboardFrame.height
    }
    
    @objc func keyboardWillHidden(notification: Notification) {
        self.keyboardHeight = 0
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.keyboardFrame = keyboardFrame
        self.keyboardHeight = keyboardFrame.height
    }
}
