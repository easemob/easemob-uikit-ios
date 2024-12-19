//
//  GiftCell.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 12/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class GiftCell: CustomMessageCell {
    
    lazy var gift: UILabel = {
        UILabel().textAlignment(.center).textColor(.white).font(.systemFont(ofSize: 16)).backgroundColor(.clear)
    }()
    
    required init(towards: BubbleTowards, reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.content.addSubview(self.gift)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createContent() -> UIView {
        UIView(frame: self.contentView.bounds).backgroundColor(.clear).tag(bubbleTag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gift.frame = self.content.bounds
    }
    
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        if let body = entity.message.body as? ChatCustomMessageBody,body.event == giftIdentifier {
            self.gift.text = body.event
        }
    }
    
    override func updateAxis(entity: MessageEntity) {
        super.updateAxis(entity: entity)
        
    }

}
