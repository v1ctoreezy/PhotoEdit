//
//  Dependency Provider.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Swinject

class DependencyProvider {
    
    let container = Container()
    let assembler: Assembler
    
    init() {
        assembler = Assembler(
            [ServicesAssembly(),
             HelperAssembly(),
             ManagerAssembly(),
             RepositoryAssembly(),
             UseCaseAssembly(),
             StorageAssembly(),
             ViewModelAssembly(),
             ViewAssembly()],
            
            container: container
        )
    }
}
