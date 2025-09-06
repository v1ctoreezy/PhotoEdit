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
    
    func getFilteredImage() -> CGImage?
}

class ImageRendererImpl: NSObject, ImageRenderer {
    var currentImage: CIImage {
        get {
            ciImage!
        }
        set {
            ciImage = newValue
            currentMTKView?.setNeedsDisplay()
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
    
    var saturation: Double = 0.0 {
        didSet {
            applySaturation()
        }
    }
    
    var exposition: Double = 0.0 {
        didSet {
            applyExposition()
        }
    }
    
    var contrast: Double = 0.0 {
        didSet {
            applyContast()
        }
    }
    
    var whiteBalance: Double = 0.0 {
        didSet {
            applyWhiteBalance()
        }
    }
    
    private var mtlCustromFilter: MTLCustomPhotoFilters
    
    private var ciContext: CIContext
    private var metalContext: MetalContext
    private var currentMTKView: MTKView?
    private var pipelineState: MTLRenderPipelineState?
    
    private var ciImage: CIImage?
    private var vertexBuffer: MTLBuffer?
    private var expositionBuffer: MTLBuffer?
    private var contrastBuffer: MTLBuffer?
    private var saturationBuffer: MTLBuffer?
    private var whiteBalanceBuffer: MTLBuffer?
        
    init(metalKitView mtkView: MTKView, metalContext: MetalContext, selectedFilter: MTLCustomPhotoFilters) {
        self.metalContext = metalContext
        self.ciContext = CIContext(mtlDevice: self.metalContext.device)
        self.mtlCustromFilter = selectedFilter
        self.metalContext = metalContext
        
        super.init()
        
        createRenderPipelineState()
        setupVertexBuffer()
        setupParameterBuffers()

        currentMTKView?.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        currentMTKView?.delegate = self
    }
    
    // Method to update the current MTKView reference
    func updateMTKView(_ mtkView: MTKView) {
        self.currentMTKView = mtkView
        mtkView.delegate = self
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        
        // Recreate pipeline state with new MTKView pixel formats
        createRenderPipelineState()
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
    
    func setupParameterBuffers() {
        // Create buffers for photo instrument parameters
        expositionBuffer = metalContext.device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        contrastBuffer = metalContext.device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        saturationBuffer = metalContext.device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        whiteBalanceBuffer = metalContext.device.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        
        // Initialize with default values
        updateParameterBuffer(expositionBuffer, value: Float(exposition))
        updateParameterBuffer(contrastBuffer, value: Float(contrast))
        updateParameterBuffer(saturationBuffer, value: Float(saturation))
        updateParameterBuffer(whiteBalanceBuffer, value: Float(whiteBalance))
    }
    
    private func updateParameterBuffer(_ buffer: MTLBuffer?, value: Float) {
        guard let buffer = buffer else { return }
        let pointer = buffer.contents().bindMemory(to: Float.self, capacity: 1)
        pointer[0] = value
    }
    
    private func setParameterBuffer(for encoder: MTLRenderCommandEncoder) {
        switch mtlCustromFilter {
        case .Exposition:
            if let buffer = expositionBuffer {
                encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            }
        case .Contrast:
            if let buffer = contrastBuffer {
                encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            }
        case .Saturation:
            if let buffer = saturationBuffer {
                encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            }
        case .WhiteBalance:
            if let buffer = whiteBalanceBuffer {
                encoder.setFragmentBuffer(buffer, offset: 0, index: 0)
            }
        default:
            break
        }
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
        
        // Set appropriate parameter buffer based on current filter
        setParameterBuffer(for: encoder)
        
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
        self.currentMTKView = view
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let commandBuffer = metalContext.commandQueue.makeCommandBuffer(),
              let pipelineState = pipelineState,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let vertexBuffer = vertexBuffer,
              let image = ciImage else { return }
        
        guard let inputTexture = createTexture(from: image, device: metalContext.device, pixelFormat: .bgra8Unorm) else { return }
        
        // Убеждаемся, что render pass descriptor настроен правильно
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Настройка depth attachment если нужно
        if let depthAttachment = renderPassDescriptor.depthAttachment {
            depthAttachment.loadAction = .clear
            depthAttachment.storeAction = .store
            depthAttachment.clearDepth = 1.0
        }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(inputTexture, index: 0)
        encoder.setFragmentSamplerState(makeSampler(), index: 0)
        
        // Set appropriate parameter buffer based on current filter
        setParameterBuffer(for: encoder)
        
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
        pipelineDescriptor.colorAttachments[0].pixelFormat = currentMTKView?.colorPixelFormat ?? .bgra8Unorm
        
        // Настройка depth pixel format для соответствия MTKView
        if let depthFormat = currentMTKView?.depthStencilPixelFormat {
            pipelineDescriptor.depthAttachmentPixelFormat = depthFormat
        }

        do {
            pipelineState = try metalContext.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Ошибка создания pipeline: \(error)")
            print("Color pixel format: \(currentMTKView?.colorPixelFormat.rawValue ?? 0)")
            print("Depth pixel format: \(currentMTKView?.depthStencilPixelFormat.rawValue ?? 0)")
            fatalError("Не удалось создать pipeline: \(error)")
        }
    }
}

// MARK: - Photo Instruments
/*
 Пример использования Photo Instruments:
 
 let renderer = ImageRendererImpl(metalKitView: mtkView, metalContext: context, selectedFilter: .Standart)
 
 // Применение экспозиции (диапазон: -2.0 до 2.0)
 renderer.setFilter(.Exposition)
 renderer.updateExposition(0.5) // Увеличить яркость
 
 // Применение контраста (диапазон: -1.0 до 1.0)
 renderer.setFilter(.Contrast)
 renderer.updateContrast(0.3) // Увеличить контраст
 
 // Применение насыщенности (диапазон: -1.0 до 1.0)
 renderer.setFilter(.Saturation)
 renderer.updateSaturation(0.2) // Увеличить насыщенность
 
 // Применение баланса белого (диапазон: -1.0 до 1.0)
 renderer.setFilter(.WhiteBalance)
 renderer.updateWhiteBalance(-0.1) // Сделать изображение более холодным
 
 // Возврат к стандартному фильтру
 renderer.setFilter(.Standart)
 */
extension ImageRendererImpl {
    private func applyExposition() {
        updateParameterBuffer(expositionBuffer, value: Float(exposition))
        currentMTKView?.setNeedsDisplay()
    }
    
    private func applyContast() {
        updateParameterBuffer(contrastBuffer, value: Float(contrast))
        currentMTKView?.setNeedsDisplay()
    }
    
    private func applySaturation() {
        updateParameterBuffer(saturationBuffer, value: Float(saturation))
        currentMTKView?.setNeedsDisplay()
    }
    
    private func applyWhiteBalance() {
        updateParameterBuffer(whiteBalanceBuffer, value: Float(whiteBalance))
        currentMTKView?.setNeedsDisplay()
    }
    
    // Public methods for changing filter and parameters
    func setFilter(_ filter: MTLCustomPhotoFilters) {
        mtlCustromFilter = filter
        createRenderPipelineState()
        currentMTKView?.setNeedsDisplay()
    }
    
    func updateExposition(_ value: Double) {
        exposition = value
    }
    
    func updateContrast(_ value: Double) {
        contrast = value
    }
    
    func updateSaturation(_ value: Double) {
        saturation = value
    }
    
    func updateWhiteBalance(_ value: Double) {
        whiteBalance = value
    }
}
