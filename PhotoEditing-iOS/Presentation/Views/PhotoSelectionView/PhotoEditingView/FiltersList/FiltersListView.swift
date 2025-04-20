//
//  FiltersListView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 08.02.2025.
//

import SwiftUI

struct FiltersListView: View {
    var filteredImages: [String:UIImage?]
    var onFilterClick: (UIImage) -> Void
            
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    LazyHStack {
                        ForEach(FilterStandartIOSType.allCases, id: \.self) { filter in
                            makeFilterImageCell(filter: filter)
                        }
                    }
                }
                .fixedSize()
            }
            .scrollIndicators(.hidden)
            let _ = Self._printChanges()
        }
    }
    
    private func makeFilterImageCell(filter: FilterStandartIOSType) -> some View {
        VStack(spacing: 0) {
            if let filImg = filteredImages[filter.rawValue]?.unsafelyUnwrapped {
                Image(uiImage: filImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 125)
                    .cornerRadius(10)
                    .onTapGesture {
                        onFilterClick(filImg)
                    }
            } else {
                ZStack {
                    Color.appOrange100
                        .frame(width: 100, height: 125)
                        .cornerRadius(10)
                    
                    AppLoader(loaderGradient: (Color.appBlue300, Color.appBlue500), isShowing: .constant(true), width: 20, height: 20, lineWidth: 1.0)
                        .frame(alignment: .center)
                }
            }
            
//            Text(filter.rawValue)
//                .font(.app_S)
//                .foregroundColor(.appBWVariants950000)
        }
    }
}
