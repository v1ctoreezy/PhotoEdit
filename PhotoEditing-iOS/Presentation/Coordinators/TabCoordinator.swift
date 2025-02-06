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
    let pages: [TabBarPage] = [.news, .services, .documents, .profile]

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
        navigate(options)
    }

    func navigate(_ options: MainNavigationScreen? = nil) {
        guard let options = options else { return }
        switch options {
        case .news:
//            tabBarController.setSelectedPage(TabBarPage.news)
            return
        case .services:
//            tabBarController.setSelectedPage(TabBarPage.services)
            return
        case .documents:
//            tabBarController.setSelectedPage(TabBarPage.documents)
            return
        case .profile:
//            tabBarController.setSelectedPage(TabBarPage.profile)
            return
        }
    }

    private func showTabScreen(){
        removeAll()
        let controllers = pages.reduce(into: [TabBarPage: UIViewController]()) {
            $0[$1] = getTabController($1)
        }
        let vc = screensFactory.makeTabScreen(
                withPages: pages,
                withTabControllers: controllers,
                TabActions(tabNews: {  }, tabServices: {  }, tabDocuments: {  }, tabProfile: {  },
                           pushVC: { [weak self] image, pass in
                               let vc = ImageEditingViewController(image: image,
                                                                   passCroppedView: { image in
                                   pass(image)
                                   self?.appRouter.dismiss()
                               }, cropRatio: 1)
//                               let vc = UIHostingController(rootView: CroppingView())
                               vc.modalPresentationStyle = .fullScreen
                               
                               self?.appRouter.present(vc, animated: true)
                           }

                )
        )
        
        appRouter.setRootModule(vc)
    }
    
    private func getTabController(_ page: TabBarPage) -> UINavigationController? {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)

        switch page {
        case .news:
            let coordinator = NewsCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
            coordinator.finishFlow = { action in
                if let action = action, case .main(let value) = action {
                    self.startWithAction(value)
                }
            }
            coordinator.callBackFlow = { [weak self] action in self?.navigate(action) }
            addDependency(coordinator)
            coordinator.start()
            break
        case .services:
            let coordinator = ServicesCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
            addDependency(coordinator)
            coordinator.start()
            break
        case .profile:
            let coordinator = ProfileCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
            addDependency(coordinator)
            coordinator.start()
            break
        case .documents:
            let coordinator = DocumentsCoordinator(appRouter: appRouter, screensFactory: screensFactory, subNavigation: navController)
            addDependency(coordinator)
            coordinator.start()
            break
        }
        return navController
    }
}
