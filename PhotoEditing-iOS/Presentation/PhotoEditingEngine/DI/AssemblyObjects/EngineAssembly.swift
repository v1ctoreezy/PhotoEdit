//
//  EngineAssembly.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 20.02.2025.
//

import Swinject

class EngineAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(FilterDataSource.self) { resolver in
            FilterDataSource()
        }.inObjectScope(.transient)
        
        
        container.register(FilterObject.self) { resolver in
            FilterObject()
        }.inObjectScope(.transient)
        
        container.register(ImageProcessor.self) { resolver in
            ImageProcessor()
        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
