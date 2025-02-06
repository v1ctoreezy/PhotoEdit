//
//  ViewModelAssembly.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Swinject

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(RootNavigationViewModel.self) { (resolver) in
            RootNavigationViewModel()
        }.inObjectScope(.transient)
        
        container.register(TabViewModel.self) { (resolver, actions: TabActions) in
            TabViewModel(
                actions: actions
            )
        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
