//
//  TabViewModel.swift
//  UMobile
//
//  Created by Good Shmorning on 01.11.2024.
//

import Combine
import UIKit

struct TabActions {
    let tabNews: CompletionBlock
    let tabServices: CompletionBlock
    let tabDocuments: CompletionBlock
    let tabProfile: CompletionBlock
    let pushVC: (UIImage, @escaping (UIImage?) -> Void) -> Void
}

final class TabViewModel: ObservableObject {
    
    @Published var selectedPage: TabBarPage = .news
    let actions: TabActions
    
//    private let getNewsUseCase: GetNewsUseCase
    
    init(actions: TabActions) {
        self.actions = actions
//        self.getNewsUseCase = getNewsUseCase
        
        getNews()
    }
    
    func getNews() {
//        getNewsUseCase.execute(receiveCompletion: { completion in
//            
//        }, receiveValue: { res in
//            print(res)
//        }, params: nil)
    }
}
