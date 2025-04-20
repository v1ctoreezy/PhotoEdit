//
//  UsersPhotoCatalogView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import SwiftUI

struct UsersPhotoCatalogView: View {
    
    var photos: [UIImage]?
    
    let onPhotoClick: (UIImage) -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach((photos ?? [UIImage]()), id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: UIScreen.main.bounds.size.width / 3,
                                height: UIScreen.main.bounds.size.width / 3
                            )
                            .clipped()
                            .onTapGesture {
                                onPhotoClick(image)
                            }
                    }
                }
            }
            Spacer()
        }
    }
}
