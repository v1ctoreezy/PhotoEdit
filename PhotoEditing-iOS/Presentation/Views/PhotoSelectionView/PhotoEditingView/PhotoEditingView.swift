//
//  PhotoEditingView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 07.02.2025.
//

import SwiftUI

enum PhotoEditingUiState {
    case `default`
    case exposition
    case settings
}

struct PhotoEditingView: View {
    @ObservedObject var model: PhotoEditingViewModel
    
    @State var isSaving: Bool = false
    
    @State private var state: PhotoEditingUiState = .default
    @State var intensity: CGFloat = 0.0
    
    @State var currentView: PhotoEditingUiState = .default
    
    var device: MTLDevice
    var context: CIContext
    
    var animatableData: any Animatable = -1000
    
    init(model: PhotoEditingViewModel) {
        self.model = model
        
        self.device = MTLCreateSystemDefaultDevice()!
        self.context = CIContext(mtlDevice: self.device)
    }
    
    var body: some View {
        AppNavBar(title: "Photo editing", backAction: model.dismiss, trailingContent: {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        model.savePhotoToUserLibrary(self.model.image) { }
                    }
            }
        }){
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        mainImage
                        
                        HStack(spacing: 48) {
                            Button("default") {
                                self.state = .default
                            }
                            
                            Button("settings") {
                                self.state = .settings
                            }
                            
                            Button("exposition") {
                                self.state = .exposition
                            }
                        }
                        
                        VStack(spacing: 0) {
                            ZStack {
                                switch state {
                                case .default:
                                    VStack(spacing: 0) {
                                        filterHeader
                                        
                                        FiltersListView(filteredImages: model.filteredImages) { newImg in
                                            self.model.image = newImg
                                        }
                                    }
                                case .exposition:
                                    VStack(spacing: 0) {
                                        Text("exposition")
                                    }
                                case .settings:
                                    VStack(spacing: 0) {
                                        Text("settings")
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    var mainImage: some View {
//        ZStack {
//            if let ciImage = CIImage(image: model.image)?.oriented(CIImage.mapOrientation(model.image.imageOrientation)) {
//                MetalImageView(image: ciImage, device: self.device, context: self.context)
//                    .frame(width: UIScreen.main.bounds.width)
////                    .frame(minHeight: 30, idealHeight: UIScreen.main.bounds.width, maxHeight: .infinity)
//                //                    .frame(maxHeight: 343)
//            }
//        }
                Image(uiImage: model.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(maxHeight: .infinity)
    }
    
    var filterHeader: some View {
        HStack(spacing: 0) {
            Text("T1")
                .font(.app_S)
                .foregroundColor(.appBWVariants950000)
            
            
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    LazyHStack {
                        ForEach(0..<10) { _ in
                            Text("dddd")
                                .font(.app_S)
                                .onTapGesture {
                                    self.state = .exposition
                                }
                        }
                    }
                }
                .fixedSize()
            }
            .scrollIndicators(.hidden)
        }
    }
}
