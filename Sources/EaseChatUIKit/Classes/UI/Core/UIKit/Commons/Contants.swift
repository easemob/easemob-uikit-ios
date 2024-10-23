//
//  Contants.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/16.
//

import UIKit

/// The width of the screen in points.
public let ScreenWidth = UIScreen.main.bounds.width

/// The height of the screen in points.
public let ScreenHeight = UIScreen.main.bounds.height

/// The edge insets with all values set to zero.
public let edgeZero: UIEdgeInsets = .zero

/// The height of the bottom safe area of the screen.
public let BottomBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

/// The height of the status bar.
public let StatusBarHeight :CGFloat = UIApplication.shared.statusBarFrame.height

/// The height of the navigation bar, which includes the status bar.
public let NavigationHeight :CGFloat = StatusBarHeight + 44

/// A wrapper for a project-specific type.
public struct ChatWrapper<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}






