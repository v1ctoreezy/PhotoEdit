//
//  LoggingType.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 17.12.2024.
//

import Foundation
import Alamofire

enum LoggingType {
    case request(
        title: String = "🐸🐸🐸 Request",
        _ request: URLRequest,
        _ requestId: String
    )
    case response(
        title: String = "🐷🐷🐷 Response",
        _ response: HTTPURLResponse?,
        _ requestTime: DispatchTime,
        _ body: String,
        _ requestId: String
    )
    case serialization(
        title: String = "🤒🤒🤒 Error Serialization Failed",
        _ response: AFError,
        _ requestId: String
    )
    case serverSide(
        title: String = "🗿🗿🗿 Error - виноват бэк",
        _ response: HTTPURLResponse?,
        _ requestId: String
    )
    case http(
        title: String = "📲📲📲 Http error",
        _ statusCode: Int?,
        _ requestId: String
    )
    case unprocessedAFError(
        title: String = "📲📲📲 Unprocessed Alamofire error",
        _ requestId: String
    )
    
    static func calculateTimeDifferenceInMs(_ requestStartTime: DispatchTime) -> UInt64 {
        return {
            let endTimeRequest = DispatchTime.now()
            let nanoTime = endTimeRequest.uptimeNanoseconds - requestStartTime.uptimeNanoseconds
            let timeInterval = nanoTime / 1_000_000
            return timeInterval
        }()
    }
}
