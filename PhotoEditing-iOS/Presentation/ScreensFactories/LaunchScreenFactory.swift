//
//  LaunchScreenFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 18.02.2025.
//

import Foundation
import UIKit

protocol LaunchScreenFactory {
    func makeLaunchScreen(actions: LaunchActions) -> UIViewController
}

extension ScreensFactory: LaunchScreenFactory {
    func makeLaunchScreen(actions: LaunchActions) -> UIViewController {
        let contentView = dependencyProvider.assembler.resolver.resolve(LaunchView.self, argument: actions)
        let vc = HostingController(rootView: contentView)
        
        return vc
    }
}
