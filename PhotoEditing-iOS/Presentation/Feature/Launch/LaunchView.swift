//
//  LaunchView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 18.02.2025.
//

import SwiftUI

struct LaunchView: View {
    @ObservedObject var model: LaunchViewModel
    
    var body: some View {
        Text("Launch Screen")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.model.showNextScreen()
                }
            }
    }
}
