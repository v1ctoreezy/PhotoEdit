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
    let selectedFilter: String
    
//    let availableTools: []
    
    let data: [LUTCollection]
    let select: (FilterColorCube) -> Void
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0) {
                    Text(selectedFilter)
                        .font(.app_S)
                        .foregroundColor(.appBWVariants900000)

                    FilterListSelector(data: data)
                }
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(data, id: \.lutID) { collection in
                            HStack(spacing: 12){
                                ForEach(collection.lutCubePreviews, id: \.filter.identifier) { cube in
                                    FilterItem(cube: cube, select: select)
                                }
                            }.id("\(collection.lutID)-cube")
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                HStack {
                    Text(selectedFilter)
                        .font(.app_S)
                        .foregroundColor(.appBWVariants900000)
                    
                    Spacer()
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

//    let scrollTo: CompletionBlock
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(data, id: \.lutID) { collection in
                    HStack(spacing: 12){
                        Text(collection.lutName)
                            .font(.app_XS)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
