//
//  ViewController.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import UIKit

final class RootNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    let viewModel: RootNavigationViewModel
    
    init(viewModel: RootNavigationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = navigationController.viewControllers.count > 1
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1 && presentedViewController == nil
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        gestureRecognizer === interactivePopGestureRecognizer
    }

}

