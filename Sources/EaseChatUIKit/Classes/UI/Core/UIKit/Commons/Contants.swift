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

/// The top inset reserved for the status bar and the window's safe area.
public var StatusBarHeight: CGFloat {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = scenes.first(where: { $0.windows.contains(where: { $0.isKeyWindow }) })
        ?? scenes.first(where: { $0.activationState == .foregroundActive })
        ?? scenes.first(where: { $0.activationState == .foregroundInactive })
        ?? scenes.first
    guard let scene = scene else {
        // Preserve the inset for apps using the AppDelegate window lifecycle.
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            ?? UIApplication.shared.windows.first(where: { $0.windowLevel == .normal })
        return max(window?.safeAreaInsets.top ?? 0,
                   UIApplication.shared.statusBarFrame.height)
    }
    let window = scene.windows.first(where: { $0.isKeyWindow })
        ?? scene.windows.first(where: { $0.windowLevel == .normal })
    // The root safe area can exceed statusBarFrame on devices with a sensor housing.
    // The scene's manager also works during connection, before a key window exists.
    return max(window?.safeAreaInsets.top ?? 0,
               scene.statusBarManager?.statusBarFrame.height ?? 0)
}

/// The height of the navigation bar, which includes the status bar.
public var NavigationHeight: CGFloat { StatusBarHeight + 44 }

/// A wrapper for a project-specific type.
public struct ChatWrapper<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}






