//
//  Router.swift
//  UMobile
//
//  Created by Good Shmorning on 11.11.2024.
//

import UIKit

final class Router: NSObject {
    
    private weak var rootController: UINavigationController?
    private var completions: RouterCompletions
    
    init(rootController: UINavigationController) {
        self.rootController = rootController
        completions = [:]
    }
    
    var toPresent: UIViewController? {
        return rootController
    }
}

private extension Router {
    func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}

extension Router: Routable {
    func present(_ module: Presentable?) {
        present(module, animated: true)
    }
    
    func present(_ module: Presentable?, animated: Bool) {
        guard let controller = module?.toPresent else { return }
        if var topController: UIViewController = rootController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(controller, animated: animated, completion: nil)
        }
    }
    
    func push(_ module: Presentable?)  {
        push(module,  animated: true)
    }
    
    func push(_ module: Presentable?, animated: Bool)  {
        push(module, animated: animated, completion: nil)
    }
    
    func push(_ module: Presentable?, animated: Bool, completion: CompletionBlock?) {
        guard let controller = module?.toPresent, !(controller is UINavigationController)
        else { assertionFailure("⚠️Deprecated push UINavigationController."); return }
        
        if let completion = completion {
            completions[controller] = completion
        }
        
        rootController?.pushViewController(controller, animated: animated)
    }
    
    func push(_ module: Presentable?, transition: CATransition, completion: CompletionBlock?) {
        guard let controller = module?.toPresent, !(controller is UINavigationController)
        else { assertionFailure("⚠️Deprecated push UINavigationController."); return }
        
        if let completion = completion {
            completions[controller] = completion
        }
        
        rootController?.view.layer.add(transition, forKey: nil)
        rootController?.pushViewController(controller, animated: false)
    }
    
    func popModule()  {
        popModule(animated: true)
    }
    
    func popModule(transition: CATransition)  {
        rootController?.view.layer.add(transition, forKey: kCATransition)
        if let controller = rootController?.popViewController(animated: false) {
            runCompletion(for: controller)
        }
    }
    
    func popModule(animated: Bool)  {
        if let controller = rootController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    func dismissModule() {
        dismissModule(animated: true, completion: nil)
    }
    
    func dismissModule(animated: Bool, completion: CompletionBlock?) {
        rootController?.dismiss(animated: animated, completion: completion)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func dismiss(animated: Bool){
        dismiss(animated: animated, completion: nil)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?){
        if var topController: UIViewController = rootController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.dismiss(animated: animated, completion: completion)
        }
    }
    
    func dismissAllPresented() {
        if let presentedViewController = rootController?.presentedViewController {
            if var vc = presentedViewController.presentingViewController {
                while (vc.presentingViewController != nil) {
                    vc = vc.presentingViewController!
                }
                vc.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func setRootModule(_ module: Presentable?) {
        setRootModule(module, hideBar: false)
    }
    
    func setRootModule(_ module: Presentable?, hideBar: Bool) {
        guard let controller = module?.toPresent else { return }
        rootController?.isNavigationBarHidden = true // fix bug navigation bar
        rootController?.setViewControllers([controller], animated: false)
    }
    
    func popToRootModule(animated: Bool) {
        if let controllers = rootController?.popToRootViewController(animated: animated) {
            controllers.forEach { controller in
                runCompletion(for: controller)
            }
        }
    }
}
