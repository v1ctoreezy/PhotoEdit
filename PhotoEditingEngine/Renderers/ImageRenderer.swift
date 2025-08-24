//
//  Renderer.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.05.2025.
//

import Foundation
import MetalKit

protocol ImageRenderer: MTKViewDelegate {
    var currentImage: CIImage { get set }
    var verBuffer: MTLBuffer? { get set }
    
    var currentFilter: MTLCustomPhotoFilters { get set }
    func getFilteredImage() -> CGImage?
}

class ImageRendererImpl: NSObject, ImageRenderer {
    var currentImage: CIImage {
        get {
            ciImage!
        }
        set {
            ciImage = newValue
            metalKitView.setNeedsDisplay()
        }
    }
    
    var verBuffer: MTLBuffer? {
        get {
            vertexBuffer
        }
        set {
            vertexBuffer = newValue
        }
    }
    
    var currentFilter: MTLCustomPhotoFilters {
        get {
            mtlCustromFilter
        }
        set {
            mtlCustromFilter = newValue
            createRenderPipelineState()
            metalKitView.setNeedsDisplay()
        }
    }
    
    private var mtlCustromFilter: MTLCustomPhotoFilters
    
    private var ciContext: CIContext
    private var metalContext: MetalContext
    private var metalKitView: MTKView
    private var pipelineState: MTLRenderPipelineState?
    
    private var ciImage: CIImage?
    private var vertexBuffer: MTLBuffer?
        
    init(metalKitView mtkView: MTKView, metalContext: MetalContext, selectedFilter: MTLCustomPhotoFilters) {
        self.metalContext = metalContext
        self.ciContext = CIContext(mtlDevice: self.metalContext.device)
        self.mtlCustromFilter = selectedFilter
        self.metalKitView = mtkView
        self.metalContext = metalContext
        super.init()
        
        createRenderPipelineState()
        setupVertexBuffer()

        metalKitView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        metalKitView.delegate = self
    }
    
    func setupVertexBuffer() {
        let vertices: [Vertex] = [
            Vertex(position: [-1,  1], texCoord: [0, 1]),  // top-left
            Vertex(position: [-1, -1], texCoord: [0, 0]),  // bottom-left
            Vertex(position: [ 1, -1], texCoord: [1, 0]),  // bottom-right

            Vertex(position: [-1,  1], texCoord: [0, 1]),  // top-left
            Vertex(position: [ 1, -1], texCoord: [1, 0]),  // bottom-right
            Vertex(position: [ 1,  1], texCoord: [1, 1])   // top-right
        ]

        vertexBuffer = metalContext.device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: [])
    }
    
    func getFilteredImage() -> CGImage? {
        guard let commandBuffer = metalContext.commandQueue.makeCommandBuffer(),
              let pipelineState = pipelineState,
              let vertexBuffer = vertexBuffer,
              let image = ciImage else { return nil }

        let width = Int(image.extent.width)
        let height = Int(image.extent.height)

        // 1. Создаем output текстуру
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: width,
            height: height,
            mipmapped: false
        )
        
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        guard let outputTexture = metalContext.device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }

        // 2. Создаем input текстуру из CIImage
        guard let inputTexture = createTexture(from: image, device: metalContext.device) else { return nil }

        // 3. Render Pass Descriptor для outputTexture
        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = outputTexture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        passDescriptor.colorAttachments[0].storeAction = .store

        // 4. Команда рендеринга
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return nil
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(inputTexture, index: 0)
        encoder.setFragmentSamplerState(makeSampler(), index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()

        // 5. Завершение буфера
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // 6. Преобразуем outputTexture → CGImage через CIContext
        let ciImage = CIImage(mtlTexture: outputTexture, options: [.colorSpace: CGColorSpaceCreateDeviceRGB()])?.oriented(.up)
        // если ориентация важна

        guard let resultImage = ciImage else { return nil }

        return ciContext.createCGImage(resultImage, from: resultImage.extent)
    }
}

extension ImageRendererImpl {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = metalContext.commandQueue.makeCommandBuffer(),
              let pipelineState = pipelineState,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let vertexBuffer = vertexBuffer,
              let image = ciImage else { return }
        
        guard let inputTexture = createTexture(from: image, device: metalContext.device, pixelFormat: .bgra8Unorm) else { return }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(inputTexture, index: 0)
        encoder.setFragmentSamplerState(makeSampler(), index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func createTexture(from ciImage: CIImage,
                       device: MTLDevice,
                       pixelFormat: MTLPixelFormat = .rgba8Unorm) -> MTLTexture? {
        
        let width = Int(ciImage.extent.width)
        let height = Int(ciImage.extent.height)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            print("Ошибка: не удалось создать текстуру Metal")
            return nil
        }
        
        ciContext.render(
            ciImage,
            to: texture,
            commandBuffer: nil,
            bounds: ciImage.extent,
            colorSpace: ciImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        )
        
        return texture
    }

    private func makeSampler() -> MTLSamplerState {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.sAddressMode = .clampToEdge
        descriptor.tAddressMode = .clampToEdge
        return metalContext.device.makeSamplerState(descriptor: descriptor)!
    }
    
    private func createRenderPipelineState() {
        guard let library = metalContext.device.makeDefaultLibrary() else {
            fatalError("Не удалось загрузить Metal library")
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_passthrough")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: mtlCustromFilter.rawValue)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat

        do {
            pipelineState = try metalContext.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Не удалось создать pipeline: \(error)")
        }
    }
}
