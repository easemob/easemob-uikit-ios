//
//  UIColorExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation
import UIKit
//MARK: - UIColor extension
public extension UIColor {
    
    /// 生成随机色
    static var randomColor: UIColor {
        let r = CGFloat.random(in: 0...1)
        let g = CGFloat.random(in: 0...1)
        let b = CGFloat.random(in: 0...1)
        let a = CGFloat.random(in: 0...1)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    ///  init with 0xabcd123
    /// - Parameter rgbValue: hex
    convenience init(_ rgbValue: UInt) {
        self.init(red: CGFloat((CGFloat((rgbValue & 0xff0000) >> 16)) / 255.0),
                  green: CGFloat((CGFloat((rgbValue & 0x00ff00) >> 8)) / 255.0),
                  blue: CGFloat((CGFloat(rgbValue & 0x0000ff)) / 255.0),
                  alpha: 1.0)
    }
    
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
            if hexString.count > 8,hexString.count < 6 {
                return nil
            }
        } else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1.0
        
        switch hexString.count {
        case 6: // RGB (24-bit)
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
        case 8: // RGBA (32-bit)
            r = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgbValue & 0x000000FF) / 255.0
        default:
            break
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    
}
