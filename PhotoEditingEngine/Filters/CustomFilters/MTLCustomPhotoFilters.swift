//
//  MTLCustomPhotoFilters.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 04.07.2025.
//

import Foundation

struct AppFilter: Identifiable {
    let id: String = UUID().uuidString
    let mtlFilter: MTLCustomPhotoFilters
    
    var name: String {
        mtlFilter.rawValue
    }
}

enum MTLCustomPhotoFilters: String {
    case Standart = "standartColor"
    case LinearBurn = "linearBurn"
    case InvertedColor = "invertColors"
    case Exposition = "expositionFilter"
    case Contrast = "contrastFilter"
    case Saturation = "saturationFilter"
    case WhiteBalance = "whiteBalanceFilter"
}
