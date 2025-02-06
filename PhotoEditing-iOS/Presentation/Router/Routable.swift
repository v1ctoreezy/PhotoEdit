//
//  Routable.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 11.11.2024.
//

import UIKit

typealias CompletionBlock = () -> Void
typealias RouterCompletions = [UIViewController: CompletionBlock]

protocol Routable: Presentable {

    func present(_ module: Presentable?)
    func present(_ module: Presentable?, animated: Bool)

    func push(_ module: Presentable?)
    func push(_ module: Presentable?, animated: Bool)
    func push(_ module: Presentable?, animated: Bool, completion: CompletionBlock?)
    func push(_ module: Presentable?, transition: CATransition, completion: CompletionBlock?)

    func popModule()
    func popModule(animated: Bool)
    func popModule(transition: CATransition)

    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)

    func dismiss()
    func dismiss(animated: Bool)
    func dismiss(animated: Bool, completion: CompletionBlock?)
    
    func dismissAllPresented()

    func setRootModule(_ module: Presentable?)
    func setRootModule(_ module: Presentable?, hideBar: Bool)

    func popToRootModule(animated: Bool)
}

