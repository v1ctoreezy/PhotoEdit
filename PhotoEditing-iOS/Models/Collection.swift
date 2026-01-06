import Foundation
import PixelEnginePackage
import SwiftUI

public class Collection: ObservableObject {
    
    public let name: String
    public let identifier: String
    public var cubeInfos:[FilterColorCubeInfo]
    
    // Deprecated - use lazy loading instead
    @available(*, deprecated, message: "Use lazy loading with LazyPreviewManager instead")
    public var cubePreviews:[PreviewFilterColorCube] = []
    
    // Lazy loading support
    public var sourceImage: CIImage?
    
    ///
    @available(*, deprecated, message: "Use setSourceImage instead for lazy loading")
    public func setImage(image:CIImage?){
        self.cubePreviews = []
        if let cubeSourceCI: CIImage = image
        {
            for item in cubeInfos {
                let cube = FilterColorCube(name: item.name, identifier: item.identifier, lutImage: UIImage(named: item.lutImage)!, dimension: 64);
                let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: cube)
                cubePreviews.append(preview)
                
            }
        }
    }
    
    /// Set source image for lazy preview generation
    public func setSourceImage(image: CIImage?) {
        self.sourceImage = image
        // Clear any cached previews when source changes
        if image != nil {
            for item in cubeInfos {
                LazyPreviewManager.shared.clearPreview(for: item.identifier)
            }
        }
    }
    
    /// Get filter for a specific cube
    public func getFilter(for identifier: String) -> FilterColorCube? {
        guard let info = cubeInfos.first(where: { $0.identifier == identifier }) else {
            return nil
        }
        return info.getFilter()
    }
    
    ///
    public func reset(){
        cubePreviews = []
        sourceImage = nil
    }
    
    ///
    public init(
        name: String,
        identifier: String,
        cubeInfos: [FilterColorCubeInfo] = []
    ) {
        self.name = name
        self.identifier = identifier
        self.cubeInfos = cubeInfos
    }
    
}

public struct FilterColorCubeInfo : Equatable {
    public let name: String
    public let identifier: String
    public let lutImage:String
    
    public init(
        name: String,
        identifier: String,
        lutImage: String
    ) {
        self.name = name
        self.identifier = identifier
        self.lutImage = lutImage
    }
    
    func getFilter()-> FilterColorCube{
        return FilterColorCube(name: name, identifier: identifier, lutImage: UIImage(named: lutImage)!, dimension: 64)
    }
    
}
