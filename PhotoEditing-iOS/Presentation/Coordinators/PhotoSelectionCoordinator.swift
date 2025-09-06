//
//  PhotoSelectionCoordinator.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 13.11.2024.
//

import SwiftUI

// MARK: - Protocols

protocol CropCoordinatorDelegate: AnyObject {
    
    var callBackFlow: ((MainNavigationScreen) -> Void)? { get set }
    var finishFlow: LaunchCompletionBlock? { get set }
}

class PhotoSelectionCoordinator: BaseCoordinator, CropCoordinatorDelegate {
    
    // MARK: - Properties
    
    var callBackFlow: ((MainNavigationScreen) -> Void)?
    var finishFlow: LaunchCompletionBlock?
    var togleTabBar: CompletionBlock? 
    
    // MARK: - Fileprivate properties
    
    fileprivate let appRouter: Routable
    fileprivate let subRouter: Routable
    
    // MARK: - Private properties
    
    private let screensFactory: PhotoSelectionScreenFactory
    
    // MARK: - Initializers
    
    init(appRouter: Routable, screensFactory: PhotoSelectionScreenFactory, subNavigation: UINavigationController) {
        self.appRouter = appRouter
        self.screensFactory = screensFactory
        self.subRouter = Router(rootController: subNavigation)
    }
}

extension PhotoSelectionCoordinator: Coordinatable {
    
    func start() {
        performFlow()
    }
    
    
    func performFlow() {
        showPhotoSelection()
    }
    
    func showPhotoSelection() {
        let vc = screensFactory
            .makePhotoSelectionScreen(
                actions:
                    PhotoSelctionActions(
                        showCropView: { [weak self] image in
                            self?.showPhotoEdit(image)
                        },
                        showImagePicker: { [weak self] in
                            self?.showPhotoPicker()
                        }
                    )
            )
        
        self.subRouter.push(vc, animated: true)
    }
    
    
    func showPhotoEdit(_ image: UIImage?) {
        let vc = UIHostingController(rootView: PhotoEditingView(model: PhotoEditingViewModel(selectedImage: image!, actions: PhotoEditingActions(close: {[weak self] in self?.subRouter.dismiss(animated: true)}))))
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        self.subRouter.present(vc, animated: true)
    }
    
    func showPhotoPicker() {
        let vc = UIImagePickerController()
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        self.subRouter.present(vc, animated: true)
    }
}
