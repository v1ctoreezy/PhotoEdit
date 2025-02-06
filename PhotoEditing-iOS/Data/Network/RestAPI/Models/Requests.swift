//
//  Requests.swift
//  UMobile
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Foundation
 
struct UmobileRequest {
    struct News: Request { // TODO: удалить
        typealias ReturnType = UmobileResponse.News
        var path: String = "articles"
        var method: HTTPMethod = .get
        var body: [String : Any]
    }
}
