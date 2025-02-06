//
//  Request.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol Request {
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }
    var body: [String : Any] { get }
    var headers: [String: String] { get }
    associatedtype ReturnType: Decodable
}

extension Request {
    // Defaults
    var method: HTTPMethod { .get }
    var contentType: String { "application/json" }
    var queryParams: [String: String]? { nil }
    var body: [String: Any] { [:] }
    var headers: [String: String] { [:] }
    
    /// Serializes an HTTP dictionary to a JSON Data Object
    /// - Parameter params: HTTP Parameters dictionary
    /// - Returns: Encoded JSON
    private func requestBodyFrom(params: [String: Any]?) -> Data? {
        guard let params = params else { return nil }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return nil
        }
        return httpBody
    }
    
    /// Transforms an Request into a standard URL request
    /// - Parameter baseURL: API Base URL to be used
    /// - Returns: A ready to use URLRequest
    func asURLRequest(baseURL: String, token: String? = nil, xApiKey: String? = nil, platform: String = "ios") -> URLRequest? {
        let url = !baseURL.isEmpty ? (baseURL + path) : path
        guard var urlComponents = URLComponents(string: url) else { return nil }
        
        if method == .get {
            let items = body.map( { URLQueryItem(name: $0.key, value: "\($0.value)") } )
            urlComponents.queryItems = items
        }
        
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        if method != .get {
            request.httpBody = requestBodyFrom(params: body)
        }
        return request
    }
}
