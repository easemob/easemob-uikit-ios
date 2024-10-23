//
//  UIKitDSL.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/16.
//

import Foundation
import UIKit


/// Example
//private lazy var pop: UIButton = {
//    UIButton(type: .custom).frame(CGRect(x: 100, y: 100, width: 100, height: 50)).title("测试", .normal).font(.systemFont(ofSize: 15)).textColor(.black, .normal).addTargetFor(self, action: #selector(popAction), for: .touchUpInside)
//}()

/**
 A set of convenience methods for configuring UIView properties, such as corner radius, background color, gradient, content mode, layer properties, user interaction, tag, center, and transform. 
 
 This extension provides a set of methods that can be used to configure the properties of a UIView instance. These methods include setting the corner radius, background color, gradient, content mode, layer properties, user interaction, tag, center, and transform. 
 
 - Author: UIKitDSL.swift
 - Version: 1.0
 - Date: August 2021
 */
public enum CornerRadius: UInt {
    case extraSmall = 4
    case small = 8
    case medium = 16
    case large = 32
}

public extension UIView {
    
    func middleShowBothSidesAnimation() {
        
        self.transform = CGAffineTransform(scaleX: 0, y: 1)

        UIView.animate(withDuration: 1.0, animations: {
            self.transform = CGAffineTransform.identity
        })
    }
    
    @discardableResult
    func cornerRadius(_ value: CornerRadius , _ corners: [UIRectCorner] , _ color: UIColor , _ width: CGFloat) -> Self {
        let view = self
        view.clipsToBounds = true
        var radius = self.frame.height/2.0
        if value != .large {
            radius = CGFloat(value.rawValue)
        }
        let corner = UIRectCorner(corners)
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer().frame(self.bounds).borderColor(color.cgColor).borderWidth(width).path(maskPath.cgPath)
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        return view
    }
    
    @discardableResult
    func cornerRadius(_ value: CornerRadius) -> Self  {
        let view = self
        var radius = CGFloat(value.rawValue)
        if value == .large {
            radius = self.frame.height/2.0
            if radius == 0 {
                radius = (self.heightAnchor as? NSLayoutConstraint)?.constant ?? 0
            }
        }
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        return view
    }
    
    @discardableResult
    func cornerRadiusMask(_ value: CornerRadius,_ mask: Bool) -> Self {
        let view = self
        view.layer.masksToBounds = mask
        var radius = self.frame.height/2.0
        if value != .large {
            radius = CGFloat(value.rawValue)
        }
        view.layer.cornerRadius = radius
        return view
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        let view = self
        view.backgroundColor = color
        return view
    }
    
    @discardableResult
    func createGradient(_ colors: [UIColor], _ points: [CGPoint],_ locations: [NSNumber]) -> Self {
        let gradientColors: [CGColor] = colors.map { $0.cgColor }
        let startPoint = points[0]
        let endPoint = points[1]
        let gradientLayer = CAGradientLayer().colors(gradientColors).startPoint(startPoint).endPoint(endPoint).frame(bounds).backgroundColor(UIColor.clear.cgColor).locations(locations)
        layer.insertSublayer(gradientLayer, at: 0)
        return self
    }
    
    
    ///  单边圆角
    /// - Parameters:
    ///   - radius: 弧度
    ///   - corners: [左上角，右上角，左下角，右下角]
    ///   - color: layer's borderColor
    ///   - width: layer's borderWidth
    /// - Returns: Self
    @discardableResult
    func cornerRadius(_ radius: CGFloat , _ corners: [UIRectCorner] , _ color: UIColor , _ width: CGFloat) -> Self {
        let view = self
        view.clipsToBounds = true
        let corner = UIRectCorner(corners)
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer().frame(self.bounds).borderColor(color.cgColor).borderWidth(width).path(maskPath.cgPath)
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        return view
    }
    
    @discardableResult
    func contentMode(_ mode: UIView.ContentMode) -> Self {
        let view = self
        view.contentMode = mode
        return view
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self  {
        let view = self
        view.clipsToBounds = true
        view.layer.cornerRadius = radius
        return view
    }
    
    @discardableResult
    func cornerRadiusMask(_ radius: CGFloat,_ mask: Bool) -> Self {
        let view = self
        view.layer.masksToBounds = mask
        view.layer.cornerRadius = radius
        return view
    }
    
    @discardableResult
    func layerProperties(_ color: UIColor,_ width: CGFloat) -> Self {
        let view = self
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = width
        return view
    }
    
    @discardableResult
    func isUserInteractionEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isUserInteractionEnabled = enable
        return view
    }
    
