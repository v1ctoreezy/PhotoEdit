//
//  AppNavBar.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 08.02.2025.
//

import SwiftUI

struct AppNavBar<Content: View, TrailingContent: View>: View {
    let title: String
    let backAction: CompletionBlock?
    let trailingContent: () -> TrailingContent
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Img.Icons.DsIcons.icArrowRight
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.appBWVariants950000)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(180))
                    .onTapGesture {
                        backAction?()
                    }
                    .isHidden(backAction == nil)
                    .padding(.trailing, 10)
                
                Text(title)
                    .font(.app_L_Bold)
                    .foregroundColor(.appBWVariants950000)
                
                Spacer()
                
                trailingContent()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            
            content()
        }
    }
}
