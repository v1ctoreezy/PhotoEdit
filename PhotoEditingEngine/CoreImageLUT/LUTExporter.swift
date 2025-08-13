//
//  Data.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 17.07.2025.
//

import Foundation
import UIKit
import PixelEnginePackage

class LUTExporter {
    static let shared = LUTExporter()
    
    var neturalLUT: UIImage?
    var neutralCube: FilterColorCube!
    var collections: [LUTCollection] = []
    
    init() {
        autoreleasepool {
            self.neturalLUT = UIImage(named: "lut-normal")!

            let basic = LUTCollection(lutName: "Basic")
            for i in 1...10{
                let cube =  LUTFilterColorCubeInfo(
                    name: "A\(i)",
                    identifier: "basic-\(i)",
                    lutImage: "lut-\(i)"
                )
                basic.lutCubeInfo.append(cube)
            }
            // Cinematic
            let cinematic = LUTCollection(lutName: "Cinematic")
            for i in 1...10{
                let cube =  LUTFilterColorCubeInfo(
                    name: "C\(i)",
                    identifier: "Cinematic-\(i)",
                    lutImage: "cinematic-\(i)"
                )
                cinematic.lutCubeInfo.append(cube)
            }
            // Film
            let film = LUTCollection(lutName: "Film")
            for i in 1...3{
                let cube =  LUTFilterColorCubeInfo(
                    name: "Film\(i)",
                    identifier: "Film-\(i)",
                    lutImage: "film-\(i)"
                )
                film.lutCubeInfo.append(cube)
            }
            // Selfie Good Skin
            let selfie = LUTCollection(lutName: "Selfie")
            for i in 1...12{
                let cube =  LUTFilterColorCubeInfo(
                    name: "Selfie\(i)",
                    identifier: "Selfie-\(i)",
                    lutImage: "selfie-\(i)"
                )
                selfie.lutCubeInfo.append(cube)
            }
            // init collections
            self.collections = [basic, cinematic, film, selfie]
        }
    }
        
    // Cube by collection
    func cubeBy(identifier: String) -> FilterColorCube? {
        for e in self.collections {
            for cube in e.lutCubeInfo{
                if(cube.identifier == identifier){
                    return cube.getFilter()
                }
            }
        }
        return nil;
    }
}
