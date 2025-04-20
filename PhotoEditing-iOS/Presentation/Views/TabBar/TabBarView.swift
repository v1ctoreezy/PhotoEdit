//
//  TabBarView.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

//struct TabBarView: View {
//    
//    @ObservedObject var model: TabViewModel
//    @State var selectedTab = 0
//    @Binding private var visibility: TabBarVisibility
//    
//    init(
//        selection: Binding<TabBarPage>,
//        visibility: Binding<TabBarVisibility> = .constant(.visible),
//        viewModel: TabViewModel
//    ) {
//        
//        self._visibility = visibility
//        self.model = viewModel
//    }
//    
//    var body: some View {
//        TabView(selection: $selectedTab) {
//            VStack {
//                PhotoEditingView(model: PhotoEditingViewModel())
//            }
//            .tabItem { Image(systemName: "house") }
//            .tag(0)
//            
//            VStack {
//                Text("1")
//            }
//            .tabItem { Image(systemName: "house") }
//            .tag(1)
//            
//            VStack {
//                Text("2")
//            }
//            .tabItem { Image(systemName: "house") }
//            .tag(2)
//            
//            VStack(spacing: 0) {
//                Text("3")
//            }
//            .tabItem { Image(systemName: "house") }
//            .tag(3)
//        }
//        .tabViewStyle(.automatic)
//    }
//}

class TabBarView: UIView {

    var selectedPage: TabBarPage = .photoEdit {
        didSet {
            items.forEach {
                $0.isActive = $0.tabType == selectedPage
            }
        }
    }

    var pages: [TabBarPage] = [] {
        didSet {
            updatePages()
        }
    }

    var callback: ((TabBarPage) -> Void)?

    private var items: [TabBarItemView] = []

    private let horizontalStack: UIStackView = {
        let contentStack = UIStackView()
        contentStack.axis = .horizontal
        contentStack.distribution = .fillEqually
        contentStack.alignment = .fill
        contentStack.spacing = 0
        return contentStack
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Color.appRed500.uiColor()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        config()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config() {

        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        [horizontalStack, divider].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraints = [
            horizontalStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            horizontalStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            horizontalStack.topAnchor.constraint(equalTo: topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            divider.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            divider.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func updatePages() {
        items.forEach {
            horizontalStack.removeArrangedSubview($0)
        }
        items.removeAll()

        for page in pages {
            let item = TabBarItemView(tabType: page)
            item.callback = callback
            items.append(item)
        }

        items.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            horizontalStack.addArrangedSubview($0)
        }
    }

    func setAmount(amount: Float) {
//        items.first { $0.tabType == .cart }?.amount = Double(amount)
    }
    
    func setIsEmpty(itemsCount: Int) {
//        items.first { $0.tabType == .cart }?.isEmpty = itemsCount > 0 ? false : true
    }

    func setMessageCount(count: Int){
//        items.first { $0.tabType == .chat }?.setCount(count: count)
    }

}
