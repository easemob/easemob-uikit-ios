//
//  BundleExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation

private enum ChatResources {
    static let bundle: Bundle = {
#if SWIFT_PACKAGE
        // SwiftPM copies the existing resource bundle inside its generated bundle.
        let containers = [Bundle.module]
#elseif COCOAPODS || STATIC_LIBRARY
        // CocoaPods can copy resources alongside the framework or into the app.
        let containers = [Bundle(for: Theme.self), Bundle.main]
#else
        return Bundle(for: Theme.self)
#endif
#if SWIFT_PACKAGE || COCOAPODS || STATIC_LIBRARY
        for container in containers {
            if let url = container.url(forResource: "EaseChatResource", withExtension: "bundle"),
               let bundle = Bundle(url: url) {
                return bundle
            }
        }
        preconditionFailure("EaseChatUIKit: EaseChatResource.bundle is missing. Check the package resource copy step.")
#endif
    }()
}

public extension Bundle {
    /// The custom resource bundle, or the bundled EaseChatUIKit images and strings.
    /// Set `Appearance.resourceBundle` before creating views that cache images.
    class var chatBundle: Bundle {
        Appearance.resourceBundle ?? ChatResources.bundle
    }
}
