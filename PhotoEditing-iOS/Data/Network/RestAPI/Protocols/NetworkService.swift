//
//  NetworkService.swift
//  UMobile
//
//  Created by Victor Cherkasov on 16.12.2024.
//

import Combine
import Alamofire
import UIKit

protocol NetworkService: AnyObject {

    func request<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError>
    func multipartUploadImage<R: Request>(_ request: R, image: UIImage, name: String) -> AnyPublisher<R.ReturnType, NetworkRequestError>
    func download<R: Request>(_ request: R) -> AnyPublisher<Bool, NetworkRequestError>
}