    @discardableResult
    func tag(_ tag: Int) -> Self {
        let view = self
        view.tag = tag
        return view
    }
    
    @discardableResult
    func center(_ point: CGPoint) -> Self {
        let view = self
        view.center = point
        return view
    }
    
    @discardableResult
    func transform(_ transform: CGAffineTransform) -> Self {
        let view = self
        view.transform = transform
        return view
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func transform3D(_ transform3D: CATransform3D) -> Self {
        let view = self
        view.transform3D = transform3D
        return view
    }
    
    @discardableResult
    func isMultipleTouchEnabled(_ isMultipleTouchEnabled: Bool) -> Self {
        let view = self
        view.isMultipleTouchEnabled = isMultipleTouchEnabled
        return view
    }
    
    @discardableResult
    func isExclusiveTouch(_ isExclusiveTouch: Bool) -> Self {
        let view = self
        view.isExclusiveTouch = isExclusiveTouch
        return view
    }
    
    /// Put all the subviews to be added in the array in order and add them at once
    /// - Parameter views: subviews
    func addSubViews(_ views: [UIView]) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    @discardableResult
    func addLayer(_ layer: CALayer) -> Self {
        let view = self
        view.layer.addSublayer(layer)
        return view
    }
    
}

public extension UILabel {

    @discardableResult
    func text(_ text: String?) -> Self {
        let view = self
        view.text = text
        return view
    }
    
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        let view = self
        view.textAlignment = textAlignment
        return view
    }
    
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        let view = self
        view.font = font
        return view
    }
    
    @discardableResult
    func textColor(_ textColor: UIColor!) -> Self {
        let view = self
        view.textColor = textColor
        return view
    }
    
    @discardableResult
    func shadowColor(_ shadowColor: UIColor?) -> Self {
        let view = self
        view.shadowColor = shadowColor
        return view
    }
    
    @discardableResult
    func shadowOffset(_ shadowOffset: CGSize) -> Self {
        let view = self
        view.shadowOffset = shadowOffset
        return view
    }
    
    @discardableResult
    func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        let view = self
        view.lineBreakMode = lineBreakMode
        return view
    }
    
    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> Self {
        let view = self
        view.attributedText = attributedText
        return view
    }
    
    @discardableResult
    func highlightedTextColor(_ highlightedTextColor: UIColor?) -> Self {
        let view = self
        view.highlightedTextColor = highlightedTextColor
        return view
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> Self {
        let view = self
        view.isHighlighted = isHighlighted
        return view
    }
    
    @discardableResult
    func userInteractionEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isUserInteractionEnabled = enable
        return view
    }
    
    @discardableResult
    func isEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isEnabled = enable
        return view
    }
    
    @discardableResult
    func numberOfLines(_ num: Int) -> Self {
        let view = self
        view.numberOfLines = num
        return view
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ width: Bool) -> Self {
        let view = self
        view.adjustsFontSizeToFitWidth = width
        return view
    }
    
}

public extension UIButton {
    
    @discardableResult
    func setGradientBackground(colors: [UIColor], cornerRadius: CGFloat) -> Self {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = cornerRadius
        
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, UIScreen.main.scale)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(backgroundImage, for: .normal)
        return self
    }
    
    @discardableResult
    func updateGradientColors(for state: UIControl.State, colors: [UIColor]) -> Self {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = layer.cornerRadius
        
        UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, false, UIScreen.main.scale)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(backgroundImage, for: state)
        return self
    }
    
    @discardableResult
    func frame(_ frame: CGRect) -> Self {
        let view = self
        view.frame = frame
        return view
    }
    
    @discardableResult
    func userInteractionEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isUserInteractionEnabled = enable
        return view
    }
    
    @discardableResult
    func isEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isEnabled = enable
        return view
    }
    
    @discardableResult
    func title(_ title: String?, _ state: UIControl.State) -> Self  {
        let view = self
        view.setTitle(title, for: state)
        return view
    }
    
    @discardableResult
    func image(_ image: UIImage?, _ state: UIControl.State) -> Self {
        let view = self
        view.setImage(image, for: state)
        return view
    }
    
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        let view = self
        view.titleLabel?.font = font
        return view
    }
    
    @discardableResult
    func textColor(_ textColor: UIColor!, _ state: UIControl.State) -> Self {
        let view = self
        view.setTitleColor(textColor, for: state)
        return view
    }
    
    @discardableResult
    func backgroundImg(_ backgroundImg: UIImage, _ state: UIControl.State) -> Self {
        let view = self
        view.backgroundImage(for: state)
        return view
    }
    
    @discardableResult
    func imageEdgeInsets(_ edge: UIEdgeInsets) -> Self {
        let view = self
        view.imageEdgeInsets = edge
        return view
    }
    
    @discardableResult
    func titleEdgeInsets(_ edge: UIEdgeInsets) -> Self {
        let view = self
        view.titleEdgeInsets = edge
        return view
    }
    
    @discardableResult
    func contentEdgeInsets(_ edge: UIEdgeInsets) -> Self {
        let view = self
        view.contentEdgeInsets = edge
        return view
    }
    
    @discardableResult
    func attributedTitle(_ title: NSAttributedString?, _ state: UIControl.State) -> Self {
        let view = self
        view.setAttributedTitle(title, for: state)
        return view
    }
    
    @discardableResult
    func addTargetFor(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) -> Self {
        let view = self
        view.addTarget(target, action: action, for: controlEvents)
        return view
    }
}

