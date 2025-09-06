//
//  PhotoEditingView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.05.2025.
//

import UIKit
import Metal
import MetalKit
import CoreImage
import Combine
import PixelEnginePackage
import SwiftUI

struct PhotoEditingView: View {
    @ObservedObject var model: PhotoEditingViewModel
    
    @State var imageView = UIImageView()
    @State private var canvas = Canvas()

    var body: some View {
        ZStack {
            AppNavBar(title: "Photo editing", backAction: model.closeScreen, trailingContent: { HStack { } }) {
                VStack {
                    ImageView(
                        image: Binding(get: { model.currentUIImage }, set: { _ in }),
                        imageView: imageView,
                        contentMode: Binding(
                            get: { .scaleAspectFill },
                            set: { _ in }
                        )
                    )
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .topLeading
                    )
                    .overlay(
                        // Main drawing canvas
                        CanvasView(canvas: $canvas, onChanged: { drawing in }, onSelectionChanged: { _ in })
                        .onAppear {
//                            mlCanvas.mainCanvas = canvas
//                            canvas.mlCanvas = mlCanvas
                        }
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 0,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                    )
                    
                    EditingControlsView(viewModel: model)
                        .frame(height: 200)
                }
            }
        }
        .background(
            Color.appBWVariants000900
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    
}

struct ImageView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    
    @Binding var image: UIImage
    var imageView: UIImageView
    
    @Binding var contentMode: UIView.ContentMode
    
    func makeUIView(context: Context) -> UIViewType {
        imageView.image = image
        imageView.backgroundColor = .clear
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
       
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return imageView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.image = image
        uiView.contentMode = contentMode
    }
}

struct MetalView: UIViewRepresentable {
    let device: MTLDevice
    let renderer: ImageRendererImpl
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = device
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        
        // Настройка view
        mtkView.clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        mtkView.enableSetNeedsDisplay = true
        mtkView.isOpaque = false
        mtkView.framebufferOnly = false
        
        // Update the renderer with the new MTKView
        renderer.updateMTKView(mtkView)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update the renderer's MTKView reference
        renderer.updateMTKView(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(renderer: renderer)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var renderer: ImageRendererImpl
        
        init(renderer: ImageRendererImpl) {
            self.renderer = renderer
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle size changes if needed
        }
        
        func draw(in view: MTKView) {
            renderer.draw(in: view)
        }
    }
}

// MARK: - Filter Controls View
struct FilterControlsView: View {
    @Binding var selectedFilter: MTLCustomPhotoFilters
    @Binding var intensity: Double
    let onFilterChange: (MTLCustomPhotoFilters) -> Void
    let onIntensityChange: (Double) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Filter Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(MTLCustomPhotoFilters.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            onFilterChange(filter)
                        }) {
                            Text(filter.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.3))
                                )
                                .foregroundColor(selectedFilter == filter ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Intensity Slider
            VStack(alignment: .leading) {
                Text("Intensity: \(String(format: "%.2f", intensity))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $intensity, in: -1.0...1.0)
                    .onChange(of: intensity) { newValue in
                        onIntensityChange(newValue)
                    }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - MTLCustomPhotoFilters Extension
extension MTLCustomPhotoFilters: CaseIterable {
    static var allCases: [MTLCustomPhotoFilters] {
        return [.Standart, .LinearBurn, .InvertedColor, .Exposition, .Contrast, .Saturation, .WhiteBalance]
    }
}


//struct PhotoEditingView: View {
//    
//    @ObservedObject var model: PhotoEditingViewModel
//    @State private var renderer: ImageRendererImpl?
//    @State private var metalContext: MetalContext?
//    @State private var device: MTLDevice?
//    @State private var selectedFilter: MTLCustomPhotoFilters = .Standart
//    @State private var filterIntensity: Double = 0.0
//    
//    var body: some View {
//        ZStack {
//            AppNavBar(title: "Photo editing", backAction: model.closeScreen, trailingContent: { HStack { } }) {
//                VStack {
//                    if let device = device, let renderer = renderer {
//                        MetalView(device: device, renderer: renderer)
//                            .frame(
//                                minWidth: 0,
//                                maxWidth: .infinity,
//                                minHeight: 0,
//                                maxHeight: .infinity,
//                                alignment: .topLeading
//                            )
//                    } else {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .overlay(
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle())
//                            )
//                    }
//                    
//                    EditingControlsView(viewModel: model)
//                        .frame(height: 200)
//                }
//            }
//            .onAppear {
//                setupMetalRenderer()
//            }
//            .onChange(of: model.currentCIImage) { newImage in
//                if let newImage = newImage {
//                    renderer?.currentImage = newImage
//                }
//            }
//            .onChange(of: model.intensity) { newIntensity in
//                renderer?.saturation = newIntensity
//            }
//        }
//        .background(
//            Color.appBWVariants000900
//                .edgesIgnoringSafeArea(.all)
//        )
//    }
//    
//    // MARK: - Public Methods for Filter Control
//    func selectFilter(_ filter: MTLCustomPhotoFilters) {
//        renderer?.setFilter(filter)
//    }
//    
//    func updateExposition(_ value: Double) {
//        renderer?.updateExposition(value)
//    }
//    
//    func updateContrast(_ value: Double) {
//        renderer?.updateContrast(value)
//    }
//    
//    func updateSaturation(_ value: Double) {
//        renderer?.updateSaturation(value)
//    }
//    
//    func updateWhiteBalance(_ value: Double) {
//        renderer?.updateWhiteBalance(value)
//    }
//    
//    private func updateFilterIntensity(_ intensity: Double) {
//        switch selectedFilter {
//        case .Exposition:
//            renderer?.updateExposition(intensity)
//        case .Contrast:
//            renderer?.updateContrast(intensity)
//        case .Saturation:
//            renderer?.updateSaturation(intensity)
//        case .WhiteBalance:
//            renderer?.updateWhiteBalance(intensity)
//        default:
//            break
//        }
//    }
//    
//    private func setupMetalRenderer() {
//        guard let device = MTLCreateSystemDefaultDevice() else {
//            print("Metal is not supported on this device")
//            return
//        }
//        
//        self.device = device
//        self.metalContext = MetalContext(device: device)
//        
//        // Create a temporary MTKView for initialization
//        let tempMTKView = MTKView()
//        tempMTKView.device = device
//        
//        self.renderer = ImageRendererImpl(
//            metalKitView: tempMTKView,
//            metalContext: metalContext!,
//            selectedFilter: .Standart
//        )
//        
//        // Set initial image if available
//        if let initialCIImage = model.currentCIImage {
//            self.renderer?.currentImage = initialCIImage
//        }
//    }
//}
