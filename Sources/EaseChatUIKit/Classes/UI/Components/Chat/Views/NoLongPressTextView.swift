//
//  NoLongPressTextView.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2024/7/10.
//

import UIKit


@objc open class NoLongPressTextView: UITextView {

    open override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let className = gestureRecognizer.swiftClassName?.lowercased(),className.contains("press") {
            gestureRecognizer.isEnabled = false
        } else {
            super.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    open override var inputAssistantItem: UITextInputAssistantItem {
        let item = super.inputAssistantItem
        item.leadingBarButtonGroups = []
        item.trailingBarButtonGroups = []
        return item
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
//    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        // 获取点击位置的文本位置索引
//        if let position = closestPosition(to: point) {
//            // 检查点击位置是否在文本区域内
//            let textRange = tokenizer.rangeEnclosingPosition(position, with: .character, inDirection: UITextDirection(rawValue: UITextLayoutDirection.right.rawValue))
//            
//            // 如果没有文本，返回 nil 禁止响应
//            if textRange == nil {
//                return nil
//            }
//        }
//        
//        return super.hitTest(point, with: event)
//    }
}



