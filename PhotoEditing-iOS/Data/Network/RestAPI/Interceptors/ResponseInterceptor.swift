//
//  ResponseInterceptor.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation
import Alamofire

protocol ResponseInterceptor {
    func intercept<Response>(response: AFDataResponse<Response>?, requestStartTime: DispatchTime, requestDebugId: String)
    func intercept<Response>(response: AFDownloadResponse<Response>?)

    func intercept(_ response: HTTPURLResponse?)
}

extension ResponseInterceptor {
    func intercept<Response>(response: AFDataResponse<Response>?) {
        intercept(response?.response)
    }

    func intercept<Response>(response: AFDownloadResponse<Response>?) {
        intercept(response?.response)
    }
}
