//
//  BaseCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 11.11.2024.
//

import Foundation

protocol Coordinatable: AnyObject {
    func start()
}

class BaseCoordinator: NSObject {
    var childCoordinators: [Coordinatable] = []

    func addDependency(_ coordinator: Coordinatable) {
        for element in childCoordinators {
            if element === coordinator {
                return
            }
        }
        childCoordinators.append(coordinator)
    }

    func removeDependency(_ coordinator: Coordinatable?) {
        let arr = childCoordinators.filter {$0 !== coordinator}
        childCoordinators = arr
    }

    func removeAll() {
        childCoordinators = []
    }
}
