//
//  UseCase.swift
//  UMobile
//
//  Created by Victor Cherkasov on 17.12.2024.
//

import Foundation
import Combine

protocol AppScheduler {
    func getScheduler() -> DispatchQueue
}

public final class MainScheduler: AppScheduler {
    
    func getScheduler() -> DispatchQueue {
        return _mainQueue
    }
    
    private let _mainQueue: DispatchQueue = DispatchQueue.main
}

public final class UserInitiatedScheduler: AppScheduler {
    
    func getScheduler() -> DispatchQueue {
        return _queue
    }
    
    private let _queue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
}

class UseCase<ReturnType, Params> {
    
    final let executionScheduler: AppScheduler
    final let postExecutionScheduler: AppScheduler
    private var disposables: CancelBag
    
    init(executionScheduler: AppScheduler,
         postExecutionScheduler: AppScheduler) {
        self.executionScheduler = executionScheduler
        self.postExecutionScheduler = postExecutionScheduler
        disposables = []
    }
    
    func buildPublisher(params: Params) -> AnyPublisher<ReturnType, Error> {
        abort()
    }
    
    func execute(
        receiveCompletion: @escaping (Subscribers.Completion<Error>) -> Void,
        receiveValue: @escaping (ReturnType) -> Void,
        params: Params
    ) {
        execute(receiveCompletion: receiveCompletion, receiveValue: receiveValue, params: params, delay: 0)
    }
    
    func execute(receiveCompletion: @escaping (Subscribers.Completion<Error>) -> Void,
                 receiveValue: @escaping (ReturnType) -> Void,
                 params: Params,
                 delay: Int
    ) {
        var publisher: AnyPublisher<ReturnType, Error>
        if delay > 0 {
            publisher = Just(true)
                .delay(for: .milliseconds(delay), scheduler: postExecutionScheduler.getScheduler())
                .flatMap { _ in
                    self.buildPublisher(params: params)
                }
                .eraseToAnyPublisher()
        } else {
            publisher = buildPublisher(params: params)
        }
        
        publisher.subscribe(on: executionScheduler.getScheduler())
            .receive(on: postExecutionScheduler.getScheduler())
            .sink(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
            .store(in: &disposables)
    }
    
    func execute(observer: @escaping (SingleEvent<ReturnType>) -> Void,
                 params: Params,
                 delay: Int = 0) {
        self.execute(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                observer(.failure(error))
                break
            case .finished:
                break
            }
        }, receiveValue: { value in
            observer(.success(value))
        }, params: params, delay: delay)
    }
    
    func dispose() {
        disposables.cancelAll()
    }
}

public enum Event<Element> {
    case next(Element)
    case failure(Swift.Error)
    case finished
}

public enum SingleEvent<Element> {
    case success(Element)
    case failure(Swift.Error)
}

typealias CancelBag = Set<AnyCancellable>

extension CancelBag {
    mutating func cancelAll() {
        forEach { $0.cancel() }
        removeAll()
    }
}
