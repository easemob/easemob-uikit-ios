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

import ImageIO
import UniformTypeIdentifiers

extension UIImage {

    func writeImage(
        to url: URL,
        metadata: [String: Any]? = nil,
        compression: CGFloat = 0.95,
        typeIdentifier: String = UTType.jpeg.identifier
    ) throws {

        guard let cgImage = self.cgImage else {
            throw NSError(domain: "image", code: -1)
        }

        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            typeIdentifier as CFString,
            1,
            nil
        ) else {
            throw NSError(domain: "image", code: -2)
        }

        var properties = metadata ?? [:]
        properties[kCGImageDestinationLossyCompressionQuality as String] = compression

        CGImageDestinationAddImage(
            destination,
            cgImage,
            properties as CFDictionary
        )

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "image", code: -3)
        }
    }

    static func preferredCameraImageRepresentation() -> (typeIdentifier: String, fileExtension: String) {
        if self.canWriteImage(typeIdentifier: UTType.heic.identifier) {
            return (UTType.heic.identifier, "heic")
        }
        if self.canWriteImage(typeIdentifier: UTType.heif.identifier) {
            return (UTType.heif.identifier, "heif")
        }
        return (UTType.jpeg.identifier, "jpeg")
    }

    private static func canWriteImage(typeIdentifier: String) -> Bool {
        let identifiers = CGImageDestinationCopyTypeIdentifiers() as NSArray
        return identifiers.contains(typeIdentifier)
    }
}

extension UIImage {
    /// 自定义初始化方法：优先加载主工程图片，如果没有则加载 SDK 图片
    ///
    /// - Parameter chatNamed: 图片名称
    @objc convenience init?(chatNamed name: String) {
        // 1. 先尝试判断主工程 (Main Bundle) 是否有这张图
        // 注意：UIImage(chatNamed: ) 本身就有缓存机制，所以这里检查一下性能开销很小
        if UIImage(named: name) != nil {
            // 2. 如果主工程有，直接用主工程的初始化 (默认就是 Main Bundle)
            self.init(named: name)
        } else {
            // 3. 如果主工程没有，指定去 .chatBundle 加载
            self.init(named: name, in: .chatBundle, with: nil)
        }
    }
}
