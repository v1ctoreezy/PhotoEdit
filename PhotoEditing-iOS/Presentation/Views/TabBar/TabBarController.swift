//
//  TabBarPage.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.11.2024.
//

import SwiftUI

enum TabBarPage: Int, CaseIterable, Equatable, Hashable {
    case news = 0
    case services
    case documents
    case profile
    
    func currentPage() -> TabBarPage {
        return self
    }

    func pageIcon() -> UIImage {
        switch self {
        case .news:
            return UIImg.Icons.Tabbar.news
        case .services:
            return UIImg.Icons.Tabbar.services
        case .documents:
            return UIImg.Icons.Tabbar.documents
        case .profile:
            return UIImg.Icons.Tabbar.profile
        }
    }
    
    func pageImage() -> Image {
        switch self {
        case .news:
            return Img.Icons.Tabbar.news
        case .services:
            return Img.Icons.Tabbar.services
        case .documents:
            return Img.Icons.Tabbar.documents
        case .profile:
            return Img.Icons.Tabbar.profile
        }
    }
}
