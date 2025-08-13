//
//  HelperAssembly.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Swinject

class HelperAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MetalContext.self) { resolver in
            guard let device = MTLCreateSystemDefaultDevice() else { fatalError("Failed to create MTLDevice in DI")}
            
            return MetalContext(device: device)
        }.inObjectScope(.transient)
    }
    
    func loaded(resolver: Resolver) {
        
    }
}
