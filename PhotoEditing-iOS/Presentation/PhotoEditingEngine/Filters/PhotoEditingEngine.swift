//
//  PhotoEditingEngine.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 07.02.2025.
//

import Foundation
import SwiftUI
import UIKit

final class PhotoEditingEngine: UIViewController {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
