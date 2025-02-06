//
//  DocumentsCoordinator.swift
//  UMobile
//
//  Created by Good Shmorning on 13.11.2024.
//

import SwiftUI

// MARK: - Protocols

protocol DocumentsCoordinatorDelegate: AnyObject {
    
    var callBackFlow: ((MainNavigationScreen) -> Void)? { get set }
    var finishFlow: LaunchCompletionBlock? { get set }
}

class DocumentsCoordinator: BaseCoordinator, DocumentsCoordinatorDelegate {
    
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

extension DocumentsCoordinator: Coordinatable {
    
    func start() {
        
    }
    
}
