//
//  ServicesCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 13.11.2024.
//

import SwiftUI

// MARK: - Protocols

protocol ServicesCoordinatorDelegate: AnyObject {
    
    var callBackFlow: ((MainNavigationScreen) -> Void)? { get set }
    var finishFlow: LaunchCompletionBlock? { get set }
}

class ServicesCoordinator: BaseCoordinator, ServicesCoordinatorDelegate {
    
    // MARK: - Properties
    
    var callBackFlow: ((MainNavigationScreen) -> Void)?
    var finishFlow: LaunchCompletionBlock?
    
    // MARK: - Fileprivate properties
    
    fileprivate let appRouter: Routable
    fileprivate let subRouter: Routable
    
    // MARK: - Private properties
    
    private let screensFactory: ScreensFactory
    
    // MARK: - Initializers

    init(appRouter: Routable, screensFactory: ScreensFactory, subNavigation: UINavigationController) {
        self.appRouter = appRouter
        self.screensFactory = screensFactory
        self.subRouter = Router(rootController: subNavigation)
    }
}

extension ServicesCoordinator: Coordinatable {
    
    func start() {
        
    }
    
}
