//
//  MusicCell.swift
//  EaseChatUIKit_Example
//
//  Created by 朱继超 on 12/19/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import EaseChatUIKit

class MusicCell: CustomMessageCell {

    lazy var music: UILabel = {
        UILabel().textAlignment(.center).textColor(.white).font(.systemFont(ofSize: 24)).backgroundColor(.purple)
    }()
    
    required init(towards: BubbleTowards, reuseIdentifier: String) {
        super.init(towards: towards, reuseIdentifier: reuseIdentifier)
        self.bubbleWithArrow.backgroundColor = .purple
        self.bubbleWithArrow.arrow.isHidden = true
        self.bubbleMultiCorners.backgroundColor = .purple
        self.content.addSubview(self.music)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createContent() -> UIView {
        UIView(frame: self.contentView.bounds).backgroundColor(.clear).tag(bubbleTag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.music.frame = self.content.bounds
    }
    
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        if let body = entity.message.body as? ChatCustomMessageBody,body.event == musicIdentifier {
            self.music.text = body.event
        }
    }
    
    override func updateAxis(entity: MessageEntity) {
        super.updateAxis(entity: entity)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.music.frame = self.bubbleWithArrow.frame
        } else {
            self.music.frame = self.bubbleMultiCorners.frame
        }
        
    }

}
