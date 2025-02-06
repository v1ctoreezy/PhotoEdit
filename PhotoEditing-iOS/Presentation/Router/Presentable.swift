//
//  Presentable.swift
//  UMobile
//
//  Created by Good Shmorning on 11.11.2024.
//

import UIKit

protocol Presentable {
    var toPresent: UIViewController? { get }
}

extension UIViewController: Presentable {
    var toPresent: UIViewController? {
        return self
    }
}
