//
//  AppPaginator.swift
//  UMobile
//
//  Created by Victor Cherkasov on 13.12.2024.
//

import SwiftUI

struct AppPaginator<Content: View>: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
        
    @State var swipeOffset: CGFloat = .zero
    
    @State private var contentOffset: CGPoint = .zero
    @State private var scrollViewWidth: CGFloat = .zero
    @State private var scrollViewVisibleWidth: CGFloat = .zero
    
    @Binding var currentPage: Int
    var pagesCount: Int

    var height: CGFloat = .infinity
    
    let backgroundColor: Color
    
    let indicatorPadding: CGFloat
    
    private let content: () -> Content
           
    init(
        currentPage: Binding<Int>,
        pagesCount: Int,
        backgroundColor: Color,
        height: CGFloat = .infinity,
        indicatorPadding: CGFloat = 10.0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._currentPage = currentPage
        self.pagesCount = pagesCount
        self.backgroundColor = backgroundColor
        self.height = height
        self.content = content
        self.indicatorPadding = indicatorPadding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                content()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: height)
            .padding(.bottom, indicatorPadding)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ForEach(0..<pagesCount, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.appBlackWhite000 : Color.appBlackWhite000.opacity(0.5))
                            .frame(width: index == currentPage ? 32 : 8, height: 8)
                            .animation(.easeInOut, value: index == currentPage)
                    }
                }
                .padding(.bottom, 18)
            }
        }
    }
}
