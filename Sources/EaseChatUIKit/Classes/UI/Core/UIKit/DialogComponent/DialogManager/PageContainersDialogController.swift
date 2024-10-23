//
//  DialogViewController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/6.
//

import UIKit
/**
     A controller that manages a page container which displays a collection of child view controllers in a paged interface.
     
     The `presentedViewComponent` property is used to set the size of the page container. The `pageTitles` property is used to set the titles of the pages in the container. The `childControllers` property is used to set the child view controllers to be displayed in the container.
     
     The `container` property is a lazy var that returns a `PageContainer` instance with the specified frame, view controllers, and page titles. It also sets the corner radius of the container view.
*/
@objc public class PageContainersDialogController: UIViewController, PresentedViewType {
    
    
    public var presentedViewComponent: PresentedViewComponent? = PresentedViewComponent(contentSize: Appearance.pageContainerConstraintsSize,canPanDismiss: false,keyboardTranslationType: .compressInputView)
    
    private var pageTitles = [String]()
    
    private var childControllers = [UIViewController]()
    
    public var willRemoveClosure: (() -> ())?

    lazy var container: PageContainer = {
        PageContainer(frame: CGRect(x: 0, y: 0, width: self.presentedViewComponent?.contentSize.width ?? 0, height: self.presentedViewComponent?.contentSize.height ?? 0), viewControllers: self.childControllers, indicators: self.pageTitles).cornerRadius(.medium, [.topLeft,.topRight], .clear, 0).backgroundColor(UIColor.theme.neutralColor98)
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     Initializes a PageContainersDialogController with the given page titles, child view controllers, and optional constraints size.

     - Parameters:
         - pageTitles: An array of strings representing the titles of each page.
         - childControllers: An array of UIViewControllers representing the child view controllers for each page.
         - constraintsSize: An optional CGSize representing the size of the constraints for the presented view component.

     - Returns: A PageContainersDialogController instance.
     */
    @objc public required init(pageTitles:[String],childControllers: [UIViewController],constraintsSize: CGSize = .zero) {
        if pageTitles.count != childControllers.count {
            assert(false,"Titles count isn't equal child controllers count.")
        }
        if constraintsSize != .zero {
            self.presentedViewComponent?.contentSize = constraintsSize
        }
        self.pageTitles = pageTitles
        self.childControllers = childControllers
        super.init(nibName: nil, bundle: nil)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor(.clear)
        self.view.addSubview(self.container)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.willRemoveClosure?()
    }
}


extension PageContainersDialogController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.container.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
