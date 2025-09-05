//
//  TabBarPage.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

//enum TabBarPage: Int, CaseIterable, Equatable, Hashable {
//    case news = 0
//    case services
//    case documents
//    case profile
//    
//    func currentPage() -> TabBarPage {
//        return self
//    }
//
//    func pageIcon() -> UIImage {
//        switch self {
//        case .news:
//            return UIImg.Icons.Tabbar.news
//        case .services:
//            return UIImg.Icons.Tabbar.services
//        case .documents:
//            return UIImg.Icons.Tabbar.documents
//        case .profile:
//            return UIImg.Icons.Tabbar.profile
//        }
//    }
//    
//    func pageImage() -> Image {
//        switch self {
//        case .news:
//            return Img.Icons.Tabbar.news
//        case .services:
//            return Img.Icons.Tabbar.services
//        case .documents:
//            return Img.Icons.Tabbar.documents
//        case .profile:
//            return Img.Icons.Tabbar.profile
//        }
//    }
//}

import SwiftUI
import Combine

enum TabBarPage: Int {
    case photoEdit = 0
    case catalog
    //    case editedPhoto
    //    case profile

    init?(index: Int) {
        switch index {
        case 0:
            self = .photoEdit
        case 1:
            self = .catalog
//        case 2:
//            self = .profile
//        case 3:
//            self = .chat
//        case 4:
//            self = .cart
        default:
            return nil
        }
    }

    func pageTitleValue() -> String {
        switch self {
        case .photoEdit:
            return "tabCatalogTitle"
        case .catalog:
            return "RString.searchTitle"
//        case .profile:
//            return "tabProfile"
//        case .chat:
//            return "tabMessages"
//        case .cart:
//            return "tabCart"
        }
    }

    func pageIcon() -> UIImage {
        switch self {
        case .photoEdit:
            return UIImage(systemName: "location")!
        case .catalog:
            return UIImage(systemName: "crop")!
//        case .profile:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
//        case .chat:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
//        case .cart:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
        }
    }

    func pageSelectedIcon() -> UIImage {
        switch self {
        case .photoEdit:
            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
        case .catalog:
            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
//        case .profile:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
//        case .chat:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
//        case .cart:
//            return UIImage(systemName: "square.and.arrow.up.badge.clock.fill")!
        }
    }

    func pageOrderNumber() -> Int {
        switch self {
        case .photoEdit:
            return 0
        case .catalog:
            return 1
//        case .profile:
//            return 2
//        case .chat:
//            return 3
//        case .cart:
//            return 4
        }
    }
}

class TabBarController: UITabBarController {
    
    var tabControllers: [TabBarPage: UIViewController] = [:] {
        didSet {
            generateTabBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func hideTabBar() {
//        var _frame = self.tabBarController?.tabBar.frame
//        _frame?.origin.y = self.view.frame.size.height + (_frame?.size.height)!
//        UIView.animate(withDuration: 0.5, animations: {
//            self.tabBarController?.tabBar.frame = _frame!
//        })
//    }
//
//    func showTabBar() {
//        var _frame = self.tabBarController?.tabBar.frame
//        _frame?.origin.y = self.view.frame.size.height - (_frame?.size.height)!
//        UIView.animate(withDuration: 0.5, animations: {
//            self.tabBarController?.tabBar.frame = _frame!
//        })
//    }
    
    private func generateTabBar() {
        self.viewControllers = tabControllers.sorted(by: { $1.key.rawValue < $0.key.rawValue }).map {
            let tmp = $0.value
//            tmp.tabBarItem.title = $0.key.pageTitleValue()
            tmp.tabBarItem.image = $0.key.pageIcon()
            return tmp
        }
    }
}

extension UITabBarController {

    /**
     Show or hide the tab bar.

     - Parameter hidden: `true` if the bar should be hidden.
     - Parameter animated: `true` if the action should be animated.
     - Parameter transitionCoordinator: An optional `UIViewControllerTransitionCoordinator` to perform the animation
        along side with. For example during a push on a `UINavigationController`.
     */
    func setTabBar(
        hidden: Bool,
        animated: Bool = true,
        along transitionCoordinator: UIViewControllerTransitionCoordinator? = nil
    ) {
        guard isTabBarHidden != hidden else { return }

        let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
        let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        let vc: UIViewController? = viewControllers?[selectedIndex]
        var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
        let originalInsets = newInsets
        newInsets?.bottom -= offsetY

        /// Helper method for updating child view controller's safe area insets.
        func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
            cvc?.additionalSafeAreaInsets = additionalSafeArea
            cvc?.view.setNeedsLayout()
        }

        // Update safe area insets for the current view controller before the animation takes place when hiding the bar.
        if hidden, let insets = newInsets { set(childViewController: vc, additionalSafeArea: insets) }

        guard animated else {
            tabBar.frame = endFrame
            return
        }

        // Perform animation with coordinato if one is given. Update safe area insets _after_ the animation is complete,
        // if we're showing the tab bar.
        weak var tabBarRef = self.tabBar
        if let tc = transitionCoordinator {
            tc.animateAlongsideTransition(in: self.view, animation: { _ in tabBarRef?.frame = endFrame }) { context in
                if !hidden, let insets = context.isCancelled ? originalInsets : newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: { tabBarRef?.frame = endFrame }) { didFinish in
                if !hidden, didFinish, let insets = newInsets {
                    set(childViewController: vc, additionalSafeArea: insets)
                }
            }
        }
    }

    /// `true` if the tab bar is currently hidden.
    var isTabBarHidden: Bool {
        return !tabBar.frame.intersects(view.frame)
    }

}
