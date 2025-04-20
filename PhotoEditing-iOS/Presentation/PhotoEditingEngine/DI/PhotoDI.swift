//
//  PhotoDI.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 20.02.2025.
//

import Foundation
import Swinject

class PhotoEngineDependencyProvider {
    let container = Container()
    let assembler: Assembler
    
    init() {
        assembler = Assembler([
            EngineAssembly()
        ])
    }
}
