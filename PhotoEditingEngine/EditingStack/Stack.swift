//
//  Stack.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 08.08.2025.
//

import Foundation

struct Stack<T> {
    private var arrayStack: [T] = []
    
    var isEmpty: Bool {
        arrayStack.isEmpty
    }
    
    var count: Int {
        arrayStack.count
    }
    
    var last: T {
        arrayStack[arrayStack.count - 1]
    }
    
    init() { }
    
    mutating func pop() -> T {
        arrayStack.removeLast()
    }
    
    mutating func push(item: T) {
        arrayStack.append(item)
    }
    
    mutating func pushItemAt(index: Int, item: T) {
        self.popToIndex(index)
        self.push(item: item)
    }
    
    public subscript(index: Int) -> T {
        getItemInternal(at: index)
    }
    
    private func getItemInternal(at index: Int) -> T {
        return arrayStack[index]
    }
    
    private mutating func popToIndex(_ index: Int) {
        self.arrayStack.removeSubrange((index + 1)..<arrayStack.count)
    }
}
