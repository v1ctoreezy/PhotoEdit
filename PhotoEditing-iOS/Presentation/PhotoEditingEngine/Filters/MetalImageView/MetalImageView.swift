//
//  MetalImageViewSUI.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import Foundation
import SwiftUI
import MetalKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

struct MetalImageView: UIViewRepresentable {
    var image: CIImage
    let device: MTLDevice
    let context: CIContext

    func makeUIView(context: Context) -> MTKView {
        let metalView = MTKView()
        
        metalView.device = device
        metalView.delegate = context.coordinator
        
        metalView.isOpaque = false
        metalView.enableSetNeedsDisplay = true
        metalView.framebufferOnly = false
        
//        context.coordinator.metalView = metalView
        
        return metalView
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
//        context.coordinator.render(image: image, metalView: uiView)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(device: device, context: context, image: image)
    }

    class Coordinator: NSObject, MTKViewDelegate {
        var device: MTLDevice
        var ciContext: CIContext
        var commandQueue: MTLCommandQueue?
        var image: CIImage
//        weak var metalView: MTKView?

        init(device: MTLDevice, context: CIContext, image: CIImage) {
            self.device = device
            self.ciContext = context
            self.image = image
            self.commandQueue = device.makeCommandQueue()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }
        
        func draw(in view: MTKView) {
            render(image: image, metalView: view)
        }

        private func render(image: CIImage, metalView: MTKView?) {
            guard let metalView = metalView,
                  let drawable = metalView.currentDrawable,
                  let commandQueue = commandQueue,
                  let buffer = commandQueue.makeCommandBuffer() else { return }

            let bounds = metalView.bounds
            let drawableSize = metalView.drawableSize

            var rect = bounds
            rect.size = drawableSize
            rect = AVMakeRect(aspectRatio: image.extent.size, insideRect: rect)

            let scaledImage = image.transformed(by: CGAffineTransform(
                scaleX: rect.size.width / image.extent.size.width,
                y: rect.size.height / image.extent.size.height
            ))

            let x = -rect.origin.x
            let y = -rect.origin.y

            ciContext.render(
                scaledImage.oriented(.down),
                to: drawable.texture,
                commandBuffer: buffer,
                bounds: CGRect(origin: CGPoint(x: x, y: y), size: drawableSize),
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )

            buffer.present(drawable)
            buffer.commit()
        }
    }
}

//struct MetalImageView: UIViewRepresentable {
//    @Binding var intensity: CGFloat
//    @State private var mtkView: MTKView = MTKView()
//    
//    internal var image: CIImage?
//    internal var mtlTexture: MTLTexture?
//    internal var commandQueue: MTLCommandQueue?
//    internal var ciContext: CIContext?
//    internal var device: MTLDevice!
//    
//    init(intensity: Binding<CGFloat>, image: CIImage? = nil, mtlTexture: MTLTexture? = nil, commandQueue: MTLCommandQueue? = nil, ciContext: CIContext? = nil, device: MTLDevice!) {
//        self._intensity = intensity
//        self.mtkView = mtkView
//        self.image = image
//        self.mtlTexture = mtlTexture
//        self.commandQueue = commandQueue
//        self.ciContext = ciContext
//        self.device = device
//    }
//    
//    func makeUIView(context: Context) -> MTKView {
//        mtkView = MTKView()
//        
//        mtkView.isOpaque = false
//        mtkView.enableSetNeedsDisplay = true
//        mtkView.framebufferOnly = false
//        
//        mtkView.device = self.device
//        
//        return mtkView
//    }
//    
//    func updateUIView(_ uiView: MTKView, context: Context) {
//        guard let _ = self.image, let _ = self.ciContext else { return }
//        
//        context.coordinator.render(image: self.image!, context: self.ciContext!, device: self.device)
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self, mtlTexture: self.mtlTexture, commandQueue: self.commandQueue, ciContext: self.ciContext, device: self.device)
//    }
//}
//
//extension MetalImageView {
//    class Coordinator: NSObject, MTKViewDelegate {
//        var parent: MetalImageView
//        
//        private var mtlTexture: MTLTexture?
//        private var commandQueue: MTLCommandQueue?
//        private var ciContext: CIContext?
//        private var device: MTLDevice?
//        
//        init(parent: MetalImageView, mtlTexture: MTLTexture? = nil, commandQueue: MTLCommandQueue? = nil, ciContext: CIContext? = nil, device: MTLDevice? = nil) {
//            self.parent = parent
//            self.mtlTexture = mtlTexture
//            self.commandQueue = commandQueue
//            self.ciContext = ciContext
//            self.device = device
//        }
//        
//        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
//            
//        }
//        
//        func draw(in view: MTKView) {
//            render(image: parent.image!, context: parent.ciContext!, device: parent.device!)
//        }
//        
//        func render(image: CIImage, context: CIContext, device: MTLDevice) {
//            ciContext = context
//            self.device = device
//            
//            var rect = parent.mtkView.bounds
//            rect = AVMakeRect(aspectRatio: image.extent.size, insideRect: rect)
//            
//            let filteredImage = image.transformed(by:
//                                                    CGAffineTransform(
//                                                        scaleX: rect.size.width/image.extent.size.width,
//                                                        y: rect.size.height/image.extent.size.height
//                                                    )
//            )
//            
//            let x = -rect.origin.x
//            let y = -rect.origin.y
//            
//            commandQueue = self.device?.makeCommandQueue()
//            
//            let buffer = commandQueue?.makeCommandBuffer()!
//            mtlTexture = parent.mtkView.currentDrawable?.texture
//            
//            ciContext!.render(filteredImage.oriented(.down),
//                              to: parent.mtkView.currentDrawable!.texture,
//                             commandBuffer: buffer,
//                              bounds: CGRect(origin: CGPoint(x: x, y: y), size: parent.mtkView.drawableSize),
//                             colorSpace: CGColorSpaceCreateDeviceRGB()
//            )
//            
//            buffer?.present(parent.mtkView.currentDrawable!)
//            buffer?.commit()
//        }
//    }
//}
