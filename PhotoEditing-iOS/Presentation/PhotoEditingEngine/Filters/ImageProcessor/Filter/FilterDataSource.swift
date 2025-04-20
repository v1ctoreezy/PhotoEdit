//
//  FilterDataSource.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 20.02.2025.
//

import Foundation
import UIKit

final class FilterDataSource: ObservableObject {
    
    @Published var filtersCollection: [ImgFilterCollection]
    
    init() {
        let standartiOS = ImgCollectionImpl(name: "iOS stn.", id: "iOS stn.")
        
        standartiOS.setFilters = FilterStandartIOSType.allCases.map {
            ImgStandartFilterImpl(name: $0.rawValue, id: $0.rawValue, type: $0)
        }
        
        self.filtersCollection = [
            standartiOS
        ]
    }
}
