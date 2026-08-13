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
  public var BottomBarHeight: CGFloat {
      guard let scene = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first(where: { $0.activationState == .foregroundActive })
          ?? UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene }).first
      else { return 49 }
   
      let window: UIWindow?
      if #available(iOS 15.0, *) {
          window = scene.keyWindow ?? scene.windows.first
      } else {
          window = scene.windows.first(where: \.isKeyWindow) ?? scene.windows.first
      }
      // 注意:安全区底部在无 Home Indicator 机型上合法为 0,不可用 >0 判定有效性
      return window?.safeAreaInsets.bottom ?? 49
  }

/// The height of the status bar.
public var StatusBarHeight: CGFloat {
      UIApplication.shared.connectedScenes
          .compactMap { $0 as? UIWindowScene }
          .first?.statusBarManager?.statusBarFrame.height ?? 0
}

/// The height of the navigation bar, which includes the status bar.
public var NavigationHeight :CGFloat {
    StatusBarHeight + 44
}

/// A wrapper for a project-specific type.
public struct ChatWrapper<Base> {
    var base: Base
    init(_ base: Base) {
        self.base = base
    }
}






