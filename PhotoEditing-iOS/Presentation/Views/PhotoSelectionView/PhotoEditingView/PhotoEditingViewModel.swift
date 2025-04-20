//
//  PhotoEditingViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 07.02.2025.
//

import Foundation
import Combine
import UIKit

struct PhotoEditingActions {
    let dismiss: CompletionBlock
}

final class PhotoEditingViewModel: ObservableObject {
    
    private final let actions: PhotoEditingActions
    
    private final let imgProcessor: ImageProcessor = ImageProcessor()
    
    let originalImage: UIImage
    @Published var image: UIImage
    @Published var filteredImages: [String:UIImage?] = [:]
    
    init(originalImage: UIImage, actions: PhotoEditingActions) {
        self.originalImage = originalImage
        self.image = originalImage
        self.actions = actions
        
        asyncApplyFiltersPreview()
    }
    
    func savePhotoToUserLibrary(_ image: UIImage, completion: @escaping CompletionBlock) {
        ImageSaver.shared.writeToPhotoAlbum(image: image, completion: completion)
    }
    
    
    func dismiss() {
        actions.dismiss()
    }
    
    private func asyncApplyFiltersPreview() {
//        FilterStandartIOSType.allCases.forEach { filter in
            DispatchQueue.global(qos: .userInteractive).async {
//                let filteredImg = self.originalImage.applyStandartFilter(filter)
//                DispatchQueue.main.async {
//                    self.filteredImages[filter.rawValue] = filteredImg
//                }
                
                self.imgProcessor.setImage(self.originalImage)
            }
//        }
    }
}