public extension UITextField {
    
    @discardableResult
    func userInteractionEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isUserInteractionEnabled = enable
        return view
    }
    
    @discardableResult
    func isEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isEnabled = enable
        return view
    }
    
    @discardableResult
    func text(_ txt: String?) -> Self {
        let view = self
        view.text = txt
        return view
    }
    
    @discardableResult
    func placeholder(_ txt: String?) -> Self {
        let view = self
        view.placeholder = txt
        return view
    }
    
    @discardableResult
    func attributedText(_ attribute: NSAttributedString?) -> Self {
        let view = self
        view.attributedText = attribute
        return view
    }
    
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        let view = self
        view.textAlignment = textAlignment
        return view
    }
    
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        let view = self
        view.font = font
        return view
    }
    
    @discardableResult
    func textColor(_ textColor: UIColor!) -> Self {
        let view = self
        view.textColor = textColor
        return view
    }
    
    @discardableResult
    func delegate(_ del: UITextFieldDelegate?) -> Self {
        let view = self
        view.delegate = del
        return view
    }
    
    @discardableResult
    func clearButtonMode(_ clearMode: UITextField.ViewMode) -> Self {
        let view = self
        view.clearButtonMode = clearMode
        return view
    }
    
    @discardableResult
    func leftView(_ left: UIView?, _ model: UITextField.ViewMode) -> Self {
        let view = self
        view.leftView = left
        view.leftViewMode = model
        return view
    }
    
    @discardableResult
    func rightView(_ right: UIView?, _ model: UITextField.ViewMode) -> Self {
        let view = self
        view.rightView = right
        view.rightViewMode = model
        return view
    }
    
    @discardableResult
    func inputView(_ input: UIView?) -> Self {
        let view = self
        view.inputView = input
        return view
    }
    
    @discardableResult
    func inputAccessoryView(_ input: UIView?) -> Self {
        let view = self
        view.inputAccessoryView = input
        return view
    }
    
    @discardableResult
    func borderStyle(_ style: UITextField.BorderStyle) -> Self {
        let view = self
        view.borderStyle = style
        return view
    }
}

public extension UITextView {
    
    @discardableResult
    func userInteractionEnabled(_ enable: Bool) -> Self {
        let view = self
        view.isUserInteractionEnabled = enable
        return view
    }
    
    @discardableResult
    func isEditable(_ enable: Bool) -> Self {
        let view = self
        view.isEditable = enable
        return view
    }
    
    @discardableResult
    func text(_ txt: String?) -> Self {
        let view = self
        view.text = txt
        return view
    }
    
    @discardableResult
    func attributedText(_ attribute: NSAttributedString?) -> Self {
        let view = self
        view.attributedText = attribute
        return view
    }
    
    @discardableResult
    func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        let view = self
        view.textAlignment = textAlignment
        return view
    }
    
    @discardableResult
    func font(_ font: UIFont!) -> Self {
        let view = self
        view.font = font
        return view
    }
    
    @discardableResult
    func textColor(_ textColor: UIColor!) -> Self {
        let view = self
        view.textColor = textColor
        return view
    }
    
    @discardableResult
    func delegate(_ del: UITextViewDelegate?) -> Self {
        let view = self
        view.delegate = del
        return view
    }
}

public extension UITableView {
    
    @discardableResult
    func tableHeaderView(_ header: UIView?) -> Self {
        let view = self
        view.tableHeaderView = header
        return view
    }
    
    @discardableResult
    func tableFooterView(_ footer: UIView?) -> Self {
        let view = self
        view.tableFooterView = footer
        return view
    }
    
