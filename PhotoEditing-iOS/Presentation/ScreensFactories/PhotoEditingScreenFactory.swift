//
//  PhotoEditingScreenFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 09.02.2025.
//

import Foundation
import UIKit

protocol PhotoEditingScreenFactory {
    func makeEditPhotoScreen(image: UIImage, actions: PhotoEditingActions) -> UIViewController
}

extension ScreensFactory: PhotoEditingScreenFactory {
    func makeEditPhotoScreen(image: UIImage, actions: PhotoEditingActions) -> UIViewController {
        let contentView = dependencyProvider.assembler.resolver.resolve(PhotoEditingView.self, arguments: image, actions)
        let vc = HostingController(rootView: contentView)
        
        return vc
    }
}
