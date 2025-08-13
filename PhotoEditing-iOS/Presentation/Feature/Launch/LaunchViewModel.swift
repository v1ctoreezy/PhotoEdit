//
//  LaunchViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 18.02.2025.
//

import Foundation

struct LaunchActions {
    let showNextScreen: CompletionBlock
}

final class LaunchViewModel: ObservableObject {
    private final let actions: LaunchActions
    
    init(actions: LaunchActions) {
        self.actions = actions
    }
    
    func showNextScreen() {
        actions.showNextScreen()
    }
}
