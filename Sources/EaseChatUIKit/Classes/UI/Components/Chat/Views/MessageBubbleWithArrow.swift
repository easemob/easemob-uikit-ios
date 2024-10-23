//
//  MessageBubbleWithArrow.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/9.
//

import UIKit

@objc public enum BubbleTowards: UInt {
    case right
    case left
}

@objcMembers open class MessageBubbleWithArrow: UIView {
    
    var sendBubbleColor: UIColor {
        Theme.style == .dark ? UIColor.theme.primaryDarkColor:UIColor.theme.primaryLightColor
    }
    
    var receiveBubbleColor: UIColor {
        Theme.style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor95
    }
    
    @MainActor public var towards = BubbleTowards.right
    
    public lazy var arrow: UIImageView = {
        UIImageView(frame: .zero).contentMode(.scaleAspectFit).backgroundColor(.clear)
    }()
    
    public lazy var bubble: UIView = {
        UIView(frame: .zero)
    }()
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc required public init(frame: CGRect, forward: BubbleTowards) {
        self.towards = forward
        super.init(frame: frame)
        self.addSubview(self.arrow)
        self.addSubview(self.bubble)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.image = UIImage(named: self.towards == .left ? "arrow_left": "arrow_right", in: .chatBundle, with: nil)?.withTintColor(self.towards == .left ? self.receiveBubbleColor:self.sendBubbleColor)
        self.bubble.backgroundColor = towards == .left ? self.receiveBubbleColor:self.sendBubbleColor
        self.arrow.frame = CGRect(x: self.towards == .left ? 0:self.frame.width-5, y: self.frame.height-10-8, width: 5, height: 8)
        self.bubble.frame = CGRect(x: self.towards == .left ? 5:0, y: 0, width: self.frame.width-5, height: self.frame.height)
        self.bubble.cornerRadius(4)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
