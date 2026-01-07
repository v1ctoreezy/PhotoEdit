import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import QCropper
import CoreData

class ExportController : ObservableObject{
    
    // Export
    @Published var originExport:UIImage?
    
    var originRatio: Double {
        guard let originUI = PhotoEditingController.shared.originUI else { return 1.0 }
        return originUI.size.width / originUI.size.height
    }
    
    var controller: PhotoEditingController {
        get {
            PhotoEditingController.shared
        }
    }
    
    func prepareExport() {
        guard originExport == nil,
              let editState = controller.editState,
              let originUI = controller.originUI else { return }
        
        controller.didReceive(action: .commit)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Preview height used during editing (must match PhotoEditorController)
            let previewHeight: CGFloat = 512
            
            // Render base image with filters
            var renderedImage: UIImage?
            if let cropperState = self.controller.cropperCtrl.state,
               let croppedImage = originUI.cropped(withCropperState: cropperState) {
                let source = StaticImageSource(source: convertUItoCI(from: croppedImage))
                renderedImage = editState.makeCustomRenderer(source: source)
                    .render(resolution: .full)
            } else {
                renderedImage = editState.makeRenderer().render(resolution: .full)
            }
            
            // Apply text elements on top of the rendered image
            // Pass preview height to ensure correct font scaling
            if let baseImage = renderedImage {
                let textElements = self.controller.textCtrl.textElements
                self.originExport = baseImage.withTextElements(textElements, previewHeight: previewHeight)
            }
        }
    }
    
    func resetExport() {
        originExport = nil
    }
    
    func exportOrigin() {
        if let origin = originExport{
            ImageSaver().writeToPhotoAlbum(image: origin)
        }
        return
    }
   
}
