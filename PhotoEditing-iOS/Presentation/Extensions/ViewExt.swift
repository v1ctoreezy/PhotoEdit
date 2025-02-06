//
//  ViewExt.swift
//  UMobile
//
//  Created by Good Shmorning on 04.12.2024.
//

import SwiftUI

enum TabBarVisibility: CaseIterable {
    
    case visible
    case invisible
    
    mutating func toggle() {
        switch self {
        case .visible:
            self = .invisible
        case .invisible:
            self = .visible
        }
    }
}

extension View {
    @ViewBuilder func visibility(_ visibility: TabBarVisibility) -> some View {
        switch visibility {
        case .visible:
            self.transition(.move(edge: .bottom))
        case .invisible:
            hidden().transition(.move(edge: .bottom))
        }
    }
}
