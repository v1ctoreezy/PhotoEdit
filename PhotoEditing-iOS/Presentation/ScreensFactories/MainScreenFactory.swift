//
//  MainScreenFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import UIKit

protocol MainScreenFactory {
    
    func makeTabScreen(withPages pages: [TabBarPage],  withTabControllers tabControllers: [TabBarPage: UIViewController],_ actions: TabActions) -> UIViewController
}

extension ScreensFactory: MainScreenFactory {
    
    func makeTabScreen(withPages pages: [TabBarPage],  withTabControllers tabControllers: [TabBarPage: UIViewController],_ actions: TabActions) -> UIViewController {
        let contentView = dependencyProvider.assembler.resolver.resolve(TabBarView.self, argument: actions)!
        let vc = HostingController(rootView: contentView)
        return vc
    }

}
