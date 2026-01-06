import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class LutsController : ObservableObject{
    
    @Published var loadingLut:Bool = false
    
    // Cube
    var collections:[Collection] = []
    var cubeSourceCG:CGImage?
    var cubeSourceCI:CIImage?
    
    @Published var currentCube:String = ""
    @Published var editingLut:Bool = false
    
    var showLoading:Bool{
        get{
            return loadingLut || cubeSourceCG == nil
        }
    }
    
    func setImage(image:CIImage){
        currentCube = ""
        /// setImage
        self.cubeSourceCG = nil
        self.cubeSourceCI = image
        loadingLut = true
        
        // Clear preview cache when changing image
        LazyPreviewManager.shared.clearCache()
        
        collections = Data.shared.collections
        
        DispatchQueue.global(qos: .background).async{
            print("init Cube - using lazy loading")
            self.cubeSourceCG = sharedContext.createCGImage(image, from: image.extent)!
            
            // NEW: Use lazy loading instead of generating all previews at once
            for e in self.collections {
                e.setSourceImage(image: image)
            }
            
            DispatchQueue.main.async {
                self.loadingLut = false
                print("LUT initialization complete - previews will load on demand")
            }
        }
    }
    
    ///
    func selectCube(_ value:String){
        currentCube = value
    }
    
    ///
    func onSetEditingMode(_ value:Bool){
        editingLut = value
    }
    
}
