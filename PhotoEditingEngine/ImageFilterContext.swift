//
//  ImageFilterContext.swift
//  PhotoEditing-iOS
//
//  Created by Виктор Черкасов on 03.07.2025.
//

import Foundation
import CoreImage

final class ImageFilterContext {
    var ciContext: CIContext
    
    init(ciContext: CIContext) {
        self.ciContext = ciContext
    }
}
