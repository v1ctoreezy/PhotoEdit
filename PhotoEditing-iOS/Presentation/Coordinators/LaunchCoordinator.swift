//
//  LaunchCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

typealias LaunchCompletionBlock = (LaunchInstructor?) -> Void

protocol LaunchCoordinatorDelegate: AnyObject {
    var finishFlow: LaunchCompletionBlock? { get set }
}

struct LaunchFlowResult {

}

final class LaunchCoordinator: BaseCoordinator, LaunchCoordinatorDelegate {

    var finishFlow: LaunchCompletionBlock?
    
    private var isLoggedIn: Bool = true

    private var launchResult: LaunchFlowResult?

    fileprivate let appRouter: Routable
    private let screensFactory: ScreensFactory

    init(appRouter: Routable, screensFactory: ScreensFactory) {
        self.appRouter = appRouter
        self.screensFactory = screensFactory
    }
}

// MARK:- Coordinatable
extension LaunchCoordinator: Coordinatable {
    func start() {
        performFlow()
    }

    func startWithAction(_ action: LaunchNavigationScreen?) {
        switch action {
        case .launch:
            start()
        default:
            start()
        }
    }
}

// MARK:- Private methods
private extension LaunchCoordinator {
    
    func performFlow() {
        showLaunchScreen()
    }
    
    func downloadComplete(_ res: LaunchFlowResult) {
        self.launchResult = res
    }
    
    func showLaunchScreen() {
        let screen = screensFactory
            .makeLaunchScreen(
                actions:
                    LaunchActions(showNextScreen: { [weak self] in
                        self?.downloadComplete()
                    })
            )
        
        screen.modalPresentationStyle = .overFullScreen
        screen.modalTransitionStyle = .flipHorizontal
        
        appRouter.setRootModule(screen, hideBar: true)
    }
    
    func downloadComplete() {
        showNextScreen()
    }
    
    func showNextScreen() {
        
        if isLoggedIn {
            performTabFlow(action: .catalog)
        } else {
            
        }
    }
    
    func showLogin() {
        
    }
    
    func performTabFlow(action: MainNavigationScreen? = nil) {
        self.finishFlow?(.main(.catalog))
    }
}
