//
//  TabViewModel.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 01.11.2024.
//

import Combine
import UIKit

//struct TabActions {
//    let tabNews: CompletionBlock
//    let tabServices: CompletionBlock
//    let tabDocuments: CompletionBlock
//    let tabProfile: CompletionBlock
//    let pushVC: (UIImage, @escaping (UIImage?) -> Void) -> Void
//}
//
//final class TabViewModel: ObservableObject {
//    
//    @Published var selectedPage: TabBarPage = .news
//    let actions: TabActions
//    
////    private let getNewsUseCase: GetNewsUseCase
//    
//    init(actions: TabActions) {
//        self.actions = actions
////        self.getNewsUseCase = getNewsUseCase
//        
//        getNews()
//    }
//    
//    func getNews() {
////        getNewsUseCase.execute(receiveCompletion: { completion in
////            
////        }, receiveValue: { res in
////            print(res)
////        }, params: nil)
//    }
//}

import Combine
import Foundation

enum Page {
    case home
    case search
    case profile
    case chat
    case cart
}

struct TabActions {
    let showChat: CompletionBlock
    let showLogin: CompletionBlock
//    let showLimitDelivery: (TaxyInfo, CartItem?) -> Void
    let addressError: CompletionBlock
}

final class TabViewModel: ObservableObject {
    
    // MARK: Dependence injection vars
    private let actions: TabActions
    
    // MARK: Public vars
    @Published var chatUnreadMessage: Int = 0
    
    var loggedIn = false
    
    // MARK: Private vars
    
    private var cancellables = [AnyCancellable]()
    
    // MARK: - Init
    
    init(
        actions: TabActions
    ) {
        print("TabViewModel_init")
        self.actions = actions
    }
    
    // MARK: - Public helpers
    
    /*func skipLogin(_ value: Bool) {
     setSkipLoginUseCase.fetch(value)
     }*/
    
    func handleError(_ error: Error) {
//        if let cartError = error as? AppCartError
    }
    
//    func receivePush(_ receivedPush: ReceivedPush) {
//        print("receivePush = \(receivedPush)")
//        send(receivedPush: receivedPush)
//        switch receivedPush.action {
//        case .appCart:
//            setPage(.cart)
//        case .showOrder:
//            if let orderId = receivedPush.orderId {
//                setPage(.profile)
//                NotificationCenter.default.post(name: .pushShowOrder, object: nil, userInfo: ["orderId": orderId])
//            }
//        case .scoreOrder:
//            if let orderId = receivedPush.orderId {
//                setPage(.profile)
//                NotificationCenter.default.post(name: .pushShowScoreOrder, object: nil, userInfo: ["orderId": orderId])
//            }
//        case .showMessages:
//            //isPresentingChat = true
//            break
//        case .product:
//            /*if let productId = receivedPush.productId {
//             if let product = findProduct(productId: Int(productId) ?? 0) {
//             pushProduct = product
//             showProduct = true
//             }
//             //setPage(.home)
//             //NotificationCenter.default.post(name: .pushShowProduct, object: nil, userInfo: ["productId": productId, "categoryId": categoryId])
//             }*/
//            break
//        default:
//            break
//        }
//    }
        
    // MARK: - Public helpers
    
    func setPage(_ page: Page) {
        print("setPage = \(String(describing: setPage))")
        
    }
    
    // MARK: - Private helpers
        
    // MARK: - API
    
//    private func send(receivedPush: ReceivedPush) {
//        pushReceivedUseCase.execute(
//            receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    print(error.localizedDescription)
//                case .finished: break
//                }
//            }, receiveValue: { _ in },
//            params: .init(messageId: receivedPush.messageId, userId: Int(receivedPush.userId ?? "")))
//    }
    
    func showChat(){
        if loggedIn {
            actions.showChat()
        } else {
            actions.showLogin()
        }
    }
    
    func showAddressError() {
        actions.addressError()
    }
}
