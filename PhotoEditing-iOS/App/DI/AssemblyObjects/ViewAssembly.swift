//
//  ViewAssembly.swift
//  UMobile
//
//  Created by Good Shmorning on 29.10.2024.
//

import Swinject

class ViewAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(RootNavigationController.self) { resolver in
            let vc = RootNavigationController()
            vc.viewModel = resolver.resolve(RootNavigationViewModel.self)
            return vc
        }.inObjectScope(.transient)
        
        container.register(TabBarView.self) { (resolver, actions: TabActions) in
            TabBarView(selection: .constant(.news), viewModel: resolver.resolve(TabViewModel.self, argument: actions)!)
        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
