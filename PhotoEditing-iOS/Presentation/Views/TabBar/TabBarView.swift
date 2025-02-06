//
//  TabBarView.swift
//  UMobile
//
//  Created by Good Shmorning on 12.11.2024.
//

import SwiftUI

struct TabBarView: View {
    
    @ObservedObject var model: TabViewModel
    @State var selectedTab = 0
    @Binding private var visibility: TabBarVisibility
    
    init(
        selection: Binding<TabBarPage>,
        visibility: Binding<TabBarVisibility> = .constant(.visible),
        viewModel: TabViewModel
    ) {
        
        self._visibility = visibility
        self.model = viewModel
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack {
                TabView(selection: $selectedTab) {
                    Text("1")
                        .tag(0)
                    
                    VStack {
                        Text("1")
                    }
                    .tag(1)
                    
                    VStack {
                        Text("2")
                    }
                    .tag(2)
                    
                    VStack(spacing: 0) {
                        Text("1")
                    }
                    .tag(3)
                }.tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack {
                    Divider()
                    HStack {
                        ForEach((TabBarPage.allCases), id: \.self) { item in
                            Button {
                                selectedTab = item.rawValue
                            } label: {
                                EmptyView()
                            }
                            .buttonStyle(StateableButton(change: { state in
                                ZStack {
                                    TabBarItemView(page: item, isActive: .constant(state), isSelected: item.rawValue == selectedTab)
                                }
                            }))
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal)
                }
                .padding(.bottom, 34)
                .background(Color.appBWVariants000900)
                .visibility(self.visibility)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
