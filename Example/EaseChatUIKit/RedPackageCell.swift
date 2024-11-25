//
//  RedPackageCell.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 11/22/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class RedPackageCell: CustomMessageCell {

    override func createContent() -> UIView {
        UIView(frame: self.contentView.bounds).backgroundColor(.clear).tag(bubbleTag).backgroundColor(.systemRed)
    }
    
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        
    }
    
    override func updateAxis(entity: MessageEntity) {
        super.updateAxis(entity: entity)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.arrow.image = UIImage(named: self.towards == .left ? "arrow_left": "arrow_right", in: .chatBundle, with: nil)?.withTintColor(self.towards == .left ? .systemRed:.systemRed)
        } else {
            self.bubbleMultiCorners.backgroundColor = .systemRed
        }
    }
}

