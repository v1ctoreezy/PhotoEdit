import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class LutsController : ObservableObject{
    
    @Published var loadingLut:Bool = false
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
        self.cubeSourceCG = nil
        self.cubeSourceCI = image
        loadingLut = true
        LazyPreviewManager.shared.clearCache()
        
        collections = Data.shared.collections
        
        DispatchQueue.global(qos: .background).async{
            self.cubeSourceCG = sharedContext.createCGImage(image, from: image.extent)!
            for e in self.collections {
                e.setSourceImage(image: image)
            }
            
            DispatchQueue.main.async {
                self.loadingLut = false
            }
        }
    }

    func selectCube(_ value:String){
        currentCube = value
    }

    func onSetEditingMode(_ value:Bool){
        editingLut = value
    }
    
}
