//
//  Point.swift
//  PhotoEditing-iOS
//
//  Created by Виктор Черкасов on 29.05.2025.
//

import Foundation
import simd
import UIKit

struct Point {
    var position: vector_float4
    var color: vector_float4
    var size: Float

    init(position: vector_float4, color: vector_float4, size: Float) {
        self.position = position
        self.color = color
        self.size = size
    }

    init(x: CGFloat, y: CGFloat, color: UIColor, size: CGFloat) {
        self.init(position: vector_float4(Float(x), Float(y), 0, 1), color: color.vectorFloat4, size: Float(size))
    }

    init(location: CGPoint, parentSize: CGSize, color: UIColor, size: CGFloat) {
        let roundedLocation = CGPoint(x: location.x.int.cgFloat, y: location.y.int.cgFloat)
        let xK = (1.0 / (parentSize.width / roundedLocation.x)).rounded(symbolsAfterComma: 5)
        let yK = (1.0 / (parentSize.height / roundedLocation.y)).rounded(symbolsAfterComma: 5)
        let x = xK == 0.5 ? 0.0 : (xK < 0.5 ? -(1 - xK / 0.5) : xK / 0.5 - 1)
        let y = yK == 0.5 ? 0.0 : (yK > 0.5 ? (1 - yK / 0.5) : 1 - (yK / 0.5))
        self.init(x: x, y: y, color: color, size: size)
    }
}
