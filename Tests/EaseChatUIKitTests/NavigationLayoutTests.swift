import EaseChatUIKit
import ObjectiveC
import UIKit
import XCTest

final class NavigationLayoutTests: XCTestCase {
    @MainActor
    func testLegacyKeyWindowSafeAreaIsPreferredAndReadAgain() throws {
        let normalWindow = NavigationMetricsWindow(topInset: 140)
        let keyWindow = NavigationMetricsWindow(topInset: 62, isKey: true)
        try withLegacyApplication(windows: [normalWindow, keyWindow], statusBarHeight: 54) {
            XCTAssertEqual(StatusBarHeight, 62)
            XCTAssertEqual(NavigationHeight, 106)
            keyWindow.topInset = 80
            XCTAssertEqual(StatusBarHeight, 80)
            XCTAssertEqual(NavigationHeight, 124)
        }
    }

    @MainActor
    func testLegacyNormalWindowIsUsedWithoutAKeyWindow() throws {
        let overlay = NavigationMetricsWindow(topInset: 140)
        overlay.windowLevel = .alert
        let normalWindow = NavigationMetricsWindow(topInset: 62)
        try withLegacyApplication(windows: [overlay, normalWindow], statusBarHeight: 54) {
            XCTAssertEqual(StatusBarHeight, 62)
            XCTAssertEqual(NavigationHeight, 106)
        }
    }

    @MainActor
    func testLegacyStatusBarHeightIsPreservedWhenLargerThanSafeArea() throws {
        let window = NavigationMetricsWindow(topInset: 20, isKey: true)
        try withLegacyApplication(windows: [window], statusBarHeight: 54) {
            XCTAssertEqual(StatusBarHeight, 54)
            XCTAssertEqual(NavigationHeight, 98)
        }
    }

    @MainActor
    func testLegacyStatusBarHeightIsUsedBeforeAWindowExists() throws {
        for height: CGFloat in [54, 0] {
            try withLegacyApplication(windows: [], statusBarHeight: height) {
                XCTAssertEqual(StatusBarHeight, height)
                XCTAssertEqual(NavigationHeight, height + 44)
            }
        }
    }

    @MainActor
    func testTextHeaderControlsStayInsideTheirOwnContentArea() {
        for height: CGFloat in [44, 64, 88, 103] {
            let bar = ChatNavigationBar(
                show: CGRect(x: 0, y: 0, width: ScreenWidth, height: height),
                textAlignment: .left,
                rightTitle: "Done"
            )
            bar.subtitle = "Detail"
            bar.title = "Title"
            let topInset = max(0, height - 44)
            for view in [bar.leftItem, bar.titleLabel, bar.detail, bar.rightItem] {
                XCTAssertGreaterThanOrEqual(view.frame.minY, topInset)
                XCTAssertLessThanOrEqual(view.frame.maxY, height)
            }
        }
    }

    // Modern iOS can create a scene even for an AppDelegate-only test host.
    // Override only these getters for a synchronous main-thread test, then restore them.
    @MainActor
    private func withLegacyApplication(
        windows: [UIWindow], statusBarHeight: CGFloat, body: () throws -> Void
    ) throws {
        let selectors: [(Selector, Selector)] = [
            (#selector(getter: UIApplication.connectedScenes), #selector(UIApplication.navigationTestScenes)),
            (#selector(getter: UIApplication.windows), #selector(UIApplication.navigationTestWindows)),
            (#selector(getter: UIApplication.statusBarFrame), #selector(UIApplication.navigationTestStatusBarFrame))
        ]
        let methods = try selectors.map { original, replacement in
            (
                try XCTUnwrap(class_getInstanceMethod(UIApplication.self, original)),
                try XCTUnwrap(class_getInstanceMethod(UIApplication.self, replacement))
            )
        }
        navigationWindowsFixture = windows
        navigationTestStatusBarHeight = statusBarHeight
        for (original, replacement) in methods {
            method_exchangeImplementations(original, replacement)
        }
        defer {
            for (original, replacement) in methods.reversed() {
                method_exchangeImplementations(original, replacement)
            }
            navigationWindowsFixture = []
            navigationTestStatusBarHeight = 0
        }
        XCTAssertTrue(UIApplication.shared.connectedScenes.isEmpty)
        try body()
    }
}

private final class NavigationMetricsWindow: UIWindow {
    var topInset: CGFloat
    private let isKey: Bool

    init(topInset: CGFloat, isKey: Bool = false) {
        self.topInset = topInset
        self.isKey = isKey
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isKeyWindow: Bool { isKey }
    override var safeAreaInsets: UIEdgeInsets {
        UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }
}

private var navigationWindowsFixture: [UIWindow] = []
private var navigationTestStatusBarHeight: CGFloat = 0

private extension UIApplication {
    @objc func navigationTestScenes() -> Set<UIScene> { [] }
    @objc func navigationTestWindows() -> [UIWindow] { navigationWindowsFixture }
    @objc func navigationTestStatusBarFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: 390, height: navigationTestStatusBarHeight)
    }
}
