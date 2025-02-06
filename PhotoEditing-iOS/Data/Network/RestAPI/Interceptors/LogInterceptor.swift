//
//  LogInterceptor.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation
import Alamofire
import OSLog

final class LogInterceptor: RequestInterceptor, ResponseInterceptor {
    func intercept<Response>(response: AFDataResponse<Response>?, requestStartTime: DispatchTime, requestDebugId: String) {
        let body = response?.data ?? Data()
        let bodyWrapped = String(decoding: body, as: UTF8.self)
        
        if let _wrappedRequest = response?.request {
            Logger.logInConsole(errorType: .response(response?.response, requestStartTime, bodyWrapped, requestDebugId))
        }
    }

    func intercept<Response>(response: AFDownloadResponse<Response>?){
        print("🐷🐷🐷response_str = \(response!.request!.url!) response = \(response)")
    }

    func intercept(_ response: HTTPURLResponse?) {
    }
}
