//
//  ApiServiceFactory.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Combine
import UIKit
import Alamofire

class RestApiService: NetworkServiceImpl{}

class ExternalApiService: NetworkServiceImpl{}

class ApiServiceFactory {

    static func makeRestApiService(networkConfiguration: NetworkConfiguration) -> RestApiService {

        let baseUrl = networkConfiguration.getBaseUrl()

        let interceptors: [RequestInterceptor] = [
            LogInterceptor(),
        ]

        return RestApiService(baseUrl: baseUrl, interceptors: interceptors)
    }

    static func makeOtherRestApiService() -> ExternalApiService {
        ExternalApiService(baseUrl: "", interceptors: [LogInterceptor()])
    }
}
