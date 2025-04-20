//
//  ViewModelAssembly.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Swinject
import UIKit

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(RootNavigationViewModel.self) { (resolver) in
            RootNavigationViewModel()
        }.inObjectScope(.transient)
        
        container.register(LaunchViewModel.self) { (resolver, actions: LaunchActions) in
            LaunchViewModel(actions: actions)
        }.inObjectScope(.transient)
        
        container.register(TabViewModel.self) { (resolver, actions: TabActions) in
            TabViewModel(
                actions: actions
            )
        }.inObjectScope(.transient)
        
        container.register(TabViewModel.self) { (resolver, actions: TabActions) in
            TabViewModel(
                actions: actions)
        }.inObjectScope(.transient)
        
        container.register(PhotoSelctionViewModel.self) { (resolver, actions: PhotoSelctionActions) in
            PhotoSelctionViewModel(actions: actions)
        }.inObjectScope(.transient)
        
        container.register(PhotoEditingViewModel.self) { (resolver, image: UIImage, actions: PhotoEditingActions) in
            PhotoEditingViewModel(originalImage: image, actions: actions)
        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
