//
//  File.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 19.02.2025.
//

import Foundation
import CoreImage
import SwiftUI

protocol ImgFilter {
    var name: String { get }
    var id: String { get }
    
    func applyFilter(to originalImg: UIImage) -> UIImage
}

final class ImgStandartFilterImpl: ImgFilter {
    let name: String
    let id: String
    
    let type: FilterStandartIOSType
    
    init(name: String, id: String, type: FilterStandartIOSType) {
        self.name = name
        self.id = id
        self.type = type
    }
    
    func applyFilter(to originalImg: UIImage) -> UIImage {
        originalImg.applyStandartFilter(type)
    }
}

final class ImgCustomFilterImpl: ImgFilter {
    let name: String
    let id: String
        
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    func applyFilter(to originalImg: UIImage) -> UIImage {
        originalImg.applyStandartFilter(.Fade)
    }
}
