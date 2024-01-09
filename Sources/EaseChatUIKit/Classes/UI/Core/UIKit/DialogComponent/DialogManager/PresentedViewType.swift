//
//  VoiceRoomAlertViewController.swift
//  VoiceRoomBaseUIKit
//
//  Created by 朱继超 on 2022/8/30.
//

import Foundation

/// presentedView setting
public struct PresentedViewComponent {
    /// presentedView的size
    public var contentSize: CGSize

    /// presentedView destination point.
    public var destination: PresentationDestination = .bottomBaseline

    /// present transition animation type.
    public var presentTransitionType: TransitionType?

    /// dismiss transition animation type.
    public var dismissTransitionType: TransitionType?

    /// Whether tap background dismiss self or not.
    public var canTapBGDismiss: Bool = true

    /// Whether pan gesture dismiss self or not.
    public var canPanDismiss: Bool = true

    /// Pan gesture direction
    public var panDismissDirection: PanDismissDirection?

    /// ``KeyboardTranslationType``
    public var keyboardTranslationType: KeyboardTranslationType = .unabgeschirmt(compress: true)

    /// Keyboard padding
    public var keyboardPadding: CGFloat = 0

    /// Init method
    ///
    /// - Parameters:
    ///   - contentSize: presentedView的size
    ///   - destination: presentedView destination
    ///   - presentTransitionType: present transition type.
    ///   - dismissTransitionType: dismiss transition type.
    ///   - canTapBGDismiss:  ``true`` or ``false``
    ///   - canPanDismiss: ``true`` or ``false``
    ///   - panDismissDirection: pan getsture dismiss direction
    ///   - keyboardTranslationType: keyboardTranslationType
    ///   - keyboardPadding: `default` is 0.
    public init(contentSize: CGSize,
                destination: PresentationDestination = .bottomBaseline,
                presentTransitionType: TransitionType? = nil,
                dismissTransitionType: TransitionType? = nil,
                canTapBGDismiss: Bool = true,
                canPanDismiss: Bool = true,
                panDismissDirection: PanDismissDirection? = nil,
                keyboardTranslationType: KeyboardTranslationType = .unabgeschirmt(compress: true),
                keyboardPadding: CGFloat = 0)
    {
        self.contentSize = contentSize
        self.destination = destination
        self.presentTransitionType = presentTransitionType
        self.dismissTransitionType = dismissTransitionType
        self.canTapBGDismiss = canTapBGDismiss
        self.canPanDismiss = canPanDismiss
        self.panDismissDirection = panDismissDirection
        self.keyboardTranslationType = keyboardTranslationType
        self.keyboardPadding = keyboardPadding
    }
}

public protocol PresentedViewType {
    var presentedViewComponent: PresentedViewComponent? { get set }
}

extension PresentedViewType {
    var presentTransitionType: TransitionType {
        return presentedViewComponent!.presentTransitionType ?? .translation(origin: presentedViewComponent!.destination.defaultOrigin)
    }

    var dismissTransitionType: TransitionType {
        return presentedViewComponent!.dismissTransitionType ?? presentTransitionType
    }
}
