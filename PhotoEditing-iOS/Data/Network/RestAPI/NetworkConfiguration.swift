//
//  NetworkConfiguration.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation

protocol NetworkConfiguration {
    func getBaseUrl() -> String
}

class NetworkConfigurationImpl: NetworkConfiguration {

    func getBaseUrl() -> String {
        AppConfig.getBaseURL()
    }
}
