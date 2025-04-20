//
//  AppFlowCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 06.02.2025.
//

import Foundation
import UIKit

enum LaunchInstructor {
    case launch(_ action: LaunchNavigationScreen? = nil)
    case main(_ action: MainNavigationScreen?)
}
enum LaunchNavigationScreen {
    case launch
}

enum MainNavigationScreen {
    case photoEdit, catalog, editedPhoto, profile
}

final class AppFlowCoordinator: BaseCoordinator {
    
    private let router: Routable
    private let screensFactory: ScreensFactory
    
    init(
        rootController: RootNavigationController,
        dependencyProvider: DependencyProvider
    ) {
        self.router = Router(rootController: rootController)
        screensFactory = ScreensFactory(dependencyProvider: dependencyProvider)
        super.init()
    }
}

extension AppFlowCoordinator: Coordinatable {

    func start() {
        performLaunchFlow()
    }

    func startWithAction(_ launchOptions: LaunchInstructor?){
        switch launchOptions {
        case .main(let options):
            performTabFlow(options)
        case .launch(let options):
            performLaunchFlow(options)
        default:
            performLaunchFlow()
        }
    }
    
    func receiveDeepLink(_ url: URL) {
       
    }
}

private extension AppFlowCoordinator {
    
    func performTabFlow(_ action: MainNavigationScreen? = nil) {
        
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: true)
        navController.modalPresentationStyle = .overFullScreen
        
        let coordinator = TabCoordinator(appRouter: router, screensFactory: screensFactory)
        coordinator.finishFlow = { [unowned self, unowned coordinator] options in
            self.removeDependency(coordinator)
            self.startWithAction(options)
        }
        
        addDependency(coordinator)
        coordinator.startWithAction(action)
    }

    func performLaunchFlow(_ action: LaunchNavigationScreen? = nil) {
        let coordinator = LaunchCoordinator(appRouter: router, screensFactory: screensFactory)
        
        coordinator.finishFlow = { [unowned self, unowned coordinator] options in
            self.removeDependency(coordinator)
            self.startWithAction(options)
        }
        
        addDependency(coordinator)
        coordinator.startWithAction(action)
    }
}
