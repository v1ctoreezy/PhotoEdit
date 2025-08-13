//
//  DrawingRenderer.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 04.07.2025.
//

import Foundation
import MetalKit

protocol DrawingRenderer: MTKViewDelegate {
    
}

final class DrawingRendererImpl: NSObject, DrawingRenderer {
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
    }
}
