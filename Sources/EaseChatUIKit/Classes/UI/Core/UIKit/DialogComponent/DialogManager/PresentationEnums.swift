//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation


public enum PanDismissDirection {
    case down
    case up
    case left
    case right
}


public enum PresentationOrigin: Equatable {
    case center
    case bottomOutOfLine
    case leftOutOfLine
    case rightOutOfLine
    case topOutOfLine
    case custom(center: CGPoint)

    // MARK: -  Equatable
    public static func == (lhs: PresentationOrigin, rhs: PresentationOrigin) -> Bool {
        switch (lhs, rhs) {
        case (.center, .center):
            return true
        case (.bottomOutOfLine, .bottomOutOfLine):
            return true
        case (.leftOutOfLine, .leftOutOfLine):
            return true
        case (.rightOutOfLine, .rightOutOfLine):
            return true
        case (.topOutOfLine, .topOutOfLine):
            return true
        case let (.custom(lhsCenter), .custom(rhsCenter)):
            return lhsCenter == rhsCenter
        default:
            return false
        }
    }
}


public enum PresentationDestination: Equatable {
    case center
    case bottomBaseline
    case leftBaseline
    case rightBaseline
    case topBaseline
    case custom(center: CGPoint)

    /// pan手势方向
    var panDirection: PanDismissDirection {
        switch self {
        case .center, .bottomBaseline, .custom:
            return .down
        case .leftBaseline:
            return .left
        case .rightBaseline:
            return .right
        case .topBaseline:
            return .up
        }
    }

    /// 默认的起始位置
    var defaultOrigin: PresentationOrigin {
        switch self {
        case .center:
            return .center
        case .leftBaseline:
            return .leftOutOfLine
        case .rightBaseline:
            return .rightOutOfLine
        case .topBaseline:
            return .topOutOfLine
        default:
            return .bottomOutOfLine
        }
    }

    // MARK: -  Equatable
    public static func == (lhs: PresentationDestination, rhs: PresentationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.center, .center):
            return true
        case (.bottomBaseline, .bottomBaseline):
            return true
        case (.leftBaseline, .leftBaseline):
            return true
        case (.rightBaseline, .rightBaseline):
            return true
        case (.topBaseline, .topBaseline):
            return true
        case let (.custom(lhsCenter), .custom(rhsCenter)):
            return lhsCenter == rhsCenter
        default:
            return false
        }
    }
}


public enum TransitionType: Equatable {
    case translation(origin: PresentationOrigin)
    case crossDissolve
    case crossZoom
    case flipHorizontal
    case custom(animation: PresentationAnimation)

    var animation: PresentationAnimation {
        switch self {
        case let .translation(origin):
            return PresentationAnimation(origin: origin)
        case .crossDissolve:
            return CrossDissolveAnimation()
        case .crossZoom:
            return CrossZoomAnimation(scale: 0.1)
        case .flipHorizontal:
            return FlipHorizontalAnimation()
        case let .custom(animation):
            return animation
        }
    }

    // MARK: -  Equatable
    public static func == (lhs: TransitionType, rhs: TransitionType) -> Bool {
        switch (lhs, rhs) {
        case let (.translation(lhsOrigin), .translation(rhsOrigin)):
            return lhsOrigin == rhsOrigin
        case (.crossDissolve, .crossDissolve):
            return true
        case (.flipHorizontal, .flipHorizontal):
            return true
        case (.crossZoom, .crossZoom):
            return true
        case let (.custom(lhsAnimation), .custom(rhsAnimation)):
            return lhsAnimation == rhsAnimation
        default:
            return false
        }
    }
}


public enum AnimationOptions {
    case normal(duration: TimeInterval)
    case spring(duration: TimeInterval, delay: TimeInterval, damping: CGFloat, velocity: CGFloat)

    var duration: TimeInterval {
        switch self {
        case let .normal(duration):
            return duration
        case let .spring(duration, _, _, _):
            return duration
        }
    }
}

/// Keyboard appearance type
///
/// - unabgeschirmt: discover PresentedView，compress: keyboard nearly present view
/// - compressInputView: Nearly system keyboard
public enum KeyboardTranslationType:Equatable {
    case unabgeschirmt(compress: Bool)
    case compressInputView
    case noTreatment
}
