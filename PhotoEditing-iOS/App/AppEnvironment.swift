//
//  AppEnvironment.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Foundation

struct AppEnvironment {
    let container: DependencyProvider
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {

    static func bootstrap() -> AppEnvironment {
        let container = DependencyProvider()
        let systemEventsHandler = SystemEventsHandlerImpl(container: container)

        return AppEnvironment(container: container,
                systemEventsHandler: systemEventsHandler)
    }
    
    static func photoBootStrap() {
        
    }
}
