//
//  CustomTextView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/6/28.
//

import UIKit


@objcMembers open class CustomTextView: UIView {
    
    public let textView = PlaceHolderTextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.backgroundColor = .clear
        // 设置边距
        let top: CGFloat = 4
        let left: CGFloat = 8
        let bottom: CGFloat = 4
        let right: CGFloat = 8
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: top),
            textView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottom),
            textView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -right)
        ])
    }
    
    @MainActor public var placeholder: String? {
        get { return textView.placeholder }
        set { textView.placeholder = newValue ?? "" }
    }
    
    @MainActor public var text: String? {
        get { return textView.text }
        set { textView.text = newValue }
    }
    
    @MainActor public var attributeText: NSAttributedString? {
        get { return textView.attributedText }
        set { textView.attributedText = newValue }
    }
    
    @MainActor public var placeholderColor: UIColor {
        get { return textView.placeHolderColor }
        set { textView.placeHolderColor = newValue }
    }
}

