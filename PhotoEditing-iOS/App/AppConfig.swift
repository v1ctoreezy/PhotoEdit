//
//  AppConfig.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 29.10.2024.
//

import Foundation

struct AppConfig {
    
    static let debugURL = "https://api.spaceflightnewsapi.net/v4/"
    
    static let prodURL = "https://api.spaceflightnewsapi.net/v4/"

    static func getBaseURL() -> String {
        #if DEBUG
        return AppConfig.debugURL
        #else
        return AppConfig.prodURL
        #endif
    }
}
