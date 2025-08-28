//
//  PhotoSelctionViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import Foundation
import UIKit

struct PhotoSelctionActions {
    let showCropView: (UIImage) -> Void
    let showImagePicker: CompletionBlock
}

final class PhotoSelctionViewModel: ObservableObject {
    private final let actions: PhotoSelctionActions
//    private final let getUserEditedPhotosUseCase: GetUserEditedPhotosUseCase
    
    @Published var editedPhotos: [UIImage]?
    
    @Published var showPhotoPicker: Bool = false

    init(actions: PhotoSelctionActions) {
        self.actions = actions
        
        getUserEditedPhotos()
    }
    
    func showEditPhoto(selectedImage: UIImage) {
//        showPhotoPicker = false
        actions.showCropView(selectedImage)
    }
    
    func getUserEditedPhotos() {
        self.editedPhotos = [
            UIImage(named: "IMG_8740")!,
            UIImage(named: "IMG_333")!,
            UIImage(named: "IMG_222")!
        ]
    }
    
    func showImagePicker() {
        showPhotoPicker = true
//        actions.showImagePicker()
    }
}
