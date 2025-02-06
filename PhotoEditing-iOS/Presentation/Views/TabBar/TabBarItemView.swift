//
//  TabBarItemView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

struct TabBarItemView: View {

    let page: TabBarPage
    @Binding var isPressed: Bool
    @State private var scale: CGFloat = 1.0
    var isSelected: Bool

    init(page: TabBarPage, isActive: Binding<Bool>, isSelected: Bool) {
        self.page = page
        self._isPressed = isActive
        self.isSelected = isSelected
    }



    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            page.pageImage()
                .renderingMode(.template)
                .foregroundColor(isSelected ? .appOrange500 : .appBWVariants300600)
                .scaleEffect(scale)
                .animation(.spring(response: 0.15, dampingFraction: 0.35, blendDuration: 0.35), value: scale)

            Spacer()
        }
        .onChange(of: isPressed) { newValue in
            if newValue {
                withAnimation {
                    scale = 0.9
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scale = 1.1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            scale = 1.0
                        }
                    }
                }
            } else {
                scale = 1.0
            }
        }
        .onAppear {
            print(page.rawValue)
        }
    }
}
