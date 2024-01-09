//
//  UIViewFunctionBuilder.swift
//  Pods
//
//  Created by 朱继超 on 2021/4/13.
//

import UIKit

@resultBuilder
public struct UIViewFunctionBuilder {
    public static func buildBlock(_ views: UIView...) -> [UIView] {
        var subviews = [UIView]()
        for view in views {
            subviews.append(view)
        }
        return subviews
    }
}

extension UIView {
    
    public convenience init(@UIViewFunctionBuilder _ builder: () -> [UIView]) {
        self.init()
        let views = builder()
        if let view = views.first {
            if view.frame != .zero {
                self.frame = view.frame
            } else {
                assert(false, "views stack top must has frame")
            }
        }
        self.addSubViews(views)
    }
    
}

