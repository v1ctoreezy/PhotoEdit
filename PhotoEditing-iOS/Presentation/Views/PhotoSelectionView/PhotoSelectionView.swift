//
//  PhotoSelectionView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import SwiftUI

struct PhotoSelectionView: View {
    @ObservedObject var model: PhotoSelctionViewModel
    
    var body: some View {
        AppNavBar(title: "Photo collection", backAction: nil, trailingContent: { HStack { } }) {
            ZStack {
                UsersPhotoCatalogView(photos: model.editedPhotos) { image in
                    model.showEditPhoto(selectedImage: image)
                }
                
                ZStack {
                    Image(systemName: "plus")
                        .foregroundColor(.appBWVariants950000)
                        .frame(width: 15, height: 15)
                        .zIndex(1.0)
                }
                .background(
                    Circle()
                        .foregroundColor(Color.appRed300)
                        .frame(width: 30, height: 30)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding([.trailing, .bottom], 20)
                .onTapGesture {
                    model.showImagePicker()
                }
            }
        }
        .background(
            EmptyView().fullScreenCover(isPresented: $model.showPhotoPicker, content: {
                ImagePicker(sourceType: .photoLibrary, selectImage: { image in
//                    model.showCropView(image)
                })
                .edgesIgnoringSafeArea(.all)
            })
        )
    }
}
