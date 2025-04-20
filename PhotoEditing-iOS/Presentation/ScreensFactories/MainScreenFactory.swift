//
//  MainScreenFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import UIKit

protocol MainScreenFactory {
    func makeTabScreen(withPages pages: [TabBarPage], withTabControllers tabControllers: [TabBarPage: UIViewController]) -> TabBarController    
}

extension ScreensFactory: MainScreenFactory {
    func makeTabScreen(withPages pages: [TabBarPage], withTabControllers tabControllers: [TabBarPage: UIViewController]) -> TabBarController {
        let tabBarController = TabBarController()
        
        tabBarController.tabControllers = tabControllers
        return tabBarController
    }
}
