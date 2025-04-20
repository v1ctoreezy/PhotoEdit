//
//  FiltersListViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 08.02.2025.
//

import SwiftUI
import Combine
import UIKit

final class FiltersListViewModel: ObservableObject {
    private final let imgProcessor: ImageProcessor = ImageProcessor()
    
    @Published var filteredImages: [String:UIImage?] = [:]
    @Published var originalImage: UIImage
    
    init(originalImage: UIImage) {
        self.originalImage = originalImage
        
        asyncApplyFiltersPreview()
    }

    private func asyncApplyFiltersPreview() {
        FilterStandartIOSType.allCases.forEach { filter in
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let `self` = self else { return }
//                let filteredImg = self.originalImage.applyFilter(filter)
//                DispatchQueue.main.async {
//                    self.filteredImages[filter.rawValue] = filteredImg
//                }
                self.imgProcessor.setImage(self.originalImage)
            }
        }
    }
}
