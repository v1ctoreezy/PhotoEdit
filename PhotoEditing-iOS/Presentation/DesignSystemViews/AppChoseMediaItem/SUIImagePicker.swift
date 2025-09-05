//
//  AppChoseMediaItem.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 03.02.2025.
//

import SwiftUI

struct SUIImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var selectImage: (UIImage) -> Void
//    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SUIImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<SUIImagePicker>) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
        var parent: SUIImagePicker
     
        init(_ parent: SUIImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
     
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectImage(image)
            }
     
//            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

final class ImagePicker: UIImagePickerController {
    private var userSourceType: UIImagePickerController.SourceType
    var passImage: (UIImage) -> Void
    
    init(sourceType: UIImagePickerController.SourceType, passImage: @escaping (UIImage) -> Void) {
        self.passImage = passImage
        self.userSourceType = sourceType
        
        super.init(nibName: nil, bundle: nil)
        configurePicker() // Добавьте вызов здесь
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurePicker() {
        self.mediaTypes = ["public.image"]
        
        self.sourceType = userSourceType
        self.allowsEditing = false
        self.delegate = self
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            passImage(image)
        }
        picker.dismiss(animated: true, completion: nil) // Добавьте dismiss
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // Обработка отмены
    }
}
