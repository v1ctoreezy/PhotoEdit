//
//  ServicesAssembly.swift
//  UMobile
//
//  Created by Good Shmorning on 30.10.2024.
//

import Swinject

class ServicesAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(MainScheduler.self) { _ in
            MainScheduler.init()
        }.inObjectScope(.container)
        
        container.register(UserInitiatedScheduler.self) { _ in
            UserInitiatedScheduler.init()
        }.inObjectScope(.container)
        
        container.register(NetworkConfiguration.self) { _ in
            NetworkConfigurationImpl.init()
        }.inObjectScope(.container)
        
        container.register(NetworkService.self) { resolver in
            ApiServiceFactory.makeRestApiService(networkConfiguration: resolver.resolve(NetworkConfiguration.self)!)
        }.inObjectScope(.container)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
