//
//  PageContainer.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit
/**
     A container view controller that manages a UIPageViewController and a PageContainerTitleBar.
     
     The PageContainerTitleBar displays a list of choices that correspond to the view controllers managed by the UIPageViewController.
     The UIPageViewController displays the view controllers that correspond to the selected choice in the PageContainerTitleBar.
     */
public final class PageContainer:  UIView {
    
    
    private var controllers: [UIViewController]?

    private var nextViewController: UIViewController?
    
    private var indicators: [String] = []

    var index = 0 {
        didSet {
            DispatchQueue.main.async {
                if let vc = self.controllers?[self.index] {
                    self.pageController.setViewControllers([vc], direction: .forward, animated: false)
                }
            }
        }
    }
    
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: self.frame.width/2.0-18, y: 6, width: 36, height: 5)).cornerRadius(2.5).backgroundColor(UIColor.theme.neutralColor8)
    }()
    
    private lazy var toolBar: PageContainerTitleBar = {
        PageContainerTitleBar(frame: CGRect(x: 0, y: self.indicator.frame.maxY + 4, width: self.frame.width, height: 44), choices: self.indicators) { [weak self] in
            self?.index = $0
        }
    }()

    private lazy var pageController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        page.view.backgroundColor = .clear
        page.dataSource = self
        page.delegate = self
        page.view.isUserInteractionEnabled = true
        
        return page
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /**
     A convenience initializer for creating a `PageContainer` with a given frame, view controllers, and indicators.
     
     - Parameters:
        - frame: The frame for the `PageContainer`.
        - viewControllers: An array of `UIViewController`s to be displayed in the `PageContainer`.
        - indicators: An array of strings representing the indicators for the `PageContainer`.
     
     - Returns: A new `PageContainer` instance.
     */
    @objc public init(frame: CGRect, viewControllers: [UIViewController],indicators: [String]) {
        super.init(frame: frame)
        self.indicators = indicators
        self.controllers = viewControllers
        self.pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: false)
        self.addSubViews([self.indicator,self.toolBar,self.pageController.view])
        
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        self.toolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.toolBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.toolBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.toolBar.topAnchor.constraint(equalTo: self.indicator.bottomAnchor,constant: 5).isActive = true
        
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.pageController.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.pageController.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.pageController.view.topAnchor.constraint(equalTo: topAnchor,constant: self.toolBar.frame.maxY).isActive = true
        
        self.toolBar.backgroundColor(UIColor.theme.neutralColor98)
        self.backgroundColor(UIColor.theme.neutralColor98)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PageContainer:UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.controllers?[safe:self.index - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.controllers?[safe:self.index + 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished,completed, self.controllers?.count ?? 0 > 0 {
            for (idx, vc) in self.controllers!.enumerated() {
                if vc == self.nextViewController {
                    self.index = idx
                    break
                }
            }
            self.toolBar.scrollIndicator(to: self.index)
        } else {
            self.nextViewController = previousViewControllers.first
        }
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.nextViewController = pendingViewControllers.first
    }
}

extension PageContainer: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.indicator.backgroundColor(style == .dark ? UIColor.theme.neutralColor3:UIColor.theme.neutralColor8)
        self.toolBar.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
