//
//  ImageProcessor.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 15.02.2025.
//

import Foundation
import CoreImage
import UIKit
import Combine

final class ImageProcessor: ObservableObject {
    private var cancellables = [AnyCancellable]()

    private var filterObject: FilterObject = FilterObject()
    
    private var lastUIImg: UIImage! = nil
    private var lastCIImg: CIImage? = nil
    private let originalImg: UIImage! = nil
    
    @Published
    var previewImage:UIImage? = nil
    
//    var editStack: EditStack
    
    init() {

    }
    
    func setImage(_ image: UIImage) {
        
        if (filterObject.isProcessing) {
            return
        }
        
        self.lastUIImg = image
        self.lastCIImg = image.ciImage
        
        filterObject.setImage(image: image)
    }
    
    func selectFilter(id: String) {
        filterObject.selectFilter(id: id)
    }
}
