//
//  CIImage+Ext.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 19.02.2025.
//

import Foundation
import UIKit

extension CIImage {
    static func mapOrientation(_ orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        return switch orientation {
        case .up:
                .up
        case .down:
                .down
        case .left:
                .left
        case .right:
                .right
        case .upMirrored:
                .upMirrored
        case .downMirrored:
                .downMirrored
        case .leftMirrored:
                .leftMirrored
        case .rightMirrored:
                .rightMirrored
        }
    }
}
