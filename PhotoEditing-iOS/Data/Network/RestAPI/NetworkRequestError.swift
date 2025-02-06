//
//  NetworkRequestError.swift
//  UMobile
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation
import Alamofire

public enum NetworkRequestError: Error, LocalizedError, Equatable {
        
    case invalidRequest
    case badRequest
    case unauthorized
    case notFound
    case decodingError
    case urlSessionFailed(_ error: URLError)
    case unknownError
    case unprocessedAFError
    case error4xx(_ code: Int)
    case error5xx(_ code: Int)
    case custom(_ message: String?, _ value: Int? = nil)
    
    static func convertAFError(_ error: Error) -> Self {
        if let afError = error.asAFError {
            switch afError {
            case .responseSerializationFailed(_):
                return .decodingError
            case .sessionTaskFailed(_):
                return .invalidRequest
            default:
                return .unprocessedAFError
            }
        }
        
        switch error {
        case let urlError as URLError:
            return .urlSessionFailed(urlError)
        default:
            return .unknownError
        }
    }
    
    static func httpError(_ statusCode: Int) -> Self {
        switch statusCode {
        case 400: return .badRequest
        case 403: return .unauthorized
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
}
