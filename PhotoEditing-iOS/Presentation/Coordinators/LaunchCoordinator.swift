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

    }
}

// MARK:- Private methods
private extension LaunchCoordinator {

    func performFlow() {
    }

    func downloadComplete(_ res: LaunchFlowResult) {
        self.launchResult = res
    }
}


