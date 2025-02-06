//
//  HostingController.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

final class HostingController<ContentView>: UIHostingController<ContentView> where ContentView: View {
    
    // MARK: - Properties
        
    var isDarkContentBackground = false
    
    let clearBackground: Bool
    
    // MARK: - Init
    
    init(rootView: ContentView, clear: Bool = false) {
        self.clearBackground = clear
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        
        if clearBackground {
            view.backgroundColor = .clear
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDarkContentBackground {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    // MARK: - Methods
    
    func statusBarEnterLightBackground() {
        // isDarkContentBackground = false
        // setNeedsStatusBarAppearanceUpdate()
    }

    func statusBarEnterDarkBackground() {
        // isDarkContentBackground = true
        // setNeedsStatusBarAppearanceUpdate()
    }
}
