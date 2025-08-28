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
    
    var body: some View {
        ZStack {
            ScrollViewReader { reader in
                VStack {
                    HStack(spacing: 10) {
                        Text(viewModel.lutImageEngine.selectedFilter?.name ?? "")
                            .font(.app_S)
                            .foregroundColor(.appBWVariants900000)

                        FilterListSelector(data: viewModel.lutImageEngine.lutCollections) { id in
                            withAnimation {
                                reader.scrollTo("\(id)-cube", anchor: .leading)
                            }
                        }
                    }
                                        
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.lutImageEngine.lutCollections, id: \.lutID) { collection in
                                HStack(spacing: 12){
                                    ForEach(collection.lutCubePreviews, id: \.filter.identifier) { cube in
                                        FilterItem(cube: cube) {
                                            viewModel.selectFilter(filter: $0)
                                        }
                                    }
                                }.id("\(collection.lutID)-cube")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    HStack(spacing: 10) {
                        Text(viewModel.lutImageEngine.selectedFilter?.name ?? "")
                            .font(.app_S)
                            .foregroundColor(.appBWVariants900000)

                        FilterListSelector(data: viewModel.lutImageEngine.lutCollections) { id in
                            withAnimation {
                                reader.scrollTo("\(id)-cube", anchor: .leading)
                            }
                        }
                    }
                    
//                    Spacer()
                    
    //                HStack {
    //                    Text(viewModel.lutImageEngine.selectedFilter?.name ?? "")
    //                        .font(.app_S)
    //                        .foregroundColor(.appBWVariants900000)
    //
    //                    Spacer()
    //                }
                }
            }
        }
        .frame(height: 150)
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
            
            Text(cube.filter.name)
                .font(.app_XS)
                .frame(width: 68, height: 24)
//                .background(on ? Color.myPrimary : Color.myButtonDark)
                .foregroundColor(.white)
        }
        .frame(width: 68)
        .background(Color.appBlackWhite100)
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
