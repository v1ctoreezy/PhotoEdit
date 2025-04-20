//
//  FilterObject.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 19.02.2025.
//

import Foundation
import UIKit

final class FilterObject: ObservableObject {
    private var disposables: CancelBag
    
    private var dataSource: FilterDataSource = .init()
    private var filterList: [ImgFilterCollection] = []

    @Published var isProcessing: Bool = false
    
    init() {
        disposables = []
        
        dataSource.$filtersCollection
            .sink { [weak self] newCollection in
                self?.filterList = newCollection
            }
            .store(in: &disposables)
    }
    
    func setImage(image: UIImage) {
        
        isProcessing = true
        
        DispatchQueue.global(qos: .background).async {
            self.filterList.forEach { filter in
                filter.setImage(image: image)
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    func selectFilter(id: String) {
        filterList.first { filter in
            filter.id == id
        }
    }
}
