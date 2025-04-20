//
//  PhotoSelectionScreenFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import Foundation
import UIKit

protocol PhotoSelectionScreenFactory {
    func makePhotoSelectionScreen(actions: PhotoSelctionActions) -> UIViewController
    func makePhotoEditingScreen(image: UIImage, actions: PhotoEditingActions) -> UIViewController
}


extension ScreensFactory: PhotoSelectionScreenFactory {
    func makePhotoSelectionScreen(actions: PhotoSelctionActions) -> UIViewController {
        let contentView = dependencyProvider.assembler.resolver.resolve(PhotoSelectionView.self, argument: actions)
        let vc = HostingController(rootView: contentView)
        return vc
    }
    
    func makePhotoEditingScreen(image: UIImage, actions: PhotoEditingActions) -> UIViewController {
        let contentView = dependencyProvider.container.resolve(PhotoEditingView.self, arguments: image, actions)
        let vc = HostingController(rootView: contentView)
        return vc
    }
}
