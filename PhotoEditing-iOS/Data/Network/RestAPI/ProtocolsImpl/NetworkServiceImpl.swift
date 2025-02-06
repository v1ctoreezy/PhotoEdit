//
//  NetworkServiceImpl.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Combine
import UIKit
import Alamofire
import OSLog

class NetworkServiceImpl: NetworkService {

    private let baseUrl: String
    private let interceptors: [RequestInterceptor]

    private let _manager: Session
    private let _requestTimeout: Double = 45.0

    private let _decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(baseUrl: String, interceptors: [RequestInterceptor]) {

        self.baseUrl = baseUrl
        self.interceptors = interceptors
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = _requestTimeout
        config.timeoutIntervalForResource = _requestTimeout
        config.urlCache = nil

        let interceptor = Interceptor(interceptors: interceptors)
        _manager = Alamofire.Session(configuration: config, interceptor: interceptor)
    }
    
    // MARK: - Request

    func request<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {

        guard let urlRequest = request.asURLRequest(baseURL: baseUrl) else {
            return Fail(outputType: R.ReturnType.self, failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }

        let requestDebugId = UUID().description
        let requestStartTime = DispatchTime.now()
        
        Logger.logInConsole(errorType: .request(urlRequest, requestDebugId))
        
        return _manager.request(urlRequest)
            .responseData(queue: DispatchQueue.main, completionHandler: { response in
                self.interceptResponse(response: response, requestStartTime: requestStartTime, requestDebugId: requestDebugId)
            })
            .publishDecodable(type: R.ReturnType.self, decoder: _decoder)
            .tryCompactMap({ (response) -> R.ReturnType? in
                
                if let _statusCode = response.response?.statusCode, !(200...299).contains(_statusCode) {
                    let appError = self.handleHttpError(_statusCode)
                    self.logError(response: response, error: appError, requestId: requestDebugId)

                    throw appError
                }
                
                if let error = response.error {
                    let appError = self.handleAFError(error)
                    self.logError(response: response, error: appError, requestId: requestDebugId)
                    throw appError
                }
                
                return response.value ?? nil
            })
            .mapError { error in
                if error as? NetworkRequestError == nil {
                    return self.handleAFError(error)
                }
                
                return error as! NetworkRequestError
            }
            .eraseToAnyPublisher()
        
    }
    // MARK: - Upload
    
    func multipartUploadImage<R: Request>(_ request: R, image: UIKit.UIImage, name: String) -> AnyPublisher<R.ReturnType, NetworkRequestError> {

        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]

        let fullUrl = baseUrl + request.path
        
        let requestDebugId = UUID().description
        let requestStartTime = DispatchTime.now()
        
        return _manager.upload(multipartFormData: { multipartFormData in
            for (key, value) in request.body {
                if let data = try? JSONSerialization.data(withJSONObject: value, options: []) {
                    multipartFormData.append(data, withName: key)
                }
            }
            if let imageData = image.resize(1) {
                multipartFormData.append(imageData, withName: name, fileName: "\(Date.init().timeIntervalSince1970).jpg", mimeType: "image/jpg")
            }
        }, to: fullUrl, headers: headers)
        .responseData(queue: DispatchQueue.main, completionHandler: { response in
            self.interceptResponse(response: response, requestStartTime: requestStartTime, requestDebugId: requestDebugId)
        })
        .publishDecodable(type: R.ReturnType.self, decoder: _decoder)
        .tryCompactMap({ (response) -> R.ReturnType? in
            
            if let _statusCode = response.response?.statusCode, !(200...299).contains(_statusCode) {
                let appError = self.handleHttpError(_statusCode)
                self.logError(response: response, error: appError, requestId: requestDebugId)

                throw appError
            }
            
            if let error = response.error {
                let appError = self.handleAFError(error)
                self.logError(response: response, error: appError, requestId: requestDebugId)
                                                        
                throw appError
            }
            
            return response.value ?? nil
        })
        .mapError { error in
            self.handleAFError(error)
        }
        .eraseToAnyPublisher()
        
    }
    
    // MARK: - Download

    func download<R: Request>(_ request: R) -> AnyPublisher<Bool, NetworkRequestError> {
        guard let urlRequest = request.asURLRequest(baseURL: baseUrl) else {
            return Fail(outputType: Bool.self, failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }

        let destination: DownloadRequest.Destination = { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent("pass.pkpass")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let requestDebugId = UUID().description
        let requestStartTime = DispatchTime.now()
        
        Logger.logInConsole(errorType: .request(urlRequest, requestDebugId))
        
        return _manager.download(urlRequest, to: destination).downloadProgress { progress in
            print("Progress: \(progress.fractionCompleted)")
        }
        .publishData(queue: DispatchQueue.main)
        .tryCompactMap { response in
            
            self.interceptResponse(response: response, requestStartTime: requestStartTime, requestDebugId: requestDebugId)
            
            if let _statusCode = response.response?.statusCode, !(200...299).contains(_statusCode) {
                throw self.handleHttpError(_statusCode)
            }
            
            if let error = response.error {
                throw self.handleAFError(error)
            }
                        
            if let _ = response.value {
                return true
            }
            return false
        }
        .mapError { error in
            self.handleAFError(error)
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Interceptors

extension NetworkServiceImpl {
    private func interceptResponse<Response>(response: AFDataResponse<Response>?, requestStartTime: DispatchTime, requestDebugId: String) {
        interceptors.forEach {
            ($0 as? ResponseInterceptor)?.intercept(response: response, requestStartTime: requestStartTime, requestDebugId: requestDebugId)
        }
    }
    
    private func interceptResponse<Response>(response: AFDownloadResponse<Response>?, requestStartTime: DispatchTime, requestDebugId: String) {
        interceptors.forEach {
            ($0 as? ResponseInterceptor)?.intercept(response: response)
        }
    }
}

// MARK: - Handling errors and logging

extension NetworkServiceImpl {
    private func logError<Response>(response: AFDataResponse<Response>? = nil, error: NetworkRequestError, requestId: String) {
        if let _response = response?.response {
            switch error {
            case .decodingError:
                if let _error = response?.error, response?.error?.isResponseSerializationError ?? false {
                    Logger.logInConsole(errorType: .serialization(_error, requestId))
                }
            case .unprocessedAFError:
                Logger.logInConsole(errorType: .unprocessedAFError(requestId))
            case .error5xx(_):
                if (500...599).contains(_response.statusCode) {
                    Logger.logInConsole(errorType: .serverSide(_response, requestId))
                }
            default:
                break
            }
        }
    }
    
    private func handleAFError(_ error: Error) -> NetworkRequestError {
        return NetworkRequestError.convertAFError(error)
    }
    
    private func handleHttpError(_ statusCode: Int) -> NetworkRequestError {
        return NetworkRequestError.httpError(statusCode)
    }
}
