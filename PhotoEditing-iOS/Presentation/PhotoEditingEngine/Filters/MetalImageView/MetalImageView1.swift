//
//  MetalImageView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import AVFoundation
import UIKit
import MetalKit

internal class MetalImageViewUIKit: MTKView {
    private var mtlTexture: MTLTexture?
    private var commandQueue: MTLCommandQueue?
    private var ciContext: CIContext?
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        isOpaque = false
        enableSetNeedsDisplay = true
        framebufferOnly = false
    }
    
    func render(image: CIImage, context: CIContext, device: MTLDevice) {
        ciContext = context
        self.device = device
        
        var rect = bounds
        rect = AVMakeRect(aspectRatio: image.extent.size, insideRect: rect)
        
        let filteredImage = image.transformed(by:
                                                CGAffineTransform(
                                                    scaleX: rect.size.width/image.extent.size.width,
                                                    y: rect.size.height/image.extent.size.height
                                                )
        )
        
        let x = -rect.origin.x
        let y = -rect.origin.y
        
        commandQueue = self.device?.makeCommandQueue()
        
        let buffer = commandQueue?.makeCommandBuffer()!
        mtlTexture = currentDrawable?.texture
        
        ciContext!.render(filteredImage.oriented(.down),
                         to: currentDrawable!.texture,
                         commandBuffer: buffer,
                         bounds: CGRect(origin: CGPoint(x: x, y: y), size: drawableSize),
                         colorSpace: CGColorSpaceCreateDeviceRGB()
        )
        
        buffer?.present(currentDrawable!)
        buffer?.commit()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
