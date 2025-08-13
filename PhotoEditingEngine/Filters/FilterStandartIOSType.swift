//
//  Filters.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 07.02.2025.
//

import Foundation

enum FilterStandartIOSType : String, CaseIterable, Equatable, Hashable {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer =  "CIPhotoEffectTransfer"
}

enum ProcessEffect {
    case builtIn
    case colorKernel
    case wrapKernel
    case blendKernel
}
