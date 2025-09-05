//
//  PhotoEditingViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.07.2025.
//

import Foundation
import UIKit
import PixelEnginePackage

let sharedContext = CIContext(options: [.useSoftwareRenderer : false])

struct TestStruct: EditingStackItem {
    var id = UUID().uuidString
    
    let value: Int
}

final class PhotoEditingViewModel: ObservableObject {
    @NestedObservableObject var lutImageEngine: LUTImageEngine
    
    @Published var currentUIImage: UIImage = UIImage.init()
    @Published var currentCIImage: CIImage?
    
    @Published var intensity: Double = 0.0
    
    private var disposables: CancelBag
    
    init(selectedImage: UIImage) {
        self.lutImageEngine = PhotoEditing_iOS.LUTImageEngine(selectedImage: selectedImage)
        
        self.disposables = []
        
        self.lutImageEngine.currentCIImage
            .sink(receiveValue: { [weak self] img in
                self?.currentCIImage = img
            })
            .store(in: &disposables)
        
        self.lutImageEngine.currentUIImage
            .sink(receiveValue: { [weak self] img in
                self?.currentUIImage = img
            })
            .store(in: &disposables)
        
        $intensity
            .sink { value in
                print(value)
            }
            .store(in: &disposables)
    }
    
    func selectFilter(filter: FilterColorCube) {
        self.lutImageEngine.selectFilter(filter: filter)
    }
}
