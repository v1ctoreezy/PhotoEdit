//
//  FilterCollection.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 19.02.2025.
//

import Foundation
import UIKit

protocol ImgFilterCollection {
    var name: String { get }
    var id: String { get }
    var transformedImgs: [UIImage] { get }
    var setFilters: [ImgFilter] { get set }
    
    func setImage(image: UIImage)
    func selectFilterBy(id: String)
    
    func reset()
}

public class ImgCollectionImpl: ImgFilterCollection {
    public let name: String
    public let id: String
    
    var setFilters: [ImgFilter] {
        set {
            filters = newValue
        }
        get {
            self.filters
        }
    }
    
    private var filters: [ImgFilter] = []
    public var transformedImgs: [UIImage] = []
    
    public init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    public func setImage(image: UIImage) {
        filters.forEach {
            transformedImgs.append($0.applyFilter(to: image))
        }
    }
    
    public func reset() {
        transformedImgs = []
    }
    
    public func selectFilterBy(id: String) {
        
    }
}
