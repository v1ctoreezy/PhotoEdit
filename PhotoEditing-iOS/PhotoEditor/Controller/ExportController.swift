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
            
            if let cropperState = self.controller.cropperCtrl.state,
               let croppedImage = originUI.cropped(withCropperState: cropperState) {
                let source = StaticImageSource(source: convertUItoCI(from: croppedImage))
                self.originExport = editState.makeCustomRenderer(source: source)
                    .render(resolution: .full)
            } else {
                self.originExport = editState.makeRenderer().render(resolution: .full)
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
