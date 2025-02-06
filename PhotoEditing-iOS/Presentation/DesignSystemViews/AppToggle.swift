//
//  AppToggle.swift
//  UMobile
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import SwiftUI

struct AppToggle: View {
    
    @Binding var selectedIndex: Int
    @Namespace private var appToggleNamespace
    
    var items: [String]
    
    init(items: [String], selectedIndex: Binding<Int>) {
        self.items = items
        self._selectedIndex = selectedIndex
    }
    
    var body: some View {
        HStack {
            ForEach(0..<items.count, id: \.self) { index in
                Text(items[index])
                    .font(.app_S)
                    .foregroundColor(selectedIndex == index ? .appOrange500 : .appBWVariants500500)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(selectedIndex == index ? selectorItemBackgroundCapsule : nil)
                    .padding(4)
                    .onTapGesture { selectIndex(index) }
            }
        }
        .background(
            Color.appBWVariants050800
                .cornerRadius(20.0)
        )
    }
    
    var selectorItemBackgroundCapsule: some View {
        RoundedRectangle(cornerRadius: .infinity)
            .fill(Color.appBWVariants000900)
            .matchedGeometryEffect(id: "selectorItemBackgroundCapsule", in: appToggleNamespace)
    }
    
    private func selectIndex(_ index: Int) {
        withAnimation(.spring(response: 0.475)) {
            selectedIndex = index
        }
    }
}

//#Preview {
//    AppToggle(items: ["готово", "в работе", "выдано"], selectedIndex: .constant(0))
//}
