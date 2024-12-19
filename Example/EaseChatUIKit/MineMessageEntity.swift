//
//  MineMessageEntity.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 11/22/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

final class MineMessageEntity: MessageEntity {
    
    override func customSize() -> CGSize {
        if let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case EaseChatUIKit_user_card_message:
                return CGSize(width: self.historyMessage ? ScreenWidth-32:limitBubbleWidth, height: contactCardHeight)
            case EaseChatUIKit_alert_message:
                let label = UILabel().numberOfLines(0).lineBreakMode(.byWordWrapping)
                label.attributedText = self.convertTextAttribute()
                let size = label.sizeThatFits(CGSize(width: ScreenWidth-32, height: 9999))
                return CGSize(width: ScreenWidth-32, height: size.height+50)
            case redPackageIdentifier:
                return CGSize(width: limitBubbleWidth, height: limitBubbleWidth*(5/3.0))
            case giftIdentifier:
                return CGSize(width: limitBubbleWidth, height: 70)
            case musicIdentifier:
                return CGSize(width: limitBubbleWidth, height: 80)
            default:
                return .zero
            }
            
        } else {
            return .zero
        }
    }

    
}

