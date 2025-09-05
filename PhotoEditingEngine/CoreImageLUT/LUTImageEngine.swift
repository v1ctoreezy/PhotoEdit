//
//  LUTImageEngine.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 24.08.2025.
//

import Combine
import UIKit
import PixelEnginePackage

protocol LUTImageEngineProtocol {
    
}

enum LUTImageEnginePhotoFilterMode {
    case stackable
    case original
}

enum LUTControls: String, CaseIterable {
    case filters = "camera.filters"
    case settings = "gearshape.fill"
    case recipe = "bookmark.fill"
}

enum LUTImageEngineTools: String {
    case exposition
    case contrast
    case saturation
    case whiteBalance
}

struct LUTEngineConfig {
    let availableTools: [LUTImageEngineTools] = [.contrast, .exposition, .saturation, .whiteBalance]
    let availableControls: [LUTControls] = [.filters, .settings, .recipe]
    let photoFilterMode: LUTImageEnginePhotoFilterMode = .original
    
}

final class LUTImageEngine: ObservableObject {
    private var lutExporter = LUTExporter()
    
    var currentUIImage = CurrentValueSubject<UIImage, Never>(UIImage.init())
    var currentCIImage = CurrentValueSubject<CIImage?, Never>(nil)
    
    @Published private var originalUIImageInternal: UIImage
    @Published private var originalCIImageInternal: CIImage?
    
    @Published private var currentUIImageInternal: UIImage
    @Published private var currentCIImageInternal: CIImage?
    
    @Published var selectedFilter: FilterColorCube? = nil
    @Published var lutCollections: [LUTCollection] = []
    
    @Published var isProccessing: Bool = false
        
    @Published var lutEngineConfig: LUTEngineConfig = LUTEngineConfig()
    
    var photoFilterMode: LUTImageEnginePhotoFilterMode {
        lutEngineConfig.photoFilterMode
    }
    
    var lutControls: [LUTControls] {
        lutEngineConfig.availableControls
    }
    
    var lutSettingsTools: [LUTImageEngineTools] {
        lutEngineConfig.availableTools
    }
    
    @Published var currentValue: TestStruct?
    var editingStack = PhotoEditingStackImpl<TestStruct>()
    
    init(selectedImage: UIImage) {
        self.originalUIImageInternal = selectedImage
        self.originalCIImageInternal = CIImage(image: selectedImage)
        
        self.currentUIImageInternal = selectedImage
        self.currentCIImageInternal = CIImage(image: selectedImage)
        
        self.lutCollections = lutExporter.collections
        
        updateSubjects()
        
        self.setImage(image: selectedImage)
    }
    
    func setImage(image: UIImage) {
        isProccessing = true
        
        self.currentUIImageInternal = image
        self.currentCIImageInternal = CIImage(image: image)
        
        if let smallImage = resizedImage(at: convertUItoCI(from: image), scale: 128 / image.size.height, aspectRatio: 1) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.lutCollections.forEach {
                    $0.setImage(smallImage)
                }
                
                DispatchQueue.main.async {
                    self.isProccessing = false
                }
            }
        }
    }
    
    func selectFilter(filter: FilterColorCube) {
        switch photoFilterMode {
        case .stackable:
            selectFilterTo(filter: filter)
        case .original:
            selectFilterTo(filter: filter)
        }
    }
    
    private func selectFilterTo(filter: FilterColorCube) {
        self.selectedFilter = filter
        let currentImgDueMode = self.photoFilterMode == .original ? self.originalCIImageInternal : self.currentCIImageInternal
        
        if let ciImg = currentImgDueMode {
            let filteredImage = filter.apply(to: ciImg, sourceImage: ciImg)
            self.currentCIImageInternal = filteredImage
            self.currentUIImageInternal = UIImage(ciImage: filteredImage)
            
            updateSubjects()
        }
    }
    
    private func updateSubjects() {
        self.currentUIImage.send(currentUIImageInternal)
        self.currentCIImage.send(currentCIImageInternal)
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
