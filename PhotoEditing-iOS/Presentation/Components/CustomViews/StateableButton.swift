//
//  StateableButton.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 04.12.2024.
//

import SwiftUI

struct StateableButton<Content>: ButtonStyle where Content: View {
    var change: (Bool) -> Content
    
    func makeBody(configuration: Configuration) -> some View {
        return change(configuration.isPressed)
    }
}