    @discardableResult
    func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) -> Self {
        let view = self
        view.register(cellClass, forCellReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func registerCell(_ nib: UINib?, _ identifier: String) -> Self {
        let view = self
        view.register(nib, forCellReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func register(_ aClass: AnyClass?, _ identifier: String) -> Self {
        let view = self
        view.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func registerView(_ nib: UINib?, _ identifier: String) -> Self {
        let view = self
        view.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func delegate(_ del: UITableViewDelegate?) -> Self {
        let view = self
        view.delegate = del
        return view
    }
    
    @discardableResult
    func dataSource(_ del: UITableViewDataSource?) -> Self {
        let view = self
        view.dataSource = del
        return view
    }
    
    @discardableResult
    func rowHeight(_ height: CGFloat) -> Self {
        let view = self
        view.rowHeight = height
        return view
    }
    
    @discardableResult
    func sectionHeaderHeight(_ height: CGFloat) -> Self {
        let view = self
        view.sectionHeaderHeight = height
        return view
    }
    
    @discardableResult
    func sectionFooterHeight(_ height: CGFloat) -> Self {
        let view = self
        view.sectionFooterHeight = height
        return view
    }
    
    @discardableResult
    func estimatedRowHeight(_ height: CGFloat) -> Self {
        let view = self
        view.estimatedRowHeight = height
        return view
    }
    
    @discardableResult
    func estimatedSectionHeaderHeight(_ height: CGFloat) -> Self {
        let view = self
        view.estimatedSectionHeaderHeight = height
        return view
    }
    
    @discardableResult
    func estimatedSectionFooterHeight(_ height: CGFloat) -> Self {
        let view = self
        view.estimatedSectionFooterHeight = height
        return view
    }
    
    @discardableResult
    func separatorInset(edge: UIEdgeInsets) -> Self {
        let view = self
        view.separatorInset = edge
        return view
    }
    
    @discardableResult
    func separatorStyle(_ style: UITableViewCell.SeparatorStyle) -> Self {
        let view = self
        view.separatorStyle = style
        return view
    }
    
    @discardableResult
    func separatorColor(_ color: UIColor?) -> Self {
        let view = self
        view.separatorColor = color
        return view
    }
    
    @discardableResult
    func separatorEffect(_ effect: UIVisualEffect?) -> Self {
        let view = self
        view.separatorEffect = effect
        return view
    }
    
    @discardableResult
    func showsVerticalScrollIndicator(_ value: Bool) -> Self {
        let view = self
        view.showsVerticalScrollIndicator = value
        return view
    }
    
    @discardableResult
    func showsHorizontalScrollIndicator(_ value: Bool) -> Self {
        let view = self
        view.showsHorizontalScrollIndicator = value
        return view
    }
    
}

public extension UICollectionView {
    
    @discardableResult
    func collectionViewLayout(_ layout: UICollectionViewLayout) -> Self {
        let view = self
        view.collectionViewLayout = layout
        return view
    }
    
    @discardableResult
    func delegate(_ del: UICollectionViewDelegate?) -> Self {
        let view = self
        view.delegate = del
        return view
    }
    
    @discardableResult
    func dataSource(_ del: UICollectionViewDataSource?) -> Self {
        let view = self
        view.dataSource = del
        return view
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func dragDelegate(_ del: UICollectionViewDragDelegate?) -> Self {
        let view = self
        view.dragDelegate = del
        return view
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func dropDelegate(_ del: UICollectionViewDropDelegate?) -> Self {
        let view = self
        view.dropDelegate = del
        return view
    }
    
    @available(iOS 11.0, *)
    @discardableResult
    func dragInteractionEnabled(enabled: Bool) -> Self {
        let view = self
        view.dragInteractionEnabled = enabled
        return view
    }
    
    @discardableResult
    func registerCell(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) -> Self {
        let view = self
        view.register(cellClass, forCellWithReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func registerCell(_ nib: UINib?, _ identifier: String) -> Self {
        let view = self
        view.register(nib, forCellWithReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func registerView(_ viewClass: AnyClass?, _ elementKind: String, _ identifier: String) -> Self {
        let view = self
        view.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: identifier)
        return view
    }

    @discardableResult
    func registerView(_ nib: UINib?, _ kind: String, _ identifier: String) -> Self {
        let view = self
        view.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        return view
    }
    
    @discardableResult
    func showsVerticalScrollIndicator(_ value: Bool) -> Self {
        let view = self
        view.showsVerticalScrollIndicator = value
        return view
    }
    
    @discardableResult
    func showsHorizontalScrollIndicator(_ value: Bool) -> Self {
        let view = self
        view.showsHorizontalScrollIndicator = value
        return view
    }
    
}

public extension UIAlertController {
    
    @discardableResult
    func addAlertAction(_ action: UIAlertAction) -> Self {
        let alert = self
        alert.addAction(action)
        return alert
    }
    
    @discardableResult
    func addAlertTextField(_ configurationHandler: ((UITextField) -> Void)? = nil) -> Self {
        let alert = self
        alert.addTextField(configurationHandler: configurationHandler)
        return alert
    }
    
}

public extension UIDatePicker {
    
    @discardableResult
    func datePickerMode(_ mode: UIDatePicker.Mode ) -> Self {
        let view = self
        view.datePickerMode = mode
        return view
    }
    
    @discardableResult
    func locale(_ local: Locale?) -> Self {
        let view = self
        view.locale = local
        return view
    }
    
    @discardableResult
    func calendar(_ cal: Calendar!) -> Self {
        let view = self
        view.calendar = cal
        return view
    }
    
    @discardableResult
    func timeZone(_ zone: TimeZone?) -> Self {
        let view = self
        view.timeZone = zone
        return view
    }
    
    @discardableResult
    func date(_ date: Date) -> Self {
        let view = self
        view.date = date
        return view
    }
    
    @discardableResult
    func minimumDate(_ date: Date) -> Self {
        let view = self
        view.minimumDate = date
        return view
    }
    
    @discardableResult
    func maximumDate(_ date: Date) -> Self {
        let view = self
        view.maximumDate = date
        return view
    }
    
}

public extension UIImageView {
    
    @discardableResult
    func image(_ img: UIImage?) -> Self {
        let view = self
        view.image = img
        return view
    }
    
    @discardableResult
    func highlightedImage(_ img: UIImage?) -> Self {
        let view = self
        view.highlightedImage = img
        return view
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func preferredSymbolConfiguration(_ prefer: UIImage.SymbolConfiguration?) -> Self {
        let view = self
        view.preferredSymbolConfiguration = prefer
        return view
    }
    
    @discardableResult
    func highlighted(_ value: Bool) -> Self {
        let view = self
        view.isHighlighted = value
        return view
    }
    
    @discardableResult
    func animationImages(_ images: [UIImage]?) -> Self {
        let view = self
        view.animationImages = images
        return view
    }
    
    @discardableResult
    func highlightedAnimationImages(_ images: [UIImage]?) -> Self {
        let view = self
        view.highlightedAnimationImages = images
        return view
    }
    
    @discardableResult
    func animationDuration(_ duration: TimeInterval) -> Self {
        let view = self
        view.animationDuration = duration
        return view
    }
    
    @discardableResult
    func animationRepeatCount(_ count: Int) -> Self {
        let view = self
        view.animationRepeatCount = count
        return view
    }
    
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        let view = self
        view.tintColor = color
        return view
    }
}

public extension UIBezierPath {
    @discardableResult
    func cgPath(_ path: CGPath) -> Self {
        let bezier = self
        bezier.cgPath = path
        return bezier
    }
    
    @discardableResult
    func moveTo(_ point: CGPoint) -> Self {
        let bezier = self
        bezier.move(to: point)
        return bezier
    }
    
    @discardableResult
    func addLineTo(_ point: CGPoint) -> Self {
        let bezier = self
        bezier.addLine(to: point)
        return bezier
    }
    
    @discardableResult
    func lineWidth(_ width: CGFloat) -> Self {
        let bezier = self
        bezier.lineWidth = width
        return bezier
    }
    
    @discardableResult
    func lineCapStyle(_ style: CGLineCap) -> Self {
        let bezier = self
        bezier.lineCapStyle = style
        return bezier
    }
    
    @discardableResult
    func lineJoinStyle(_ style: CGLineJoin) -> Self {
        let bezier = self
        bezier.lineJoinStyle = style
        return bezier
    }
    
    @discardableResult
    func miterLimit(_ miter: CGFloat) -> Self {
        let bezier = self
        bezier.miterLimit = miter
        return bezier
    }
    
    @discardableResult
    func flatness(_ flat: CGFloat) -> Self {
        let bezier = self
        bezier.flatness = flat
        return bezier
    }
    
    @discardableResult
    func usesEvenOddFillRule(_ rule: Bool) -> Self {
        let bezier = self
        bezier.usesEvenOddFillRule = rule
        return bezier
    }
    
}
