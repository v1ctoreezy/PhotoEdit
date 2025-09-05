//
//  EditingControlsView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.07.2025.
//

import SwiftUI
import MetalKit
import PixelEnginePackage

struct EditingControlsView: View {
    @ObservedObject var viewModel: PhotoEditingViewModel
    
    @State private var currentPage: LUTControls = .filters
    @State private var showIntensity: Bool = false
    
    var body: some View {
        ZStack {
            ScrollViewReader { reader in
                VStack(spacing: 0) {
                    controls
                    
                    HStack(spacing: 10) {
                        Text(viewModel.lutImageEngine.selectedFilter?.name ?? "Original")
                            .font(.app_XS)
                            .foregroundColor(.appBWVariants900000)

                        FilterListSelector(data: viewModel.lutImageEngine.lutCollections) { id in
                            withAnimation {
                                reader.scrollTo("\(id)-cube", anchor: .leading)
                            }
                        }
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 16)
                    .isHidden(currentPage != .filters)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        switch currentPage {
                        case .filters:
                            filters
                        case .settings:
                            settings
                        case .recipe:
                            recipe
                        }
                    }
                }
            }
            .overlay {
                EditingSliderMenu(value: $viewModel.intensity) {
                    showIntensity = !showIntensity
                }
                .isHidden(!showIntensity)
//                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .move(edge: .bottom)))
//                    .animation(.easeInOut)
            }
        }
        .padding(.top, 10)
        .background(
            Color.appBWVariants000900
                .edgesIgnoringSafeArea(.bottom)
        )
    }
    
    var filters: some View {
        VStack {
            HStack(spacing: 12) {
                ForEach(viewModel.lutImageEngine.lutCollections, id: \.lutID) { collection in
                    HStack(spacing: 12) {
                        ForEach(collection.lutCubePreviews, id: \.filter.identifier) { cube in
                            FilterItem(cube: cube) {
                                viewModel.selectFilter(filter: $0)
                            }
                        }
                    
                        Divider()
                            .background(.appBWVariants900000)
                            .frame(width: 1)
                        
                    }.id("\(collection.lutID)-cube")
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
    
    var settings: some View {
        VStack {
            HStack {
                ForEach(0..<4) { id in
                    makeSettingsButton(icon: Image(systemName: "location.fill"), title: "intensity") {
                        showIntensity = !showIntensity
                    }
                    .id(id)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 30)
    }
    
    var recipe: some View {
        VStack {
            Text("Recipe")
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeControlButton(systemImage: String, isSelected: Bool, onClick: @escaping CompletionBlock) -> some View {
        Button {
            onClick()
        } label: {
            Image(systemName: systemImage)
                .font(.app_XL)
                .foregroundColor(isSelected ? .appBlue500 : .appBWVariants900000)
        }
    }
    
    @ViewBuilder
    private func makeSettingsButton(icon: SwiftUI.Image, title: String, action: @escaping CompletionBlock) -> some View {
        ZStack {
            Button {
                action()
            } label: {
                VStack(spacing: 10) {
                    icon
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                    
                    Text(title)
                        .font(.app_S)
                        .foregroundColor(.appBWVariants950000)
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    var controls: some View {
        HStack(spacing: 10) {
            Spacer()
            
            ForEach(viewModel.lutImageEngine.lutControls, id: \.self) { contrl in
                makeControlButton(systemImage: contrl.rawValue, isSelected: currentPage == contrl) {
                    currentPage = contrl
                }
                
                Spacer()
            }
            
            Button {
                
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.app_XL)
                    .foregroundColor(.appBWVariants900000)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct FilterItem: View {
    let cube: PreviewFilterColorCube
    let select: (FilterColorCube) -> Void
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(cgImage: cube.cgImage))
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 68, height: 60)
//                .frame(width: 20, height: 20)
                .clipped()
//                .isHidden()
            
            Text(cube.filter.name)
                .font(.app_XS)
                .frame(width: 68, height: 24)
//                .background(on ? Color.myPrimary : Color.myButtonDark)
                .foregroundColor(.white)
        }
        .frame(width: 68, height: 84)
        .background(Color.appBlackWhite700)
        .onTapGesture {
            select(cube.filter)
        }
    }
}

struct FilterListSelector: View {
    let data: [LUTCollection]
    
    let scrollToId: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(data, id: \.lutID) { collection in
                    HStack(spacing: 12){
                        Text(collection.lutName)
                            .font(.app_XS)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        scrollToId(collection.lutID)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
