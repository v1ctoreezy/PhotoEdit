//
//  LUTCollection.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 19.07.2025.
//

import Foundation
import CoreImage
import UIKit
import PixelEnginePackage

class LUTCollection {
    let lutName: String
    var lutCubeInfo: [LUTFilterColorCubeInfo] = []
    var lutCubePreviews: [PreviewFilterColorCube] = []
    
    var lutID: String {
        get {
            lutName
        }
    }
    
    init(
        lutName: String
    ) {
        self.lutName = lutName
    }
    
    func setImage(_ image: CIImage) {
        reset()
        
        lutCubeInfo.forEach {
            let lutCube = FilterColorCube(name: $0.name, identifier: $0.identifier, lutImage: UIImage(named: $0.lutImage)!, dimension: 64);
            let lutCubePreview = PreviewFilterColorCube(sourceImage: image, filter: lutCube)
            lutCubePreviews.append(lutCubePreview)
        }
        
    }
    
    private func reset() {
        self.lutCubePreviews = []
    }
}

public struct LUTFilterColorCubeInfo : Equatable {
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
