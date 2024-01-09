//
//  ImageLoader.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import Foundation

import UIKit
import Combine

/**
 private var cancellables = Set<AnyCancellable>()
 let imageURL = URL(string: "https://example.com/image.jpg")!
 
 ImageLoader.shared.loadImage(from: imageURL)
     .sink(receiveValue: { [weak self] image in
         self?.imageView.image = image
     })
     .store(in: &cancellables)
 */

/// An Image loader
struct ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCacheManager.shared
    
    /// Load image from url.
    /// - Parameter url: image url
    /// - Returns: An
    /// - How to user? See above the ImageLoader.
    func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let cachedImage = cache.image(for: url.absoluteString) {
            return Just(cachedImage).eraseToAnyPublisher()
        } else {
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({ UIImage(data: $0.data) ?? UIImage() })
                .map({ image in
                    self.cache.cacheImage(image, for: url.absoluteString)
                    return image
                })
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
