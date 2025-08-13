//
//  TabCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import Foundation
import SwiftUI

protocol TabCoordinatorDelegate: AnyObject {
    var finishFlow: LaunchCompletionBlock? { get set }
}

class TabCoordinator: BaseCoordinator, TabCoordinatorDelegate {
    
    var finishFlow: LaunchCompletionBlock?
    let pages: [TabBarPage] = [.photoEdit, .catalog] // .search, .profile, .chat, .cart]
    
    private var tabBarController: TabBarController!
    
    fileprivate let appRouter: Routable
    private let screensFactory: ScreensFactory
    
    init(appRouter: Routable, screensFactory: ScreensFactory) {
        self.appRouter = appRouter
        self.screensFactory = screensFactory
    }
    
    deinit {
        print("TabCoordinator deinit")
    }
}

extension TabCoordinator: Coordinatable {
    
    func start() {
        showTabScreen()
    }
    
    func startWithAction(_ options: MainNavigationScreen? = nil) {
        showTabScreen()
    }
    
    private func showTabScreen(){
        removeAll()
        
        let controllers = pages.reduce(into: [TabBarPage: UIViewController]()) {
            $0[$1] = getTabController($1)
        }
        
        tabBarController = screensFactory.makeTabScreen(
            withPages: pages,
            withTabControllers: controllers
        )
        
        appRouter.setRootModule(tabBarController)
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController? {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)
        
        switch page {
        case .photoEdit:
//            let coordinator = NewsCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
//            coordinator.finishFlow = { action in
//                if let action = action, case .main(let value) = action {
//                    self.startWithAction(value)
//                }
//            }
//            coordinator.callBackFlow = { [weak self] action in }
//            addDependency(coordinator)
//            coordinator.start()
            break
            
        case .catalog:
            let coordinator = PhotoSelectionCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
            coordinator.finishFlow = { action in
                if let action = action, case .main(let value) = action {
                    self.startWithAction(value)
                }
            }
            
            coordinator.togleTabBar = { [weak self] in self?.tabBarController.setTabBar(hidden: !(self?.tabBarController.isTabBarHidden ?? true), animated: true) }
            
            coordinator.callBackFlow = { [weak self] action in }
            addDependency(coordinator)
            coordinator.start()
            break
        }
        
        return navController
    }
}
