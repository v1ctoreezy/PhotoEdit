//
//  SystemEventsHandler.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Foundation

protocol SystemEventsHandler {

}


final class SystemEventsHandlerImpl: SystemEventsHandler {
    
    let container: DependencyProvider
        
    init(container: DependencyProvider) {
        self.container = container
    }
}
