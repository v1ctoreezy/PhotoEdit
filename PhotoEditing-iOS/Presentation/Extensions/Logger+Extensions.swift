//
//  Logger+Extensions.swift
//  UMobile
//
//  Created by Victor Cherkasov on 18.12.2024.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let appState = Logger(subsystem: subsystem, category: "AppState")
    static let appNetwork = Logger(subsystem: subsystem, category: "AppNetwork")
    static let error = Logger(subsystem: subsystem, category: "Error")
    
    static func logInConsole(errorType: LoggingType) {
        switch errorType {
        case .request(let title, let request, let requestId):
            Logger.appNetwork.notice(
                """
                | \(title) - \(request.url?.absoluteString ?? "" , privacy: .private)
                | ReqResDebugID - \(requestId)
                | Body - \(request, privacy: .private)
                | Headers - \(request.allHTTPHeaderFields?.debugDescription ?? "", privacy: .private)
                """
            )
        case .serialization(let title, let error, let requestId):
            Logger.appNetwork.fault(
                """
                | \(title) - \(String(describing: error))
                | ReqResDebugID - \(requestId)
                """
            )
        case .serverSide(let title, let response, let requestId):
            Logger.appNetwork.fault(
                """
                | \(title) - \(response.debugDescription ?? "")
                | ReqResDebugID - \(requestId)
                | Request - \(response?.url?.absoluteString ?? "", privacy: .private)
                | Headers - \(response?.allHeaderFields.debugDescription ?? "", privacy: .private)
                """
            )
        case .http(title: let title, let statusCode, let requestId):
            Logger.appNetwork.fault(
                """
                | \(title) - \(statusCode ?? -1)
                | ReqResDebugID - \(requestId)
                """
            )
        case .unprocessedAFError(title: let title, let requestId):
            Logger.appNetwork.fault(
                """
                | \(title)
                | ReqResDebugID - \(requestId)
                """
            )
        case .response(title: let title, let response, let requestTime, let body, let requestId):
            Logger.appNetwork.info(
                """
                | \(title) - \(response?.url?.absoluteString ?? "")
                | ReqResDebugID - \(requestId)
                | RequestTime - \(String(LoggingType.calculateTimeDifferenceInMs(requestTime))) ms
                | Body - \(body)
                """
            )
        }
    }
}
