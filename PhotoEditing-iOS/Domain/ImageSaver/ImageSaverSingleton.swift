//
//  ImageSaverSingleton.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 08.02.2025.
//

import Foundation
import UIKit

final class ImageSaver: NSObject {
    private override init() { }
    
    static let shared = ImageSaver()
    
    var completion: CompletionBlock?
    
    func writeToPhotoAlbum(image: UIImage, completion: @escaping CompletionBlock) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc internal func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?()
        print("Save finished!")
    }
}
