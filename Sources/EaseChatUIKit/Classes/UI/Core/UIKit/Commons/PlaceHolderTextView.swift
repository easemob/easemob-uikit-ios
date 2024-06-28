//
//  PlaceHolderTextView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2020/12/16.
//

import Foundation
import UIKit

/**
 A subclass of UITextView that provides a placeholder text when the text view is empty.
 */
@objcMembers public class PlaceHolderTextView: UITextView {
    
    private var placeholderLabel: UILabel
    
    @MainActor public var placeHolderColor: UIColor = UIColor.gray {
        didSet {
            self.placeholderLabel.textColor = self.placeHolderColor
        }
    }
    
    @MainActor public var placeholder: String? {
        didSet {
            self.placeholderLabel.text = self.placeholder
        }
    }
        
    @MainActor public override var text: String! {
        didSet {
            self.textDidChange()
        }
    }
    
    @MainActor override public var attributedText: NSAttributedString!{
        didSet{
            self.placeholderLabel.attributedText = attributedText
        }
    }
    

    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        self.placeholderLabel = UILabel()
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.placeholderLabel = UILabel()
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
           placeholderLabel.textColor = .lightGray
           placeholderLabel.numberOfLines = 0
           placeholderLabel.font = self.font
           placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
           addSubview(placeholderLabel)
           
           // 设置 textContainerInset 以确保光标和文本位置正确
           self.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
           self.textContainer.lineFragmentPadding = 0
           
           // 监听文本变化通知
           NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
           
           // 设置约束
           NSLayoutConstraint.activate([
               placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: textContainerInset.top),
               placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: textContainerInset.left + self.textContainer.lineFragmentPadding),
               placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(textContainerInset.right + self.textContainer.lineFragmentPadding)),
               placeholderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -textContainerInset.bottom)
           ])
           
           textDidChange()
       }
       
       
    public override func layoutSubviews() {
           super.layoutSubviews()
           // 更新 placeholderLabel 的 frame
           let padding = textContainer.lineFragmentPadding
           let insets = textContainerInset
           placeholderLabel.frame = CGRect(
               x: padding + insets.left,
               y: insets.top,
               width: frame.width - padding * 2 - insets.left - insets.right,
               height: placeholderLabel.sizeThatFits(CGSize(width: frame.width - padding * 2 - insets.left - insets.right, height: CGFloat.greatestFiniteMagnitude)).height
           )
       }
    
    @objc private func textDidChange() {
        self.placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

