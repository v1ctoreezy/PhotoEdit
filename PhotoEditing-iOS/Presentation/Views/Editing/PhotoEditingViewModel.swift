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

final class PhotoEditingViewModel {
    private var lutExporter = LUTExporter()
    
    @Published var lutCollections: [LUTCollection] = []
    @Published var originalImage: UIImage
    @Published var currentImage: UIImage
    
    @Published var isProccessing: Bool = false
    
    @Published var selectedFilter: FilterColorCube? = nil
        
    @Published var currentValue: TestStruct?
    var editingStack = PhotoEditingStackImpl<TestStruct>()
    
    private var disposables: CancelBag
    
    init(selectedImage: UIImage) {
        self.currentImage = selectedImage
        self.originalImage = selectedImage
        
        self.lutCollections = lutExporter.collections
        
        self.disposables = []
        
        self.setImage(image: self.currentImage)
    }
    
    func setImage(image: UIImage) {
        isProccessing = true
        
        if let smallImage = resizedImage(at: convertUItoCI(from: currentImage), scale: 128 / self.currentImage.size.height, aspectRatio: 1) {
            self.lutCollections.forEach {
                $0.setImage(smallImage)
            }
        }
        
        isProccessing = false
    }
    
    func selectFilter(filter: FilterColorCube) {
        self.selectedFilter = filter
        
        DispatchQueue.main.async {
            
            
            if let unwrappedFilter = self.selectedFilter, let ciImg = CIImage(image: self.originalImage) {
                
                self.currentImage = UIImage(ciImage: unwrappedFilter.apply(to: ciImg, sourceImage: ciImg))
            }
//            if let preview = filter.filter.outputImage, let cgimg = sharedContext.createCGImage(preview, from: preview.extent) {
//                self.currentImage = UIImage(cgImage: cgimg)
//            }
        }
    }
}

func convertUItoCI(from:UIImage) -> CIImage{
    let image = CIImage(image: from)!
    let fixedOriantationImage = image.oriented(forExifOrientation: imageOrientationToTiffOrientation(from.imageOrientation))
    return fixedOriantationImage
}

func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
  switch value{
  case .up:
    return 1
  case .down:
    return 3
  case .left:
    return 8
  case .right:
    return 6
  case .upMirrored:
    return 2
  case .downMirrored:
    return 4
  case .leftMirrored:
    return 5
  case .rightMirrored:
    return 7
  default:
    return 1
  }
}

func resizedImage(at image: CIImage, scale: CGFloat, aspectRatio: CGFloat) -> CIImage? {
    
    let filter = CIFilter(name: "CILanczosScaleTransform")
    filter?.setValue(image, forKey: kCIInputImageKey)
    filter?.setValue(scale, forKey: kCIInputScaleKey)
    filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
    
    return filter?.outputImage
}
