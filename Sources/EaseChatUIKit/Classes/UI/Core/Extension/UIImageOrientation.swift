//
//  UIImageOrientation.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/25.
//

import UIKit


extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
            
        default: break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default: break
        }
        
        if let cgImage = self.cgImage {
            let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgImage.bitmapInfo.rawValue)
            
            if let unwrappedContext = context {
                unwrappedContext.concatenate(transform)
                
                if self.imageOrientation == .left || self.imageOrientation == .leftMirrored || self.imageOrientation == .right || self.imageOrientation == .rightMirrored {
                    unwrappedContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
                } else {
                    unwrappedContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
                }
                
                if let newCGImage = unwrappedContext.makeImage() {
                    return UIImage(cgImage: newCGImage)
                }
            }
        }
        
        return self
    }
}
