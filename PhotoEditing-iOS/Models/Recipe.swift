import Foundation
import PixelEnginePackage
import SwiftUI
import CoreImage

public class Recipe: ObservableObject {
    
    public let data: RecipeObject
    @available(*, deprecated, message: "Use lazy loading with LazyPreviewManager instead")
    public var preview: UIImage?
    public var sourceImage: CIImage?
    
    init(data: RecipeObject){
        self.data = data
        preview = nil
    }

    public var identifier: String {
        return data.objectID.uriRepresentation().absoluteString
    }
    @available(*, deprecated, message: "Use setSourceImage instead for lazy loading")
    public func setImage(image:CIImage?){
        if let cubeSourceCI: CIImage = image
        {
            let draft = EditingStack.init(source: StaticImageSource(source: cubeSourceCI))
            let colorCube:FilterColorCube? = Data.shared.cubeBy(identifier: data.lutIdentifier ?? "")
            
            draft.set(filters: RecipeUtils.applyRecipe(data, colorCube: colorCube))
            if let ciImage = draft.previewImage{
                if let cgimg = sharedContext.createCGImage(ciImage, from: ciImage.extent) {
                    self.preview = UIImage(cgImage: cgimg)
                }
            }
        }
    }

    public func setSourceImage(image: CIImage?) {
        self.sourceImage = image
        if image != nil {
            LazyPreviewManager.shared.clearPreview(for: identifier)
        }
    }
    
}

