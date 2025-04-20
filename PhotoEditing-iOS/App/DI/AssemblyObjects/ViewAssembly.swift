//
//  ViewAssembly.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Swinject
import UIKit

class ViewAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(RootNavigationController.self) { resolver in
            let vc = RootNavigationController()
            vc.viewModel = resolver.resolve(RootNavigationViewModel.self)
            return vc
        }.inObjectScope(.transient)
        
        container.register(LaunchView.self) { (resolver, actions: LaunchActions) in
            LaunchView(model: resolver.resolve(LaunchViewModel.self, argument: actions)!)
        }.inObjectScope(.transient)
        
        container.register(PhotoSelectionView.self) { (resolver, actions: PhotoSelctionActions) in
            PhotoSelectionView(model: resolver.resolve(PhotoSelctionViewModel.self, argument: actions)!)
        }
        .inObjectScope(.transient)
        
        container.register(PhotoEditingView.self) { (resolver, image: UIImage, actions: PhotoEditingActions) in
            PhotoEditingView(model: resolver.resolve(PhotoEditingViewModel.self, arguments: image, actions)!)
        }.inObjectScope(.transient)
        
//        container.register(TabBarView.self) { (resolver, actions: TabActions) in
//            TabBarView(_
//            TabBarView(selection: .constant(.news), viewModel: resolver.resolve(TabViewModel.self, argument: actions)!)
//        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
